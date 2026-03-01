# Modify here
$searchGroup = "TZG SCCM Certificate Authentication"
#---------------------------------------

Write-Host "Searching group: '$searchGroup'" -ForegroundColor Yellow
$domains = Get-Content E:\AdminTools\SCCM_Script\SCCM_Install_Script\5_Check-Group\Domains.txt
$count = $domains.Count
$x = 0
$missing = @()
foreach($domain in $domains){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Searching for $searchGroup" `
        -Status "Progress ($x of$count)...$percent$" `
        -PercentComplete $percent `
        -CurrentOperation $domain

    
    try{
        Get-ADGroup -Server $domain -Identity $searchGroup -ErrorAction stop | Out-Null
        
    }catch{
        Write-Host "Not found in $domain" -ForegroundColor Red
        $missing += $domain
    }
    $x++
}
$missing | Out-File "E:\AdminTools\SCCM_Script\SCCM_Install_Script\5_Check-Group\Output-MissingDomains.txt"
Write-Host "Done" -ForegroundColor Yellow