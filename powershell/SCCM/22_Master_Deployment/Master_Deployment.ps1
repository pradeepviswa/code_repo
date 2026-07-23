# Uncomment the line below if running in an environment where script signing is required.
#Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Site configuration
$SiteCode = "CSN" # Site code 
$ProviderMachineName = "csn-svc-sccm-01.services.tzghosting.net" # SMS Provider machine name

# Customizations
$initParams = @{}
#$initParams.Add("Verbose", $true) # Uncomment this line to enable verbose logging
#$initParams.Add("ErrorAction", "Stop") # Uncomment this line to stop the script on any errors

# Do not change anything below this line

# Import the ConfigurationManager.psd1 module 
if((Get-Module ConfigurationManager) -eq $null) {
    Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" @initParams 
}

# Connect to the site's drive if it is not already present
if((Get-PSDrive -Name $SiteCode -PSProvider CMSite -ErrorAction SilentlyContinue) -eq $null) {
    New-PSDrive -Name $SiteCode -PSProvider CMSite -Root $ProviderMachineName @initParams
}

# Set the current location to be the site code.
Set-Location "$($SiteCode):\" @initParams

$dir = Split-Path $Script:Myinvocation.Mycommand.path

#Email Values
$to = "pradeep.viswanathan@cognizant.com"
$to = "CISTZInfraWindowsOperations@cognizant.com"
$from = "MWNoReplyHOC2@cognizant.com"
$smtp = "mail-2.trizetto.net"

######################## STEP1 - ADD PATCHES TO SUG BEGIN ########################


