$path = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $path

$output = ".\Output-PingCheck.csv"
Remove-Item -Path $output -Force -ErrorAction SilentlyContinue
New-Item -Path $output -ItemType File | Out-Null
Set-Content -Path $output -Value "Server,PingStatus"

$servers = Get-Content .\Input.txt
$count = $servers.Count
$x = 0

foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Ping Check" -Status "In progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    
    if(Test-Connection -ComputerName $server -Count 2 -Quiet){
        Write-Host "$server `t Success"
        Add-Content -Path $output "$server,Success"
    }else{
        Write-Host "$server `t Failed" -ForegroundColor Yellow
        Add-Content -Path $output -Value "$server,Failed"
    }

}


$to = "pradeep.viswanathan@cognizant.com"
$to = 'pradeep.viswanathan@trizetto.com'
$from = 'AutoatedEmailHOC2@cognizant.com'
$smtp = 'mail-2.trizetto.net'
$subject = "Ping Check"
$bodyAsHtml = "PFA Report"
Send-MailMessage -to $to -From $from -Body $bodyAsHtml -Subject $subject -SmtpServer $smtp -Attachments $output