
$dir = Split-Path $Script:Myinvocation.mycommand.path

Set-Location -Path $dir

$outfile = ".\Output.csv"

Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,Domain,Operating-System"

$domains = Get-Content ".\Input.txt"

$validServers = @()

foreach($domain in $domains){
    $server = @()
    $servers = Get-ADComputer -Server $domain -Filter * -Properties * | 
        Where-Object -FilterScript {
            (
                ($_.Enabled) -and 
                ($_.DnsHostName -notmatch "CLUS") -and
                ($_.DnsHostName -notmatch "nas")
            ) -and
            (
                ($_.DnsHostName -match "csn-") -or
                ($_.DnsHostName -match "CSN-") -or
                ($_.DnsHostName -match "abn-") -or
                ($_.DnsHostName -match "abn-")
            )
        } | select name,dnshostname,operatingsystem



    
    $output = "$domain `t $($servers.count)"
    Write-Host "`t $output - OS check in progress..."
    foreach($server in $servers){
        #"$($server.name) `t $domain `t $($server.OperatingSystem)"
        Add-Content -Path $outfile -Value "$($server.name),$domain,$($server.OperatingSystem)"
    }

}

Send-MailMessage -Attachments $outfile -To 'CISTZInfraWindowsOperations@cognizant.com' -From 'SCCM@trizetto.com' -Body "PFA sever list" -SmtpServer 'mail-2.trizetto.net' -Subject "Server OS Detail"

