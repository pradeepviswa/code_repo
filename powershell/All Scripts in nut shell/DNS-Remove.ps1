Set-Location "E:\AdminTools\Pradeep\DNS-Remove" -ErrorAction SilentlyContinue

$servers = Import-Csv ".\Input.csv"
$output = ".\Output.csv"
Set-Content -Path $output -Value "Input,Name,Zone,Domain,Status"

foreach($line in $servers){
    #$server = "csn-svc-tid-03.services.tzghosting.net"
    $server = $line.server
    $ip = $line.IP
    $name = $server.Split(".")[0]
    $zone = "$($server.Split(".")[1]).$($server.Split(".")[2]).$($server.Split(".")[3])"
    $ComputerName = $zone
    
    try{
        
        
        Remove-DnsServerResourceRecord `
            -ZoneName $zone `
            -Name $name `
            -RRType A `
            -RecordData $ip `
            -ComputerName $ComputerName `
            -Force `
            -ErrorAction Stop
        
        
            Add-Content -Path $output -Value "$server,$name,$zone,$ComputerName,Removed"
            Write-Host "$server `t Removed"
    }catch{
            Add-Content -Path $output -Value "$server,$name,$zone,$ComputerName,Record not found"
            Write-Host "$server `t Record not found" -ForegroundColor Yellow
        
    }
    

}