Function Step1_AddPatchesToSUG{
    ################## validate package name begin
    $packageName = ""
    $flag= $false
    Function Read_PackageName(){
        $packageName = Read-Host "Enter Package Name. This package will be used if patch download is pending"
        $packageName = $packageName.Trim()
        return $packageName
    }
    Write-Host "Please wait. Fetching list of Existing Packages:" -ForegroundColor Cyan
    $AllPkgs = get-CMSoftwareUpdateDeploymentPackage | select -ExpandProperty name
    $AllPkgs | Sort-Object
    do{
        $packageName = Read_PackageName
        $validPackage = get-CMSoftwareUpdateDeploymentPackage -Name $packageName
    
        if($validPackage -eq $null){
            $flag = $false
            "Invalid package name. Retry"
        }else{
            $flag = $true
            "Ok Valid package name. Moving to next step."
        }
    }until($flag)
    ############### validate package name end

    $outfile = "$dir\1_Output_AddPatchesToSUG.csv"
    Remove-Item -Path $outfile -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path $outfile | Out-Null
    Set-Content -Path $outfile -Value "BulletinID,ArticleID,SUGName,Status,Description"


    #import values from csv file
    $lines = Import-Csv -Path "$dir\1_Input_AddPatchesToSUG.csv"

    #for loop to add each patch in SUG
    Write-Host "Adding Patches to SUG. In progress..." -ForegroundColor Yellow
    $count =0
    if(!($lines.Count)){$count = 1}
    else{$count = $lines.Count}
    $x = 1
    $notFound = @()
    $notRequired = @()
    foreach($line in $lines){

        #variables
        $output = ""
        $patch = $($line.patch).trim()
        $SUGName = $($line.SUGName).trim()

        $percent = "{0:N2}" -f ($x/$count * 100)
        Write-Progress -Activity "Add patches to SUG" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "$patch to $SUGName" 


        #remove KB string from patch
        $patch = $patch.Replace("KB","")
        
        if( ($patch.Trim() -eq "") -or ($SUGName.Trim() -eq "")){
            $patch = "BlankPatch or SUG name; Patch - '$patch'; SUG - '$SUGName';"
        }

        $softwareUpdates = @()
        if($patch -match "KB"){
            $softwareUpdates = Get-CMSoftwareUpdate -Fast -ArticleId $patch
     
        }elseif($patch -match "MS"){
            $softwareUpdates = Get-CMSoftwareUpdate -Fast -BulletinId $patch
        }else{
            $softwareUpdates = Get-CMSoftwareUpdate -Fast -ArticleId $patch
            #$softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}
        }

    

        #add each Software Update ID in SUG
        $req = 0
    
        foreach($softwareUpdate in $softwareUpdates){
                <#
                if( 
                    ( $softwareUpdate.LocalizedDisplayName -notmatch "itanium") -and 
                    ( ($softwareUpdate.LocalizedDisplayName -match "server") -or 
                        ($softwareUpdate.LocalizedDisplayName -match "Windows 7") -or
                        ($softwareUpdate.LocalizedDisplayName -match "Windows 8") -or 
                        ($softwareUpdate.LocalizedDisplayName -match "Windows 10") ) -and 
                    ( $softwareUpdate.nummissing -ne 0 )            
                )
                #>
                if( $softwareUpdate.nummissing -ne 0 ){


                    #get software update ID
                    $SoftwareUpdateId = $softwareUpdate.CI_ID
                
                    $description = ""
                

                    #find software update gorup
                    $sug = Get-CMSoftwareUpdateGroup -Name $SUGName
                    if($sug.count -lt 1){
                        New-CMSoftwareUpdateGroup -Name $SUGName -Description "$SUGName Servers" | Out-Null
                        Write-Host "'$SUGName' SUG not found. Created It" -ForegroundColor Yellow
                    }

                    #check whther software-update is IsDeployable or not
                    if($softwareUpdate.IsDeployable){
                        #Add patch to SUG
                        Add-CMSoftwareUpdateToGroup `
                            -SoftwareUpdateGroupName $SUGName `
                            -SoftwareUpdateId $SoftwareUpdateId
        
                        $BulletinID = $softwareUpdate.BulletinID
                        $ArticleID = $softwareUpdate.ArticleID
                        $description = $softwareUpdate.LocalizedDisplayName

                        Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                        $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                        Add-Content -Path $outfile -Value $output
                    }else{
                        #download patch
                        Write-Host "Downloading..... `t '$BulletinID' `t '$ArticleID' in Package '$packageName'"
                        try{
                            Invoke-CMSoftwareUpdateDownload `
                                -SoftwareUpdateId $SoftwareUpdateId `
                                -DeploymentPackageName $packageName -ErrorAction Stop -ErrorVariable er


                            #Add patch to SUG
                            Add-CMSoftwareUpdateToGroup `
                                -SoftwareUpdateGroupName $SUGName `
                                -SoftwareUpdateId $SoftwareUpdateId
        
                            $BulletinID = $softwareUpdate.BulletinID
                            $ArticleID = $softwareUpdate.ArticleID
                            $description = $softwareUpdate.LocalizedDisplayName

                            Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                            $output = "$BulletinID,$ArticleID,$SUGName,Added,$description"
                            Add-Content -Path $outfile -Value $output


                        }catch{
                            $msg = $er.message
                            Write-Host "'$patch' `t Download Failed. $msg" -ForegroundColor Yellow
                            $output = ",$patch,$SUGName,Download Failed. $msg"
                            Add-Content -Path $outfile -Value $output
                        }

                
                    }


                    $req++
                }#if
            
     
            }#foreach softwareUpdates
        
            if($softwareUpdates.count -lt 1){
                        Write-Host "$patch Not found" -ForegroundColor Red
                        $output = "$patch,$patch,,Not Found"
                        Add-Content -Path $outfile -Value $output
                        $notFound += $patch
    
            }elseif( $req -eq 0){
                        Write-Host "$patch Not Required" -ForegroundColor Red
                        $output = ",$patch,$SUGName,Not Required,Supported OS not present "
                        Add-Content -Path $outfile -Value $output
                        $notRequired += $patch

            }

        
            $x++
    }#foreach patches


    $subject = "Add patches to Software Update Group"
    $notFoundHtml = ""
    $notRequiredHtml = ""
    foreach($p in $notFound){
        $notFoundHtml += "$p<br>"
    }
    foreach($p in $notRequired){
        $notRequiredHtml += "$p<br>"
    }
    $bodyAsHtml = "
    Hi, 
        <br><br> Added Patches in Software Update Group. <br>
        Package Used = $packageName <br>
        Total Patch Count = $($lines.Count) <br><br>
        <font color = red>
        <b><u>Patches Not Found in SCCM:</u></b><br>
        $notFoundHtml
        <br><br>
        <b><u>Patches Not Required on any server/node:</u></b><br>
        $notRequiredHtml
        <br><br>

        </font>
        
        <br>
        PFA file for more detail. <br><br> Thanks, <br>SCCM
"

    Send-MailMessage -Attachments $outfile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHtml
    Write-Host "Done!! Add patches to SUG `n`n" -ForegroundColor Yellow

}



######################## STEP1 - ADD PATCHES TO SUG END ########################



