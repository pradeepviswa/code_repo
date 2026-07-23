Import-Module ConfigurationManager
Set-Location csn:

#output file settings
$outpath = "E:\AdminTools\SCCM_Script\5_Download_Patches\Output.csv"
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "BulletinID,ArticleID,LocalizedDisplayName,Status"

#import values from txt file
$patches = Get-Content E:\AdminTools\SCCM_Script\5_Download_Patches\Patches.txt


#for loop to download each patch
Write-Host "In progress" -ForegroundColor Yellow
$x=0
$count = $patches.Count

foreach($patch in $patches){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Patch Download" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $patch
    #variables
    $output = ""

    #remove KB string from patch
    if($patch -match "kb"){
        $patch = $patch.Replace("KB","")
        $patch = $patch.Replace("kb","")
    }

    #get patch software updaet ID
    $softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}

    #download each path
    $req = 0
    foreach($softwareUpdate in $softwareUpdates){
    
            <#
            if( ( $softwareUpdate.LocalizedDisplayName -notmatch "itanium") -and 
                ( ($softwareUpdate.LocalizedDisplayName -match "server") -or 
                    ($softwareUpdate.LocalizedDisplayName -match "Windows 7") -or
                    ($softwareUpdate.LocalizedDisplayName -match "Windows 8") -or 
                    ($softwareUpdate.LocalizedDisplayName -match "Windows 10") ) -and 
                ( $softwareUpdate.nummissing -ne 0 )
            )
            #>
            if(( $softwareUpdate.nummissing -ne 0 ) -or ( $softwareUpdate.nummissing -eq 0 )){
                
                $LocalizedDisplayName = $softwareUpdate.LocalizedDisplayName
                #get software update ID
                $SoftwareUpdateId = $softwareUpdate.CI_ID

                #download patch
                Invoke-CMSoftwareUpdateDownload `
                    -SoftwareUpdateId $SoftwareUpdateId `
                    -DeploymentPackageName "Package-VAScan"
                    #"Package-VAScan"
                    #"Package-Nov-2017"

                $BulletinID = $softwareUpdate.BulletinID
                $ArticleID = $softwareUpdate.ArticleID

                Write-Host "'$BulletinID' `t '$ArticleID' `t $LocalizedDisplayName `t Downloaded"
                $output = "$BulletinID,$ArticleID,$LocalizedDisplayName,Downloaded"
                Add-Content -Path $outpath -Value $output

                $req++
            }#if
           
        }#foreach softwareUpdates
        
    if($softwareUpdates.count -lt 1){
                Write-Host "$patch Not found" -ForegroundColor Red
                $output = "$patch,Not Found"
                Add-Content -Path $outpath -Value $output
    
    }elseif( $req -eq 0){
                Write-Host "$patch Not Required" -ForegroundColor Red
                $output = "$patch,Not Required"
                Add-Content -Path $outpath -Value $output
    }
    $x++
}#foreach patches

    