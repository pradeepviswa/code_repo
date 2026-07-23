###########################
$dir = Split-Path $Script:Myinvocation.mycommand.path
$outpath = "E:\AdminTools\SCCM_Script\SCCM_Install_Script\3_Install_SCCM_Client\SCCMInstall.csv"
$sccmClientInstaller = ".\Client"
###########################

Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status"

$servers = Get-Content "E:\AdminTools\SCCM_Script\SCCM_Install_Script\3_Install_SCCM_Client\Servers.txt"
$count = $servers.Count
$x = 0

$failedServers = @()
$validServers = @()
Write-Host "Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Uninstall SCCM Client" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    if( Test-Connection $server -Count 1 -Quiet){
        $dest = ""
        try{

                $s = $server
                
                Start-Process -FilePath "psexec.exe" -ArgumentList " -accepteula \\$server cmd /c c:\Temp\client\ccmsetup.exe /UsePKICert CCMFIRSTCERT=1 SMSSITECODE=CSN SMSMP=https://csn-svc-sccm-01.services.tzghosting.net"
                
                Write-Host "$server `t Install Triggered"
                $outValue = "$server,Install Triggered" 
                Add-Content -Path $outpath -Value $outValue
                
                

                $validServers += $server

        }catch{
            $failedServers += $server
            Write-Host "`t $server `t Failed"
            Add-Content -Path $outpath -Value "$server,Failed"
        }

        
    }else{
        Write-Host "$server `t Ping Failed" -ForegroundColor Red
        Add-Content -Path $outpath -Value "$server,Ping Failed"
    }
    
}


#Send-MailMessage -Attachments $outpath -To 'hs-sysadmin-windows-offshore@trizetto.com' -Cc 'HS-SysAdmin-Windows-Operations@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report : $domain" -SmtpServer 'mail-2.trizetto.net'  -Body "PBA SCCM Client Instalaltion Report on domain : $domain"
