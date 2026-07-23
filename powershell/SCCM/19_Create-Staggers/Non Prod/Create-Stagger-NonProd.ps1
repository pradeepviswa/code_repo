$stagger1 = "NON PROD STAGGER 1"
$stagger2 = "NON PROD STAGGER 2"
$stagger3 = "NON PROD STAGGER 3"
$stagger4 = "NON PROD STAGGER 4"
$EarlyDeviceCollection = "MW NON PROD EARLY SERVERS"
$RegularDeviceCollection = "MW NON PROD REGULAR SERVERS"

Import-Module ConfigurationManager
cd csn:
$dir = Split-Path $Script:Myinvocation.Mycommand.path
Write-Host "Loading '$EarlyDeviceCollection' servers in variable" -ForegroundColor Yellow
$EarlyServers = Get-CMDevice -CollectionName "$EarlyDeviceCollection" | select -ExpandProperty name
Write-Host "Loading '$RegularDeviceCollection' servers in variable" -ForegroundColor Yellow
$RegularServers = Get-CMDevice -CollectionName "$RegularDeviceCollection"

Write-Host "Early server count is : $($EarlyServers.Count)"

$count = $RegularServers.Count
if($count -lt 1){
    $count = 1
}




#------------------------------ PRIORITIZING
write-host "Sorting priority customers...Please wait"
$priority = @()
$priority += "AHP"
$priority += "BRI"
$priority += "BCN"
$priority += "CVS"
$priority += "CSH"
$priority += "EMB"
$priority += "FAL"
$priority += "HSN"
$priority += "HZN"
$priority += "MMM"
$priority += "AVM"
$priority += "IHP"
$priority += "KMH"
$priority += "NHP"
$priority += "PHP"
$priority += "SAS"
$priority += "SWH"
$priority += "TPZ"
$priority += "VIB"
$priority += "VPH"
$priority += "CIP"
$priority += "CIG"
$priority += "DHP"
$priority += "ICH"
$priority += "MHH"
$priority += "MHP"
$priority += "RHCP"
$priority += "SLB"
$priority += "CNC"
$priority += "SHP"
$priority += "TXC"
$priority += "UHN"
$priority += "CMC"
$priority += "OHD"
$priority += "UAM"
$priority += "VHI"
$priority += "WMK"
$priority += "AHW"
$priority += "ATR"
$priority += "CMB"
$priority += "COA"
$priority += "COV"
$priority += "DHH"
$priority += "GHP"
$priority += "HMS"
$priority += "HNT"
$priority += "LAC"
$priority += "PFS"
$priority += "QCA"
$priority += "SMH"
$priority += "SPH"
$priority += "UHA"
$priority += "VHP"
$priority += "WHA"


$RegularServers_NewSequence = @()
$x = 0
$count = $priority.Count
Write-Host "Regular server count is : $($RegularServers.Count)"
foreach($p in $priority){
    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
        

    foreach($row in $RegularServers){
        Write-Progress -Activity "Sorting Priority List: $p" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent
        $name = $row.name
        $ResourceID = $row.ResourceID
        if($name -match $p){
            $RegularServers_NewSequence += "$name,$ResourceID"
        }
    }    
}

$x = 0
$count = $RegularServers.Count
Write-Host "After sorting priority customers, new list count is : $($RegularServers_NewSequence.Count). Adding missing serves now...Please wait"
foreach($row in $RegularServers){
    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
        Write-Progress -Activity "Sorting Priority List" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

    $name = $row.name
    $ResourceID = $row.ResourceID
    if($RegularServers_NewSequence -notcontains "$name,$ResourceID"){
        $RegularServers_NewSequence += "$name,$ResourceID"
    }
}
Write-Host "New list final count is: $($RegularServers_NewSequence.Count)"



#------------------------------
Write-Host "Dividing Servers in 3 Groups" -ForegroundColor Yellow
[int]$limit =  $count/3

$Group1 = $EarlyServers# DO NOT TROUCH GROUP1. THIS CONTAINS EARLY REBOOT CUSTOMERS
$Group2 = @()
$Group3 = @()
$Group4 = @()
$y = 0
$limit2 = $limit
$limit3 = $limit2 + $limit
$limit4 = $limit3 + $limit

foreach($row in $RegularServers_NewSequence){
    $y++
    $computer = $row.split(",")[0]
    $ResourceId = $row.split(",")[1]
    
    if($y -le $limit2){
        $Group2 += "$computer,$ResourceId"

    }elseif($y -le $limit3){
        $Group3 += "$computer,$ResourceId"

    }elseif($y -le $limit4){
        $Group4 += "$computer,$ResourceId"

    }else{
        $Group4 += "$computer,$ResourceId"
    }
    
}
Write-Host "Group1 = $($Group1.Count)"
Write-Host "Group2 = $($Group2.Count)"
Write-Host "Group3 = $($Group3.Count)"
Write-Host "Group4 = $($Group4.Count)"

function AddToStagger{
    param(
    [string[]]$rows,
    [string]$collectionName
    )

    $x = 0
    $count = $rows.Count
    if($count -lt 1){
        $count = 1
    }
    
    foreach($row in $rows){
    
        $x++
        $percent = "{0:N2}" -f ($x/$count * 100)
        
        Write-Progress -Activity "Collection '$collectionName': $computer" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

        $computer = $row.split(",")[0]
        $ResourceId = $row.split(",")[1]
        
        if($ResourceId -eq $null){
            Write-Host "Computer not found - $computer" -ForegroundColor Yellow
        }else{
            try{
                Add-CMDeviceCollectionDirectMembershipRule -CollectionName $collectionName -ResourceId $ResourceId -ErrorAction Stop -ErrorVariable er
                #Write-Host "$computer in $collectionName"
        
            }catch{
                $showError = $er[0]
        
                $msg = "$computer in $collectionName `t Error: $($showError.Message)"
                Write-Host $msg -ForegroundColor Yellow
                    
        
            }

        }
    
    
    
    }
}


AddToStagger -rows $Group2 -collectionName "$stagger2"
AddToStagger -rows $Group3 -collectionName "$stagger3"
AddToStagger -rows $Group4 -collectionName "$stagger4"

$Group1_Output = "$dir\Group1.txt"
$Group2_Output = "$dir\Group2.txt"
$Group3_Output = "$dir\Group3.txt"
$Group4_Output = "$dir\Group4.txt"

$Group1 | Out-File $Group1_Output
$Group2 | Out-File $Group2_Output
$Group3 | Out-File $Group3_Output
$Group4 | Out-File $Group4_Output

$to = 'CISTZInfraWindowsOperations@cognizant.com'
$to = "pradeep.viswanathan@cognizant.com"
$from = "automated-script@trizetto.com"
$smtp = "mail-2.trizetto.net"
$subject = "Maintenance Window - 4 Staggers NON PROD"
$body = @"
Please refer attached files. <br>
4 staggers. Stagger wise server count:<br>
$stagger1 : $($Group1.Count) <br>
$stagger2 : $($Group2.Count) <br>
$stagger3 : $($Group3.Count) <br>
$stagger4 : $($Group4.Count) <br>
<br>
These servers will be patched and rebooted.<br>

"@
Send-MailMessage -To  $to -From $from -SmtpServer $smtp -Subject $subject -Attachments $Group1_Output,$Group2_Output,$Group3_Output,$Group4_Output
#Remove-CMDeviceCollectionDirectMembershipRule