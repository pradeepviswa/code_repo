<#
Add domain names in "E:\AdminTools\SCCM_Script\SCCM_Install_Script\7_Check_SCCM_Service\Servers.txt"
execute script
#>

###########################
#change here

$basePath = "E:\AdminTools\SCCM_Script\SCCM_Install_Script"
$outpath = "$basePath\7_Check_SCCM_Service\SCCM_Service.csv"
$sccmClientInstaller = "$basePath\Client"
$domains = Get-Content "$basePath\7_Check_SCCM_Service\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

###########################

#add outptu file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status,OS"

#add server names in $SERVERS variable 
$validServers = @()
foreach($domain in $domains){
    
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
    $decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Output\DecomServers.txt"
    $DomainServer = @()
    foreach($s in $server){
        if($decomServers -notcontains $s){
            $validServers += $s
            $DomainServer += $s
        }
    }
    $output = "$domain `t $($DomainServer.count)"
    $body += "$output `n"
    Write-Host $output
}

$count = $validServers.Count
$x = 0

Write-Host "Checking SCCM Service. Total Servers: $count" -ForegroundColor Yellow
foreach($server in $validServers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Checking SCCM Client Service" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if( Test-Connection $server -Count 1 -Quiet){
        
        $os = ""
        try{
            try{

                    #open pssession before activity start. this will be used with invoke-command
                    $session = New-PSSession -ComputerName $server -Authentication Negotiate -ErrorAction stop


                    $service = Invoke-Command -Session $session -ScriptBlock{
                        Get-Service -Name "CcmExec"
                    } -ErrorAction SilentlyContinue

                    $obj = Invoke-Command -Session $session -ScriptBlock{
                        Get-WmiObject -Class win32_operatingsystem
                    } -ErrorAction SilentlyContinue

                    $os = $obj.caption

            
            }catch{
                    $service = Get-Service -Name "CcmExec" -ComputerName $server -ErrorAction SilentlyContinue
                    $obj = Get-WmiObject -ComputerName $server -Class win32_operatingsystem -ErrorAction SilentlyContinue
                    $os = $obj.caption

                        
            }

                
                if ($service.Name -eq "CcmExec"){
                    Add-Content -Path $outpath -Value "$server,Installed,$os"
                }else{

                    Write-Host "$server : Missing `t $os" -ForegroundColor Red
                    Add-Content -Path $outpath -Value "$server,Missing,$os"
                }

            #close pssession
            Remove-PSSession -Session $session

        }catch{
            Write-Host "$server `t Unable to establish remote session." -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Unable to establish remote session"
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
#Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@trizetto.com','Daniel.Villalobos@trizetto.com','hs-sysadmin-windows-offshore@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM Client Instalaltion Report on domain. Address those servers where SCCM client is not installed"
