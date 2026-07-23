$decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"
$servers = Get-Content "E:\AdminTools\Pradeep\Check-Decom\Servers.txt"
$outFile = "E:\AdminTools\Pradeep\Check-Decom\Output_DecomServers.txt"

Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null


foreach($server in $servers){
    $server = $server.Trim()
    if($decomServers -contains $server){
        Write-Host "$server `t Decom" -ForegroundColor Red
        Add-Content -Path $outFile -Value "$server"
    }
}

notepad $outFile