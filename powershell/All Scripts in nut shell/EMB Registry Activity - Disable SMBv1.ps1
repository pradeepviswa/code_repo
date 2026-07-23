$myDir = split-path $Script:MyInvocation.mycommand.path
Set-Location $myDir
$servers = Get-Content .\1.txt
$servers = $servers | select -Unique
$custDomain = "emb.tzghosting.net"
$excludedGroupName = "Disable SMBv1"
$count = $servers.count
$x = 0
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    #$server = $server.Split(".")[0]
    Write-Progress -Activity "Add Computer Object to '$server'" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    Write-Host $server
    $compObj = Get-ADComputer -Server $custDomain -Filter "dnshostname -eq '$server'"
    #$compObj
    Add-ADGroupMember -Identity $excludedGroupName -Members $compObj -Server $custDomain
}

Write-Host "Done" -ForegroundColor Yellow





#>