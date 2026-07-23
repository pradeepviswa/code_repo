#store credential


$servers = Get-Content 'E:\AdminTools\SCCM_Script\SCCM_Install_Script\2_GPUpdate\List.txt'
$count = $servers.count
$x = 0
foreach($server in $servers){
    $percent = "{0:N2}" -f (($x/$count * 100))
    Write-Progress -Activity "GPUpdate" -Status "$x of $count..$percent%" -PercentComplete $percent -CurrentOperation $server

    #Invoke-GPUpdate -Computer $server -Force -AsJob
    Start-Process -FilePath "PSExec.exe" -ArgumentList "\\$server gpupdate /force"
    #PSExec.exe \\$server gpupdate /force
    

    $x++
}
