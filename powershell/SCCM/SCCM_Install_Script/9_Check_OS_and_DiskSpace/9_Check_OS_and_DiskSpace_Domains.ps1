$outpath = ".\Output.csv"
$domains = Get-Content ".\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"


#add output file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,OS,C: Size, C: Free Space, Free Percent"

#add server names in $SERVERS variable 
$servers = @()
Write-Host "Fetching server names from domains..." -ForegroundColor Yellow
foreach($domain in $domains){
    $domain = $domain.Trim()
    $DomainServers = Get-ADComputer -Server $domain -Filter * | Where-Object -FilterScript {$_.Enabled} | select -ExpandProperty DnsHostName
    $output = "$domain `t $($DomainServers.count)"
    $servers += $DomainServers
    Write-Host $output
}

$count = $servers.Count
$x = 0


Write-Host "Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Installing SCCM Client" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if(Test-Connection $server -Count 1 -Quiet){
        
        
        try{
                $os = Invoke-Command -Authentication Negotiate -ComputerName $server -ScriptBlock{
                    Get-WmiObject -Class Win32_OperatingSystem | select caption
                } -ErrorAction Stop | select -ExpandProperty caption
                $os = $os.Replace(",","")

                $disk = Invoke-Command -Authentication Negotiate -ComputerName $server -ScriptBlock{
                    Get-WmiObject -Class Win32_LogicalDisk -Filter {deviceID = 'c:'}
                } -ErrorAction Stop 
                
                $size = "{0:N2}" -f ($disk.Size/1GB)
                $free = "{0:N2}" -f ($disk.FreeSpace/1GB)
                $perc = "{0:N2}" -f ($free/$size * 100)

                Write-Host "$server `t $os `t $perc% Free"                    
                Add-Content -Path $outpath -Value "$server,$os,$size,$free,$perc%"


         }catch{
            Write-Host "$server `t Failed" -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Failed"
        }

        
    }else{
        if($decomServers -contains $server){
            Write-Host "$server `t Decom" -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Decom"
        }else{
            Write-Host "$server `t Ping Failed" -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Ping Failed"
        }
    }
    $x++
}

Send-MailMessage -Attachments $outpath -To 'hs-sysadmin-windows-offshore@trizetto.com' -From 'SCCM@trizetto.com' -Subject "Machine OS and C drive space detail" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA Report"
#Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM Client Instalaltion Report on domain"
