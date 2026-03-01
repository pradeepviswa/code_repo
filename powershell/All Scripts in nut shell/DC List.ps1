$dir = Split-Path $Script:myinvocation.mycommand.path
Set-Location -Path $dir
$outfile = ".\output.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Domain,DC,IP"

Write-Host "Generatign trusted domain list" -ForegroundColor Yellow
$domains = @()
$localDomain = $env:USERDNSDOMAIN
$domains += Get-ADTrust -Server $localDomain -Filter * | select -ExpandProperty name
$domains += $localDomain

$x = 0
$count = $domains.Count
foreach($domain in $domains){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    
    Write-Progress -Activity "Extracting DC List" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $domain

    try{
        $DCs = Get-ADDomainController -Filter * -Server $domain -ErrorAction Stop -ErrorVariable $er | select -ExpandProperty name    
        foreach($DC in $DCs){
            $DCName = "$dc.$domain"
            
            $ping = Test-Connection $DCName -Count 1
            $IP = $ping.IPV4Address.IPAddressToString
            "$DCName `t $IP"
            Add-Content -Path $outfile -Value "$domain,$DCName,$IP"
            $IP = ""
    
        }
    
    }catch{
        $msg = $er.message    
        Write-Host "$domain `t Error - $msg"
        Add-Content -Path $outfile -Value "$domain,Error $msg"
    }
}



$to = "pradeep.viswanathan@cognizant.com"
$from = "automated-hoc3@cognizant.com"
$smtp = "mail.cishoc.com"
$subject = "HOC2 DC IPs"
$html = "PFA list of DC IPs"
Send-MailMessage -To $to -From $from -SmtpServer $smtp -Subject $subject -Body $html -Attachments $outfile


