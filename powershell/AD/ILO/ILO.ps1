Test-NetConnection -ComputerName csn-svc-ps-01 -Port 3389 | select TcpTestSucceeded


cls



$servers = Get-Content E:\AdminTools\Pradeep\ILO\Servers.txt

$outFile = "E:\AdminTools\Pradeep\ILO\Output.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Add-Content -Path $outFile -Value "Server,IP"


$logFile = "E:\AdminTools\Pradeep\ILO\ILO.log"
if(Test-Path $logFile){
}else{
    New-Item -ItemType File -Path $logFile | Out-Null
}

$count = $servers.Count
$x = 0

foreach($server in $servers){

    $percent = "{0:N2}" -f (($x / $count)*100)
    Write-Progress -Activity "Generate ILO XML file" `
        -Status "Progress ($x of $count)..$percent%" `
        -PercentComplete $percent `
        -CurrentOperation $server

    $outTmpFile = "c:\temp\$server.xml"
    $tmpFolder = "\\$server\c$\temp"
    if(Test-Path $tmpFolder){
    }else{
        New-Item -ItemType Directory -Path $tmpFolder | Out-Null
    }

    PsExec.exe \\$server "C:\Program Files\HP\hponcfg\hponcfg.exe" /w $outTmpFile

    $source = "\\$server\c$\temp\$server.xml"
    $dest = "\\csn-svc-util-08.services.tzghosting.net\E$\AdminTools\Pradeep\ILO\XML\"
    try{
        Copy-Item -Path $source -Destination $dest -Force -ErrorAction Stop
        $result = "Success"
    }catch{
        $result = "Failed"
    }

    $xmlFile = "$dest\$server.xml"
    $xmlData = Get-Content $xmlFile
    $ip = $xmlData[28]
    $start = $ip.IndexOf("`"")+1
    $end = $ip.IndexOf("`"/")
    $range = $end - $start
    $ip = $ip.Substring($start,$range)
    $ip


    Add-Content -Path $outFile -Value "$server,$ip"

    Add-Content -Path $logFile -Value "$server,$ip,$result"

    $ip = ""
    $xmlData = ""
    $xmlFile = ""
    $x++   

}

$to = "pradeep.viswanathan@trizetto.com"
$from = "script@trizetto.com"
$smtp = "mail-2.trizetto.net"
$subject = "ILO IP Detail"
$body = "PFA ILO IP Detail"

Send-MailMessage -To $to -From $from -SmtpServer $smtp -Subject $subject -Body $body -Attachments $outFile

