#
# Press 'F5' to run this script. Running this script will load the ConfigurationManager
# module for Windows PowerShell and will connect to the site.
#
# This script was auto-generated at '5/2/2018 11:19:55 PM'.

# Uncomment the line below if running in an environment where script signing is 
# required.
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

$dir = Split-Path $Script:Myinvocation.mycommand.path
$patches = Get-Content "$dir\Input-PatchReport.txt"
$outfile = "$dir\Output-PatchReport.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "BulletinID,ArticleID,PatchRequiredOn,PercentCompliant,Size,LocalizedDisplayName"
$count = $patches.count
$x = 0
foreach($patch in $patches){
    $patch = $patch.Trim()
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Patch Report" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $patch
    if($patch -match "MS"){
        $objs = Get-CMSoftwareUpdate -BulletinId $patch -Fast
    }else{
        $patch = $patch.replace("KB","")
        $objs = Get-CMSoftwareUpdate -ArticleId $patch -Fast
    }
    #$objs = Get-CMSoftwareUpdate -Fast | where { $_.ArticleId -eq  $patch }
    foreach($obj in $objs){
        $BulletinID = $obj.BulletinID
        $ArticleID = $obj.ArticleID
        $NumMissing = $obj.NumMissing
        $PercentCompliant = $obj.PercentCompliant
        $Size = $obj.Size
        $LocalizedDisplayName = $obj.LocalizedDisplayName 
        if($NumMissing -gt 0 ){
            Write-Host "$ArticleID `t $PercentCompliant% `t $Size"
            Add-Content -Path $outfile -Value "$BulletinID,$ArticleID,$NumMissing,$PercentCompliant,$Size,$LocalizedDisplayName"
        }
    }
}

