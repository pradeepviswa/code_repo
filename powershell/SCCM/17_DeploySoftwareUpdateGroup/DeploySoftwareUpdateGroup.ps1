import-module (Join-Path $(Split-Path $env:SMS_ADMIN_UI_PATH) ConfigurationManager.psd1)
$SiteCode=Get-PSDrive -PSProvider CMSITE
cd ((Get-PSDrive -PSProvider CMSite).Name + ':')

$basePath = "E:\AdminTools\SCCM_Script\17_DeploySoftwareUpdateGroup"
$InputFile = "$basePath\Input-SUG_Deployment.csv"
$outFile = "$basePath\Output-SUG_Deployment.csv"
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


$to = "pradeep.viswanathan@cognizant.com"
$from = "automated-script@trizetto.com"
$smtp = "mail-2.trizetto.net"
$sub = "Deploy Software Update Group"
$body = "PFA report"
Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer $smtp -Subject $sub -BodyAsHtml $body

