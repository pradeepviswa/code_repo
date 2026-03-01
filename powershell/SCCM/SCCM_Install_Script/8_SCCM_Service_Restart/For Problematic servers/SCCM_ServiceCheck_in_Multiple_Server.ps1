
###########################
#change here

$outpath = ".\SCCM_Service.csv"
$servers = Get-Content ".\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"


#add output file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status"

$count = $servers.Count
$x = 0

Write-Host "Checking SCCM Service. Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Checking SCCM Client Service" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if( Test-Connection $server -Count 1 -Quiet){
        try{
        
                $service = Get-Service -Name "CcmExec" -ComputerName $server -ErrorAction Stop
                
                if ($service.Name -eq "CcmExec"){
                    Add-Content -Path $outpath -Value "$server,Installed"
                }else{
                    Write-Host "$server : Missing" -ForegroundColor Red
                    Add-Content -Path $outpath -Value "$server,Missing"
                }


        }catch{
            Write-Host "$server `t Error" -ForegroundColor Red
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
Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@cognizant.com','hs-sysadmin-windows-offshore@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM Client Instalaltion Report on domain. Address those servers where SCCM client is not installed"
