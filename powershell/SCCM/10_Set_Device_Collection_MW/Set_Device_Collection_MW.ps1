Import-Module ConfigurationManager
Set-Location csn:


#Run on Site server 
 

 
Function Set-PatchMW ([datetime]$StartTime, [datetime]$EndTime, [string] $CollID, [string] $CollName) 
 {
    #Create The Schedule Token
    $Schedule = New-CMSchedule -Nonrecurring -Start $StartTime -End $EndTime 

    $MWName = "MW from '$StartTime' to '$EndTime'"

    #Set Maintenance Windows 
    $newMW = New-CMMaintenanceWindow -CollectionID $CollID -Schedule $Schedule -Name $MWName -ApplyToSoftwareUpdateOnly 
    Write-Host "$CollName `t $($newMW.StartTime) `t $EndTime `t $($newMW.Duration)mins"
    Add-Content -Path $outfile -Value "$CollName,$CollID,$($newMW.StartTime),$EndTime,$($newMW.Duration)"
} 
 
#Remove all existing Maintenance Windows for a Collection 
Function Remove-MaintnanceWindows ([string]$CollID)  
{ 
    Get-CMMaintenanceWindow -CollectionId $CollID | ForEach-Object { 
        Remove-CMMaintenanceWindow -CollectionID $CollID -Name $_.Name -Force 
        $Coll=Get-CMDeviceCollection -CollectionId $CollID 
        Write-Host "Removing MW:"$_.Name"- From Collection:"$Coll.Name 
    } 
} 
 


$inputs = Import-Csv -Path "E:\AdminTools\SCCM_Script\10_Set_Device_Collection_MW\Input.csv"
$outfile = "E:\AdminTools\SCCM_Script\10_Set_Device_Collection_MW\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "CollectionName, CollectionID, StartTime,EndTime,Duration(mins)"
$x = 1
$count = $inputs.Count
foreach($input in $inputs){

    $collectionID = ""
    $CollectionName = $input.CollectionName
    [datetime]$MWStartTime = $input.MWStartTime
    [datetime]$MWEndtTime = $input.MWEndTime

    Write-Host "Processing '$CollectionName'"


    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Set Maintenance Window on Device Collection" `
        -Status "Progress ($x of $count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation "Processing '$CollectionName'"


    $collectionID = Get-CMDeviceCollection -Name $CollectionName | select -ExpandProperty collectionID

    #validate date time
    if($MWStartTime -gt $MWEndtTime){
        Write-Host "$CollectionName `t Error. Start date should be less than end time" -ForegroundColor Red
        Add-Content -Path $outfile "$CollectionName, Error. Start date should be less than end time"  
    }elseif($collectionID -eq $null){
        Write-Host "$CollectionName `t Error. Collection Name not valid" -ForegroundColor Red
        Add-Content -Path $outfile "$CollectionName, Error. Collection Name not valid" 
    }else{
         #Remove Previous Maintenance Windows 
        Remove-MaintnanceWindows $collectionID 
 
        #set MW on device collection
        Set-PatchMW -StartTime $MWStartTime -EndTime $MWEndtTime -CollID $collectionID -CollName $CollectionName
   
    }

     Write-Host ""
     Write-Host "--------------next--------------"
     $x++
}

#send email
$to = "pradeep.viswanathan@trizetto.com"
$to = "CISTZInfraWindowsOperations@cognizant.com"
$from = "automated-script@trizetto.com"
$smtp = "mail-2.trizetto.net"
$subject = "Set Maintenance Window on Device Collection"
$bodyAsHtml = "Hi, <br><br> Maintenance window has been set on Device Collections. <br> PFA file for more detail. <br><br> Thanks, <br>SCCM"

Send-MailMessage -Attachments $outfile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHtml
