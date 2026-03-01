
$servers = Get-Content "E:\AdminTools\Pradeep\Uptime\Servers.txt"
$outfile = "E:\AdminTools\Pradeep\Uptime\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Computer,LastBootupTime,Uptime,UptimeInMins,UptimeInHrs"
$x = 0
$count = $servers.Count
$cred = Get-Credential -Credential services\viswanathan.admin
foreach($computer in $servers){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Uptime Report - Gruop1" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $computer
    $computer = $computer.trim()
    try{
            $os = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock{
                Get-WmiObject -Class Win32_OperatingSystem
            } -ErrorAction Stop

            $lastBootupTime = [Management.ManagementDateTimeConverter]::ToDateTime($os.LastBootUpTime)

            $diff = (Get-Date) - $lastBootupTime

            $ComputerName = $computer
            $LastBootupTime = $lastBootupTime;
            $Uptime = "Uptime: {0} days {1} hrs {2} mins" -f $diff.Days, $diff.Hours, $diff.Minutes;
            $UptimeInMins = ("{0:N2}" -f $diff.TotalMinutes).Replace(",","")
            $UptimeInHrs = "{0:N2}" -f $diff.TotalHours
        
            Add-Content -Path $outfile -Value "$ComputerName,$lastBootupTime,$Uptime,$UptimeInMins,$UptimeInHrs"
            Write-Host "$ComputerName `t $lastBootupTime"
    
    }catch{
        Add-Content -Path $outfile -Value "$computer,Error"
        Write-Host "$computer `t Error" -ForegroundColor Red
    
    }
    $x++

}
    

Send-MailMessage -Attachments $outfile -To "hs-sysadmin-windows-offshore@trizetto.com" -From "automated-script@trizetto.com" -Subject "Server Uptime" -SmtpServer "mail-2.trizetto.net"