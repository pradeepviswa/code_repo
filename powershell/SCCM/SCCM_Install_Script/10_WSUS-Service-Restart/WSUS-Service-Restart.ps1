

###########################
#change here
$dir = Split-Path $Script:MyInvocation.MyCommand.path
Set-Location -Path $dir

$outpath = ".\Output.csv"

$servers = Get-Content ".\Servers.txt"

#decom servers store in variable
$decomServers = Get-Content "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

###########################

#add output file
Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,Status"

$count = $servers.Count
$x = 0

Write-Host "Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){

    $server = $server.Trim()
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "WSUS Restart" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    if( Test-Connection $server -Count 1 -Quiet){
        
        try{
                    #$server = "CSN-SVC-UTIL-07.services.tzghosting.net"
                    $obj = Get-Service -Name "wuauserv" -ComputerName $server -ErrorAction Stop -ErrorVariable er| Stop-Service
                    Remove-Item -Path "\\$server\C$\Windows\SoftwareDistribution" -Force -Recurse 
                    #Rename-Item -Path "\\$server\C$\Windows\SoftwareDistribution" -NewName "\\$server\C$\Windows\SoftwareDistribution_old" -Force 
                    $obj = Get-Service -Name "wuauserv" -ComputerName $server -ErrorAction Stop -ErrorVariable er| Start-Service
                    
                    Write-Host "$server `t Done"
                    Add-Content -Path $outpath -Value "$server,Done"




        }catch{
            $msg = $er.message
            Write-Host "$server `t Error - $msg" -ForegroundColor Red
            Add-Content -Path $outpath -Value "$server,Error-$msg"
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
#Send-MailMessage -Attachments $outpath -To 'pradeep.viswanathan@cognizant.com','hs-sysadmin-windows-offshore@trizetto.com' -From 'SCCM@trizetto.com' -Subject "SCCM Client Installation Report" -SmtpServer 'mail-2.trizetto.net'  -Body "PFA SCCM Client Instalaltion Report on domain. Address those servers where SCCM client is not installed"

<#
Receive-Job -id 2829
Get-Job -id 2829
#>
