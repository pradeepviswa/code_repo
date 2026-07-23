$dir = Split-Path $Script:MyInvocation.MyCommand.path
Set-Location $dir
$servers = Get-Content ".\servers.txt"
$outFile = ".\Output2.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "FQDN,IP"
$count = $servers.Count
$x = 1
$ServerFQDN = @()


foreach($server in $servers){

    $x++
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "FQDN to IP" -Status "$x of $count .. $percent%" -PercentComplete $percent -CurrentOperation $server
    $a = ""
    $IP = ""
    if(Test-Connection -ComputerName $server -Count 1 -Quiet){
        $a = Test-Connection $server -Count 1 -ErrorAction Stop -ErrorVariable er
        $IP = $a.IPV4Address.IPAddressToString
        Add-Content -Path $outFile -Value "$server,$IP"
        #Write-Host "$server `t $IP"

    }else{
        Add-Content -Path $outFile -Value "$server,Error"
        Write-Host "$server `t Error" -ForegroundColor Yellow
    
    }
}

