Import-Module configurationmanager
Set-Location -Path CSN:

#$InputPatches = Get-Content -Path "E:\AdminTools\SCCM_Script\16_Check_Patches_in_SUG\Input-CheckPatches.txt"
$InputPatches = Import-Csv "E:\AdminTools\SCCM_Script\16_Check_Patches_in_SUG\Custom\Input-CheckPatches.csv"
$inputSUGs = $InputPatches.SUGName | select -Unique
$outFile = "E:\AdminTools\SCCM_Script\16_Check_Patches_in_SUG\Output-CheckedPatches.csv"

Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "BulletinID,ArticleID,Present or Missing,SUG Name,Detail"

#$SUGname = "SUG-Nov-2017"

$count = $inputSUGs.Count
$x = 1
foreach($InputPatch in $inputSUGs){
    
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Check Patch in $SUGname" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $InputPatch

    $SUGname = $InputPatch

    write-host "Please wait... Collecting list of patches in SUG '$SUGname'"
    $updates = Get-CMSoftwareUpdateGroup |
        Where-Object -FilterScript {$_.LocalizedDisplayName -eq $SUGname} |
        select -ExpandProperty SDMPackageXML


    $patches = $InputPatches | where {$_.SUGName -eq $SUGname} | select -ExpandProperty Patch_name
    foreach($patch in $patches){




        $patchFound = 0
        $patchPresent = 0
        #get patch software updaet ID
        $softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $patch) -or ($_.BulletinID -eq $patch)}
    
        foreach($softwareUpdate in $softwareUpdates){
            $patchFound++
            $BulletinID = $softwareUpdate.BulletinID
            $ArticleID = $softwareUpdate.ArticleID

            $CI_UniqueID = $softwareUpdate.CI_UniqueID
            $det= $softwareUpdate.LocalizedCategoryInstanceNames
            $detail = "$($det[0]) - $($det[1])"
        

            if($updates -match $CI_UniqueID){
                $patchPresent++
                Write-Host "'$BulletinID' `t '$ArticleID' `t Present in $SUGname"  
                Add-Content -Path $outFile -Value "$BulletinID,$ArticleID,Present,$SUGname,$detail"
                break;  
            }else{
                #Write-Host "'$BulletinID' `t '$ArticleID' `t Missing in $SUGname" -ForegroundColor Yellow
                #Add-Content -Path $outFile -Value "$BulletinID,$ArticleID,Missing,$SUGname,$detail"
            }

        
        }#foreach softwareupdate
        if($patchFound -eq 0){
            Write-Host "'$patch' `t Not found in SCCM" -ForegroundColor Yellow 
            Add-Content -Path $outFile -Value "$patch,NA,Not found in SCCM,NA,NA"
        }
        if($patchPresent -eq 0){
            Write-Host "'$BulletinID' `t '$ArticleID' `t Missing in $SUGname" -ForegroundColor Yellow
            Add-Content -Path $outFile -Value "$BulletinID,$ArticleID,Missing,$SUGname,$detail"
        }








    
    }

    $x++
}#foreach InputPatches




