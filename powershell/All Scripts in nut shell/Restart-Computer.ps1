$servers = Get-Content E:\AdminTools\Pradeep\Restart-Computer\Servers.txt
$count = $servers.Count
$x = 0
foreach($server in $servers){
    $percent = "{0:N2}" -f (($x/$count)*100)
    Write-Progress -Activity "Reboot" `
        -Status "Progress ($x of $count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation $server

    if(Test-Connection $server -Count 1 -Quiet){
        Restart-Computer -ComputerName $server -Force -AsJob
        
      
    }else{
        Write-Host "$server" -ForegroundColor Red
    }

    $x++
}