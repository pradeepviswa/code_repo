Import-Module configurationmanager
Set-Location -Path CSN:

$dir = Split-Path $Script:Myinvocation.Mycommand.path
$InputPatches = Get-Content -Path "$dir\Input-CheckPatches.txt"
$outFile = "$dir\Output-CheckedPatches.csv"

Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "BulletinID,ArticleID,Present or Missing,SUG Name,Detail"

$SUGname = "SUG-May-2018"
#$SUGname = "SUG_DeviceCollection_Patch5"

write-host "Please wait... Collecting list of patches in SUG '$SUGname'"
$updates = Get-CMSoftwareUpdateGroup |
    Where-Object -FilterScript {$_.LocalizedDisplayName -eq $SUGname} |
    select -ExpandProperty SDMPackageXML

$count = $InputPatches.Count
$x = 1
foreach($InputPatch in $InputPatches){
    $InputPatch = $InputPatch.Replace("KB","")
    $InputPatch = $InputPatch.Replace("kb","")

    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Check Patch '$InputPatch' in $SUGname" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $InputPatch
    $patchFound = 0
    $patchPresent = 0
    #get patch software updaet ID
    $softwareUpdates = Get-CMSoftwareUpdate -Fast | where {($_.ArticleID -eq $InputPatch) -or ($_.BulletinID -eq $InputPatch)}
    $BulletinID = ""
    $ArticleID = ""
    $detail = ""
    $reqCount = 0
    foreach($softwareUpdate in $softwareUpdates){
        $patchFound++
        $BulletinID = $softwareUpdate.BulletinID
        $ArticleID = $softwareUpdate.ArticleID

        $CI_UniqueID = $softwareUpdate.CI_UniqueID
        #$det= $softwareUpdate.LocalizedCategoryInstanceNames
        #$detail = "$($det[0]) - $($det[1])"
        $detail = $softwareUpdate.LocalizedDisplayName
        
        $reqCount = $softwareUpdate.nummissing

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
        Write-Host "'$InputPatch' `t Not found in SCCM" -ForegroundColor Yellow 
        Add-Content -Path $outFile -Value "$InputPatch,$InputPatch,Not found in SCCM,NA,NA"
    }elseif($patchPresent -eq 0){
        Write-Host "'$InputPatch' `t '$InputPatch' `t Missing in $SUGname. Required count is $reqCount" -ForegroundColor Yellow
        Add-Content -Path $outFile -Value "$InputPatch,$InputPatch,Missing. Required count is $reqCount,$SUGname,$detail"
    }

    $x++
}#foreach InputPatches




