
$computers = Get-Content "E:\AdminTools\Pradeep\Check_Trend_AV\Servers.txt"
$cred = Get-Credential -Credential services\viswanathan.admin
$outfile = "E:\AdminTools\Pradeep\Check_Trend_AV\output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,TrendAT,TrendServiceStatus"

$count = $computers.Count
$x = 0

foreach($computer in $computers){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Checking Trend AV" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $computer
    try{
        $service = Invoke-Command -ComputerName $computer -Credential $cred -ScriptBlock{
            Get-Service -Name "SpntSvc"
        } -ErrorAction Stop

        Add-Content -Path $outfile -Value "$computer,Trend AV Installed,$($service.status)"
        Write-Host "$computer `t Trend AV Installed `t $($service.status)"

    }catch{
        Add-Content -Path $outfile -Value "$computer,Trend AV not Installed,Not Available"
        Write-Host "$computer `t Trend AV Not Found" -ForegroundColor Yellow
    }

    $x++
}


$to1 = "pradeep.viswanathan@trizetto.com"
$to2 = "Jeff.Grabowski@trizetto.com"
$from = "automated-script@trizetto.com"
$smtp ="mail-2.trizetto.net"
$subject = "Trend Antivirus Status - test"
$bodyAsHTML = "PFA file"

Send-MailMessage -To $to1,$to2 -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHTML -Attachments $outfile

