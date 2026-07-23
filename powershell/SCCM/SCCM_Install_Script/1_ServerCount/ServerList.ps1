<#
    1. Add domain name in E:\AdminTools\SCCM_Script\SCCM_Install_Script\1_ServerCount\Input.txt
    2. Execute Script
    3. Email will  be sent with server count
#>
Set-Location "E:\AdminTools\SCCM_Script\SCCM_Install_Script\1_ServerCount" -ErrorAction SilentlyContinue

$outfile = ".\Output.txt"


$domains = Get-Content ".\Input.txt"

$validServers = @()

foreach($domain in $domains){
    $server = @()
    $servers = Get-ADComputer -Server $domain -Filter * | 
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
        }


    $server = $servers.DnsHostName


    #remove decom servers
    $decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"
    $DomainServer = @()
    foreach($s in $server){
        if($decomServers -notcontains $s){
            $validServers += $s
            $DomainServer += $s
        }
    }
    $output = "$domain `t $($DomainServer.count)"
    Write-Host $output

}
    $validServers | Out-File $outfile


Send-MailMessage -Attachments $outfile -To 'pradeep.viswanathan@cognizant.com','Abhijeet.Joshi5@cognizant.com' -From 'SCCM@trizetto.com' -Body "PFA sever list" -SmtpServer 'mail-2.trizetto.net' -Subject "Server Count"


#Write-Host "Email sent" -ForegroundColor Yellow
notepad $outfile