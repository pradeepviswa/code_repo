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
$outpath = "$dir\Output-Add patches to SUG NO DOWNLOAD.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "BulletinID,ArticleID,SUGName,Status"


#import values from csv file
$lines = Import-Csv -Path "$dir\Patches.csv"

#for loop to add each patch in SUG
Write-Host "In progress" -ForegroundColor Yellow
$count =0
if(!($lines.Count)){$count = 1}
else{$count = $lines.Count}
$x = 1

foreach($line in $lines){

    #variables
    $output = ""
    $patch = $line.patch
    $SUGName = $line.SUGName

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Add patches to SUG" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "$patch to $SUGName" 


    #remove KB string from patch
    if($patch -match "kb"){
        $patch = $patch.Replace("KB","")
        $patch = $patch.Replace("kb","")
    }

    #get patch software updaet ID
    $softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}
    
    #add each Software Update ID in SUG
    $req = 0
    foreach($softwareUpdate in $softwareUpdates){
            if( $softwareUpdate.nummissing -ne 0 ){
                #get software update ID
                $SoftwareUpdateId = $softwareUpdate.CI_ID


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

                    Write-Host "'$BulletinID' `t '$ArticleID' `t Added to '$SUGName'"
                    $output = "$BulletinID,$ArticleID,$SUGName,Added"
                    Add-Content -Path $outpath -Value $output
                }else{
                    #download patch
                    Write-Host "Download Pending `t '$BulletinID' `t '$ArticleID'"
                    $output = "$BulletinID,$ArticleID,$SUGName,Download Pending"
                    Add-Content -Path $outpath -Value $output

                
                }


                $req++
            }#if
            
     
        }#foreach softwareUpdates
        
        if($softwareUpdates.count -lt 1){
                    Write-Host "$patch Not found" -ForegroundColor Red
                    $output = "$patch,Not Found"
                    Add-Content -Path $outpath -Value $output
    
        }elseif( $req -eq 0){
                    Write-Host "$patch Not Required" -ForegroundColor yellow
                    $output = "$patch,Not Required"
                    #Add-Content -Path $outpath -Value $output




        }

        $x++
}#foreach patches


 