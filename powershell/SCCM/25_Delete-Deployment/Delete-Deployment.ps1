#Add_Patches_to_SUG_NO_DOWNLOAD
#Set-ExecutionPolicy Bypass

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

#output file settings
$dir = Split-Path $Script:Myinvocation.Mycommand.path
$outpath = "$dir\Output-Delete Deployment.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Deployment Name,Delete Status"



$deployments = Get-Content "$dir\Input.txt"
$count = $deployments.Count
$x = 0
foreach($deployment in $deployments){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Delete Deployment" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $deployment
    $flag = Get-CMSoftwareUpdateDeployment | Where-Object -FilterScript {$_.AssignmentName -eq $deployment}
    if( ($flag.count -eq 0) -or ($flag -eq $null) ){
        Write-Host "'$deployment' `t Not Found" -ForegroundColor Yellow
        Add-Content -path $outpath -value "$deployment,Not Found"
    }else{
        $fgColor = "White"
        if($flag.Count -gt 1){
            $fgColor = "grey"
        }
        foreach($row in $flag){
            Remove-CMSoftwareUpdateDeployment -InputObject $row -Force
            Write-Host "'$deployment' `t Removed" -ForegroundColor $fgColor
            Add-Content -path $outpath "$deployment,Removed"
        }
    }
}#foreach deployments