################### STEP 2 - SET MAINTENANCE WINDOW  BEGIN ###################
 
Function Step2_SetMaintenanceWindow{

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

    $inputs = Import-Csv -Path "$dir\2_Input_Set_MaintenanceWindow.csv"
    $outfile = "$dir\2_Output_Set_MaintenanceWindow.csv"

    Remove-Item -Path $outfile -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path $outfile | Out-Null
    Set-Content -Path $outfile -Value "CollectionName, CollectionID, StartTime,EndTime,Duration(mins)"
    $x = 0
    $count = $inputs.Count
    if($count -lt 1){
        $count = 1
    }
    Write-Host "Set Maintenance Window on Device Collection" -ForegroundColor Yellow
    foreach($input in $inputs){
        
        $collectionID = ""
        $CollectionName = $input.CollectionName
        [datetime]$MWStartTime = $input.MWStartTime
        [datetime]$MWEndtTime = $input.MWEndTime

        $x++
        $percent = "{0:N2}" -f ($x / $count * 100)
        Write-Progress -Activity "Set Maintenance Window on Device Collection" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $CollectionName 

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
         
    }

    #send email

    $subject = "Set Maintenance Window on Device Collection"
    $bodyAsHtml = "Hi, <br><br> Maintenance window has been set on Device Collections. <br> PFA file for more detail. <br><br> Thanks, <br>SCCM"

    Send-MailMessage -Attachments $outfile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHtml
    Write-Host "Done!! Set Maintenance Window on Device Collection `n`n" -ForegroundColor Yellow
}


################### STEP 2 - SET MAINTENANCE WINDOW END ###################



