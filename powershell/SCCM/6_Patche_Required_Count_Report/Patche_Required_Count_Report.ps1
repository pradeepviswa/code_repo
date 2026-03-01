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

#output file settings
$dir = Split-Path $Script:MyInvocation.Mycommand.Path

$outpath = "$dir\Output.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "kb, title, date, total, Installed, missing, notApplicable, unKnown, PercentCompliant, bulletinID, Downloaded, Deployed, Superseded, URL, Size"



#import values from csv file
$lines = Get-Content "$dir\Input-Patches.txt"

#for loop to add each patch in SUG
Write-Host "In progress" -ForegroundColor Yellow

$count = $lines.Count
$x = 0
foreach($line in $lines){

    #variables
    $output = ""
    $patch = $line.trim()

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Patch Required Count" `
        -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "$patch" 


    #remove KB string from patch
    if($patch -match "kb"){
        $patch = $patch.Replace("KB","")
        $patch = $patch.Replace("kb","")
    }

    #get patch software updaet ID
    $softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}

    #add each Software Update ID in SUG
    $kb = ""
    $title = ""
    $date = ""
    $total = ""
    $Installed = ""
    $missing = ""
    $notApplicable = ""
    $unKnown = ""
    $PercentCompliant = ""
    $BulletinID = ""
    $Downloaded = ""
    $Deployed = ""
    $Superseded = ""
    $URL = ""
    $Size = ""
    $req = 0
    foreach($softwareUpdate in $softwareUpdates){
            if(( $softwareUpdate.nummissing -ne 0 ) -or ( $softwareUpdate.nummissing -eq 0 )){
                #get software update ID
                $SoftwareUpdateId = $softwareUpdate.CI_ID

                #store each output value in variable
                $kb = $softwareUpdate.ArticleID
                $title = $softwareUpdate.LocalizedDisplayName
                $date = $softwareUpdate.DateLastModified
                $total = $softwareUpdate.NumTotal
                $Installed = $softwareUpdate.NumPresent
                $missing = $softwareUpdate.NumMissing
                $notApplicable = $softwareUpdate.NumNotApplicable
                $unKnown = $softwareUpdate.NumUnknown
                $PercentCompliant = $softwareUpdate.PercentCompliant
                $BulletinID = $softwareUpdate.BulletinID
                $Downloaded = $softwareUpdate.IsDeployable
                $Deployed = $softwareUpdate.IsDeployed
                $Superseded = $softwareUpdate.IsSuperseded
                $URL = $softwareUpdate.LocalizedInformativeURL
                $Size = $softwareUpdate.Size

                #convertign TRUE/FALSE to YES/NO 
                if($Downloaded){ $Downloaded = "Yes" }else{ $Downloaded = "No"}
                if($Deployed){ $Deployed = "Yes" }else{ $Deployed = "No"}
                if($Superseded){ $Superseded = "Yes" }else{ $Superseded = "No"}

                #in $title replace ',' with '-'
                $title = $title.Replace(",","-")

                Write-Host "'$kb' `t Required $missing"
                $output = "$kb, $title, $date, $total, $Installed, $missing, $notApplicable, $unKnown, $PercentCompliant, $bulletinID, $Downloaded, $Deployed, $Superseded, $URL, $Size"
                Add-Content -Path $outpath -Value $output

                $req++
            }#if
            
     
        }#foreach softwareUpdates
        
        if($softwareUpdates.count -lt 1){
                    Write-Host "$patch Not found in SCCM" -ForegroundColor Red
                    $output = "$patch,Not found in SCCM"
                    Add-Content -Path $outpath -Value $output
    
        }elseif( $req -eq 0){
                    Write-Host "$patch Not Required" -ForegroundColor Red
                    $output = "$patch,Not Required"
                    Add-Content -Path $outpath -Value $output
        }

        $x++
}#foreach patches


 