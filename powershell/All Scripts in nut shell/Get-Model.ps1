<#
Created by: 
Name: Pradeep Viswanathan
Email ID: pradeep.viswanathan@trizetto.com

this script generates server make model detail
---------------------------------------------

Step:1
Copy server names to 
E:\AdminTools\Pradeep\Get-Model\Servers.txt

Step2:
Execute script.

Step3:
Check output in
E:\AdminTools\Pradeep\Get-Model\Output.csv"

#>

$servers = Get-Content E:\AdminTools\Pradeep\Get-Model\Servers.txt

$outFile = "E:\AdminTools\Pradeep\Get-Model\Output.csv"
Remove-Item -Path $outFile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Make-Model"

$count = $servers.Count
$x = 0

foreach($server in $servers){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Get make model" `
        -Status "Progress ($x of $count)...$percent%" `
        -PercentComplete $percent `
        -CurrentOperation $server

    if(Test-Connection $server -Count 1 -Quiet){
        try{
            $cs = Get-WmiObject -Class Win32_Computersystem -ComputerName $server -ErrorAction Stop

            $manuf = $cs.Manufacturer
            $model = $cs.Model

            Add-Content -Path $outFile -Value "$server,$manuf $model"
    
        }catch{
            Write-Host "$server" -ForegroundColor Red
            Add-Content -Path $outFile -Value "$server,Error"
        }
    
    }else{
            Write-Host "$server" -ForegroundColor Red
            Add-Content -Path $outFile -Value "$server,Ping Failed"
    
    }

    $x++
}


Send-MailMessage -To "pradeep.viswanathan@trizetto.com" -From "model@trizetto.com" -SmtpServer "mail-2.trizetto.net" -Subject "get-model" -Body "PFA file" -Attachments $outFile