################### STEP 3 - CREATE STAGGER BEGIN ###################
Function Step3_CreateStagger{

    Function EmptyStagger{
        Param(
                [String]$stagger
        )        
        Write-Host "Empty Stagger: $stagger" -ForegroundColor DarkCyan -BackgroundColor Yellow
        $queries = Get-CMDeviceCollectionDirectMembershipRule -CollectionName $stagger
        $queryCount = $queries.count
        $queryX = 0
        
        foreach($query in $queries){
            $queryX++
            $queryProgress = "{0:N2}" -f ($queryX/$queryCount * 100)
            $rulename= $query.rulename
            Write-Progress -Activity "empty stagger '$stagger'" -Status "$queryX of $queryCount...$queryProgress%" -PercentComplete $queryProgress -CurrentOperation $rulename
            $query.rulename
            
            Remove-CMDeviceCollectionDirectMembershipRule -CollectionName $stagger -ResourceName $rulename -Force
        }
        
    }
    

    Function Stagger{
        Param(
                [String]$Environment,
                [String]$stagger1,
                [String]$stagger2,
                [String]$stagger3,
                [String]$stagger4,
                [String]$EarlyDeviceCollection,
                [String]$RegularDeviceCollection
        )        


        Write-Host "$Environment : Loading '$EarlyDeviceCollection' servers in variable" -ForegroundColor Yellow
        $EarlyServers = Get-CMDevice -CollectionName "$EarlyDeviceCollection" | select -ExpandProperty name
        Write-Host "$Environment : Loading '$RegularDeviceCollection' servers in variable" -ForegroundColor Yellow
        $RegularServers = Get-CMDevice -CollectionName "$RegularDeviceCollection"

        Write-Host "$Environment : Early server count is : $($EarlyServers.Count)"

        $count = $RegularServers.Count
        if($count -lt 1){
            $count = 1
        }




        #------------------------------ PRIORITIZING
        write-host "$Environment : Sorting priority customers...Please wait"
        $priority = @()
        $priority += "B17"
        $priority += "sch" # this inclused wae, wcc, scheem, schmon
        $priority += "BRI"
        $priority += "BCN"


        $RegularServers_NewSequence = @()
        $x = 0
        $count = $priority.Count
        Write-Host "$Environment : Regular server count is : $($RegularServers.Count)"
        foreach($p in $priority){
            $x++
            $percent = "{0:N2}" -f ($x/$count * 100)
        

            foreach($row in $RegularServers){
                Write-Progress -Activity "$Environment : Sorting Priority List: $p" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent
                $name = $row.name
                $ResourceID = $row.ResourceID
                if($name -match $p){
                    $RegularServers_NewSequence += "$name,$ResourceID"
                }
            }    
        }

        $x = 0
        $count = $RegularServers.Count
        Write-Host "$Environment : After sorting priority customers, new list count is : $($RegularServers_NewSequence.Count). Adding missing serves now...Please wait"
        foreach($row in $RegularServers){
            $x++
            $percent = "{0:N2}" -f ($x/$count * 100)
                Write-Progress -Activity "$Environment : Sorting Priority List" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

            $name = $row.name
            $ResourceID = $row.ResourceID
            if($RegularServers_NewSequence -notcontains "$name,$ResourceID"){
                $RegularServers_NewSequence += "$name,$ResourceID"
            }
        }
        Write-Host "$Environment : New list final count is: $($RegularServers_NewSequence.Count)"



        #------------------------------
        Write-Host "$Environment : Dividing Servers in 3 Groups" -ForegroundColor Yellow
        [int]$limit =  $count/3

        $Group1 = $EarlyServers# DO NOT TOUCH GROUP1. THIS CONTAINS EARLY REBOOT CUSTOMERS
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
        Write-Host "$Environment : Group1 = $($Group1.Count)"
        Write-Host "$Environment : Group2 = $($Group2.Count)"
        Write-Host "$Environment : Group3 = $($Group3.Count)"
        Write-Host "$Environment : Group4 = $($Group4.Count)"

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
        
                Write-Progress -Activity "$Environment : Collection '$collectionName': $computer" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent

                $computer = $row.split(",")[0]
                $ResourceId = $row.split(",")[1]
        
                if($ResourceId -eq $null){
                    Write-Host "$Environment : Computer not found - $computer" -ForegroundColor Yellow
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

        $Group1_Output = "$dir\Stagger_Group1_$Environment.txt"
        $Group2_Output = "$dir\Stagger_Group2_$Environment.txt"
        $Group3_Output = "$dir\Stagger_Group3_$Environment.txt"
        $Group4_Output = "$dir\Stagger_Group4_$Environment.txt"

        $Group1 | Out-File $Group1_Output
            $Group2Servers = @()
            foreach($g in $Group2){$Group2Servers += $g.Split(",")[0]}
        $Group2Servers | Out-File $Group2_Output
            $Group3Servers = @()
            foreach($g in $Group3){$Group3Servers += $g.Split(",")[0]}
        $Group3Servers | Out-File $Group3_Output
            $Group4Servers = @()
            foreach($g in $Group3){$Group4Servers += $g.Split(",")[0]}
        $Group4Servers | Out-File $Group4_Output



        $subject = "Maintenance Window - Create 4 Staggers in $Environment"
        $body = "
        Please refer attached files. <br>
        4 staggers. Stagger wise server count:<br>
        $stagger1 : $($Group1.Count) <br>
        $stagger2 : $($Group2.Count) <br>
        $stagger3 : $($Group3.Count) <br>
        $stagger4 : $($Group4.Count) <br>
        <br>
        These servers will be patched and rebooted.<br>

        "
        Send-MailMessage -To  $to -From $from -SmtpServer $smtp -Subject $subject -Attachments $Group1_Output,$Group2_Output,$Group3_Output,$Group4_Output
        #Remove-CMDeviceCollectionDirectMembershipRule
    
    }#Function StaggerNonProd

    

    $Environment = "NonProd"
    $stagger1 = "NON PROD STAGGER 1"
    $stagger2 = "NON PROD STAGGER 2"
    $stagger3 = "NON PROD STAGGER 3"
    $stagger4 = "NON PROD STAGGER 4"
    $EarlyDeviceCollection = "MW NON PROD EARLY SERVERS"
    $RegularDeviceCollection = "MW NON PROD REGULAR SERVERS"
    EmptyStagger -stagger $stagger2
    EmptyStagger -stagger $stagger3
    EmptyStagger -stagger $stagger4
    Stagger -Environment $Environment -stagger1 $stagger1 -stagger2 $stagger2 -stagger3 $stagger3 -stagger4 $stagger4 -EarlyDeviceCollection $EarlyDeviceCollection -RegularDeviceCollection $RegularDeviceCollection

    $Environment = "Prod"
    $stagger1 = "PROD STAGGER 1"
    $stagger2 = "PROD STAGGER 2"
    $stagger3 = "PROD STAGGER 3"
    $stagger4 = "PROD STAGGER 4"
    $EarlyDeviceCollection = "MW PROD EARLY SERVERS"
    $RegularDeviceCollection = "MW PROD REGULAR SERVERS"
    EmptyStagger -stagger $stagger2
    EmptyStagger -stagger $stagger3
    EmptyStagger -stagger $stagger4
    Stagger -Environment $Environment -stagger1 $stagger1 -stagger2 $stagger2 -stagger3 $stagger3 -stagger4 $stagger4 -EarlyDeviceCollection $EarlyDeviceCollection -RegularDeviceCollection $RegularDeviceCollection

}
################### STEP 3 - CREATE STAGGER END ###################



Function Step4_DeploySUG{
    
    $InputFile = "$dir\4_Input_SUG_Deployment.csv"
    $outFile = "$dir\4_Output_SUG_Deployment.csv"
    Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
    New-Item -ItemType File -Path $outFile | Out-Null
    Set-Content -Path $outFile -Value "DeploymentName,DeviceCollection,AvailableTime, DeadLineTime,Status"

    $lines = Import-Csv $InputFile
    $count = $lines.Count
    if($count -le 1){$count = 1}
    $x = 0
    foreach($line in $lines){
        $x++
        $percent = "{0:N2}" -f ($x/$count * 100)
        Write-Progress -Activity "Deploy Software Update Group" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $line


        try{

            $deviceCollection = $line.deviceCollection
            $DeploymentName = $line.DeploymentName
            $description = $line.description
            [DateTime]$DeploymentAvailable = $line.AvailableTime
            [DateTime]$DeploymentExpire = $line.DeadlineTime

            $SUGName = $line.SUGName
            $SoftwareUpdateGroupObj = Get-CMSoftwareUpdateGroup -Name $SUGName -ErrorVariable er1

            if($SoftwareUpdateGroupObj -eq $null){
                $errMessage = "Error: Invalid Software-Update-Group Name '$SUGName'. $($er1.Message)"
                Write-Host "$deploymentName : `t $errMessage" -ForegroundColor Yellow
                Add-Content -Path $outFile -Value "$deploymentName,$deviceCollection,$DeploymentAvailable,$DeploymentExpire,Failed: $errMessage"
                Continue;
            }
        


                Start-CMSoftwareUpdateDeployment `
                -InputObject $SoftwareUpdateGroupObj `
                -CollectionName $deviceCollection `
                -DeploymentName $DeploymentName `
                -Description $description `
                -DeploymentType Required `
                -SendWakeUpPacket $False `
                -VerbosityLevel AllMessages `
                -TimeBasedOn LocalTime `
                -DeploymentAvailableDay $DeploymentAvailable.ToShortDateString() `
                -DeploymentAvailableTime $DeploymentAvailable.ToShortTimeString() `
                -DeploymentExpireDay $DeploymentExpire.ToShortDateString() `
                -DeploymentExpireTime $DeploymentExpire.ToShortTimeString() `
                -UserNotification DisplaySoftwareCenterOnly `
                -SoftwareInstallation $False `
                -AllowRestart $False `
                -RestartServer $False `
                -RestartWorkstation $False `
                -PersistOnWriteFilterDevice $True `
                -GenerateSuccessAlert $True `
                -PercentSuccess 90 `
                -TimeValue 2 `
                -TimeUnit Days `
                -DisableOperationsManagerAlert $True `
                -GenerateOperationsManagerAlert $False `
                -ProtectedType RemoteDistributionPoint `
                -UnprotectedType UnprotectedDistributionPoint `
                -UseBranchCache $False `
                -DownloadFromMicrosoftUpdate $True `
                -AllowUseMeteredNetwork $True -ErrorVariable er -ErrorAction Stop

                Add-Content -Path $outFile -Value "$deploymentName,$deviceCollection,$DeploymentAvailable,$DeploymentExpire,Deployed"
                Write-Host "$deploymentName `t Done"
        }catch{


            $errMessage = "Error: SUG Deployment error. Check device-collection name or date/time format. $($er.Message)"
            Write-Host "$deploymentName : `t $errMessage" -ForegroundColor Yellow
            Add-Content -Path $outFile -Value "$deploymentName,$deviceCollection,$DeploymentAvailable,$DeploymentExpire,Failed: $errMessage"
        
    
        }


    }


    $sub = "Deploy Software Update Group"
    $body = "PFA report"
    Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer $smtp -Subject $sub -BodyAsHtml $body


}



#Step1_AddPatchesToSUG
Step2_SetMaintenanceWindow
#Step3_CreateStagger
Step4_DeploySUG