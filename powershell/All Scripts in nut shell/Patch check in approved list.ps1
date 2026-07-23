Set-Location -Path  "E:\AdminTools\Pradeep\Patch Check in Approved List" -ErrorAction SilentlyContinue
$approvedPatches= Get-Content .\Intput-ApprovedPatches.txt
$checkThesePatches = Get-Content .\Input-CheckThesePatches.txt
    $patchFound = @()
    $patchNotFound = @()
    $count = $checkThesePatches.Count
    $x = 1
foreach($checkpatch in $checkThesePatches){
    $checkpatch = $checkpatch.Replace("KB","")
    $percent = "{0:N2}" -f ($x/$count * 100)
    

    $y = 0
    
    foreach($approvedPatch in $approvedPatches){
        Write-Progress -Activity "Comparing $checkpatch with $approvedPatch" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent
        
        if($approvedPatch -match $checkpatch){

            $y++
            $patchFound += $checkpatch
            Write-Host "Found: $checkpatch"
            break;
        }#if
    }#foreach approvedPatches

    if($y -eq 0 ){
        $patchNotFound += $checkpatch
        Write-Host "Not Found: $checkpatch" -ForegroundColor Yellow
    }

    $x++
}#foreach checkThesePatches

$patchNotFound | Out-File .\Output-PatchNotFound.txt
$patchFound | Out-File .\Output-PatchFound.txt
notepad .\Output-PatchFound.txt
notepad .\Output-PatchNotFound.txt