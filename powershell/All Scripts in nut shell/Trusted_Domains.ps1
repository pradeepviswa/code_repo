$outfile = "E:\AdminTools\Pradeep\Trusted_Domains\Output.txt"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile  | Out-Null


$trusts = ([System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()).GetAllTrustRelationships()
foreach($trust in $trusts){

    $domain = $trust.Targetname
    Add-Content -PassThru $outfile -Value $domain
    
}
$count = $trusts.Count
$to = "pradeep.viswanathan@trizetto.com"
$from = "automation@trizetto.com"
$smtp = "mail-2.trizetto.net"
$subject ="Trusted Domain List"
$bodyAsHTML ="<center>Trusted domain list attached.<br><b> Total Count: $count </b></center>"

Send-MailMessage -Attachments $outfile -To $to -From $from -SmtpServer $smtp -Subject $subject -BodyAsHtml $bodyAsHTML

