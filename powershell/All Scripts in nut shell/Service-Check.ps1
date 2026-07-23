$service_Name = "CcmExec"
$dir = Split-Path $Script:Myinvocation.Mycommand.path
Set-Location -Path $dir -ErrorAction SilentlyContinue
$servers = Get-Content .\Input-Servers.txt
$outFile = ".\Output-ServiceCheck.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile "Server,ServiceName,Present(Yes/No)"
$count = $servers.Count
$x = 1
Write-Host "Looking for service: $service_Name" -ForegroundColor Yellow
foreach($server in $servers){
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Check Service" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    try{
        $service = Get-Service -ComputerName $server -Name *$service_Name* -ErrorAction Stop
        if($service.count -eq 0){
            Write-Host "$server `t Missing" -ForegroundColor DarkGray
            Add-Content -Path $outFile -Value "$server,$service_Name,No"
        }else{
            Write-Host "$server `t Present" -ForegroundColor Cyan
            Add-Content -Path $outFile -Value "$server,$service_Name,Yes"
        }
    }catch{
        Write-Host "$server `t Connection-Error" -ForegroundColor Red
        Add-Content -Path $outFile -Value "$server,$service_Name,Connection-Error"
    
    }

    $x++
}
