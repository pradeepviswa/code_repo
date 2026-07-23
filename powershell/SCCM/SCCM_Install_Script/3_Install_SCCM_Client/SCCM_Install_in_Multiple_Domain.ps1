<#
Add domain names in "E:\AdminTools\SCCM_Script\SCCM_Install_Script\3_Install_SCCM_Client\Servers.txt"
execute script
#>

###########################
#change here
$basePath = "E:\AdminTools\SCCM_Script\SCCM_Install_Script\3_Install_SCCM_Client"
$outpath = "$basePath\3_Install_SCCM_Client\SCCMInstall.csv"
$sccmClientInstaller = "$basePath\Client"
$domains = Get-Content "$basePath\3_Install_SCCM_Client\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

#store credential
$TmpFile = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Secure_Password_DO_NOT-DELETE\Infra.Service_SecurePassword.txt"
$username = "SERVICES\infra.service"
$password = Get-Content $TmpFile | ConvertTo-SecureString
#$cred = New-Object System.Management.Automation.PSCredential -ArgumentList $username, $password
$cred = Get-Credential -Credential services\viswanathan.admin
###########################

#add outptu file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status"

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
$servers
$count = $servers.Count
$x = 0


Write-Host "Installation in progress. Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Installing SCCM Client" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if(Test-Connection $server -Count 1 -Quiet){
        
        
        try{
                #open pssession before activity start. this will be used with invoke-command
                $session = New-PSSession -ComputerName $server -Credential $cred -ErrorAction stop

                $s = $server
                $reg = $null
                $key=$null

                $key = Invoke-Command -Session $session -ScriptBlock{
                    param($s)
                    $keyname = 'SOFTWARE\Microsoft\CCM'
                    $reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey("LocalMachine","$s")
                    $key = $reg.OpenSubkey($keyname)
                    $key
                } -ArgumentList $s

                if ($key -ne $null){
                    Write-Host "$server `t Already Installed"
                    $outValue = "$server,Already Installed" 
                    Add-Content -Path $outpath -Value $outValue
                }else{
                    Invoke-Command -Session $session -ScriptBlock{
                        param($s)
                        New-Item -ItemType Directory -Path C:\Temp -ErrorAction SilentlyContinue | Out-Null
                    } -ArgumentList $s
                    
                    #copy installer to remote machine C:\Temp folder
                    Copy-Item -ToSession $session -Destination c:\temp\ -Path $sccmClientInstaller -Recurse -Force

                    #install SCCM Client
                    Invoke-Command -Session $session -ScriptBlock{
                        cmd /c "c:\Temp\client\ccmsetup.exe /UsePKICert CCMFIRSTCERT=1 SMSSITECODE=CSN SMSMP=https://csn-svc-sccm-01.services.tzghosting.net"
                    }
                    
                    
                    Write-Host "$server `t Installed"
                    $outValue = "$server,Installed" 
                    Add-Content -Path $outpath -Value $outValue

                }#if key -ne null

            #close pssession
            Remove-PSSession -Session $session

        }catch{
            Write-Host "$server `t Failed to connect registry. Check Port." -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Failed to connect registry. Check Port"
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

#Send-MailMessage -Attachments $outpath -To 'hs-sysadmin-windows-offshore@trizetto.com' -Cc 'HS-SysAdmin-Windows-Operations@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PBA SCCM Client Instalaltion Report on domain"
#Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM Client Instalaltion Report on domain"
