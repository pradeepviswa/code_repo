Set-Location "E:\AdminTools\Pradeep\DNS-CheckRecord" -ErrorAction SilentlyContinue

$servers = Get-Content ".\Input.txt"
$output = ".\Output.csv"
Set-Content -Path $output -Value "Name,IP"

$count = $servers.Count
$x = 0

foreach($server in $servers){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Check Decom Servers" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server


    $name = $server.Split(".")[0]
    $zone = "$($server.Split(".")[1]).$($server.Split(".")[2]).$($server.Split(".")[3])"
    $computer = $zone
    
        
    $record = Get-DnsServerResourceRecord -Name $name -RRType A -ZoneName $zone -ComputerName $computer -ErrorAction SilentlyContinue
    if($record -eq $null){
        Write-Host "$server `t Decom" -ForegroundColor Yellow
        Add-Content -Path $output -Value "$server,Decom"

    }else{
        $ip = ""
        $ip = $record.RecordData.IPv4Address.IPAddressToString
        Write-Host "$server `t $ip"
        Add-Content -Path $output -Value "$server,$ip"
    
    }
    
    $x++
}


