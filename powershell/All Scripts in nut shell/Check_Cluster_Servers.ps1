$servers = Get-Content E:\AdminTools\Scheduled_Tasks\Results\All_Relevant_Computer_Objects.txt

#create file
$fpath = "C:\Temp\Pradeep\ClusterServer.csv"
Remove-Item -Path $fpath -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType File -Path $fpath
Set-Content -Path $fpath -Value "SNo,Server,Cluster_Yes_No"
$x = 0
Write-Host "ServerCount: $($servers.Count)"

foreach($server in $servers){
$x++
    try{
        $cluster = Get-WmiObject -Class win32_service -ComputerName $server -ErrorAction Stop | where {$_.name -eq 'ClusSvc'} | select *
        if($cluster.state -eq 'Running'){
            Add-Content -Path $fpath -Value "$x,$server,Yes"
            Write-Host "$x. $server  Yes"
        }else{
            Add-Content -Path $fpath -Value "$x,$server,No"
            Write-Host "$x. $server  No"
        }


    }catch{
            Add-Content -Path $fpath -Value "$x,$server,Error"
            Write-Host "$x. $server  Error" -ForegroundColor Red

    }
}

C:\Temp\Pradeep\ClusterServer.csv
