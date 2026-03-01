

###########################
#change here
$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location $dir


$outpath = ".\Output.csv"

$servers = Get-Content ".\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

###########################

#add output file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status,OS"

$count = $servers.Count
$x = 0

Write-Host "Checking SCCM Service. Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Checking SCCM Client Service" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if( Test-Connection $server -Count 1 -Quiet){
        $service = ""
        $os = ""
        try{
                    $service = Get-Service -Name "CcmExec" -ComputerName $server -ErrorAction SilentlyContinue

                    
                    $os = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $server -ErrorAction silentlycontinue | select -ExpandProperty caption
                
                if ($service.Name -eq "CcmExec"){
                    Add-Content -Path $outpath -Value "$server,Installed,$os"
                    Write-Host "$server : installed `t $os"
                }else{

                    Write-Host "$server : Missing `t $os" -ForegroundColor Red
                    Add-Content -Path $outpath -Value "$server,Missing,$os"
                }



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
Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@cognizant.com','hs-sysadmin-windows-offshore@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM-Client Service Check Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM-Client service check report."
#Send-MailMessage -Attachments $outpath -To 'mahesh.limaye@cognizant.com' -From 'SCCM@trizetto.com' -Subject "SCCM-Client Service Check Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM-Client service check report."
