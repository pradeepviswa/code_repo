#Import-Module ConfigurationManager
Set-Location csn:
Write-Host "Please wait... Loading Deivice information" -ForegroundColor Yellow
$devices = Get-CMDevice
Write-Host "Information Loaded" -ForegroundColor Yellow

$servers = Get-Content "E:\AdminTools\SCCM_Script\11_Get-Device_NameAndDomain_from_SCCM\Servers.txt"
$outfile = "E:\AdminTools\SCCM_Script\11_Get-Device_NameAndDomain_from_SCCM\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue -Force
New-Item -ItemType fi -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,Domain,FQDN"

foreach($server in $servers){
    $obj = $devices | where {$_.name -eq $server} | select name,domain
    $domain = $obj.domain
    if($obj.Name -eq $null){
        Write-Host "$server `t Not in SCCM"
        Add-Content -Path $outfile -Value "$server,Not in SCCM"
    
    }else{
        $dcServer = Get-ADComputer -Server $domain -Identity $server
        $fqdn = $dcServer.dnsHostName
        Write-Host "$server `t $domain `t $fqdn"
        Add-Content -Path $outfile -Value "$server,$domain,$fqdn"
    
    }
    
}

Send-MailMessage -Attachments $outfile -To "pradeep.viswanathan@cognizant.com" -From "sccm@trizetto.com" -SmtpServer "mail-2.trizetto.net" -Subject "Domain name extracted from SCCM" -Body "PFA file"

