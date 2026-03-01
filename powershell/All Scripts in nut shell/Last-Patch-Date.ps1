<#
last patch install date
bits service status on remote server
server ping status
server uptime

get-command
input server name
foreach loop
check service status
print result on screen and output file
send report via email
#>
<#
$path = Split-Path $Script:MyInvocation.MyCommand.Path
Set-Location -Path $path

$output = ".\Output-PatchInstalledOn.csv"
Remove-Item -Path $output -Force
New-Item -ItemType File -Path $output | Out-Null
Set-Content -Path $output -Value "ServerName,LastPatchInstalledOn"


$servers = Get-Content .\Input.txt
foreach($server in $servers){
    
    $patch = Get-HotFix -ComputerName  $server | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1
    $InstalledOn = $patch.InstalledOn
    Write-Host "$server `t $InstalledOn"
    #content add to file
    Add-Content -Path $output -Value "$server,$InstalledOn"
}

#send email
$tomy = "pradeep.viswanathan@cognizant.com","ashok.kokate@cognizant.com"
$frommy = "AshokNoReply@cognizant.com"
$smtpmy = "mail-2.trizetto.com"
$subectmy = "Last patch installed on Report"
$bodymy = "Please find attached file. This contains report of last patch installed detail on servers."

Send-MailMessage -To $tomy -From $frommy -Subject $subectmy -BodyAsHtml $bodymy -SmtpServer $smtpmy -Attachments $output
 #>

 $path = Split-Path $Script:MyInvocation.mycommand.path
 Set-Location -Path $path

 $output=".\output-patchinstalledon.csv"
 Remove-Item -Path $output -Force
 New-Item -ItemType file -Path $output | Out-Null
 Set-Content -Path $output -Value "serverName,LastPathchINstalledOn"


 $servers= Get-Content .\Input.txt
 foreach($server in $servers){
    $patch=Get-HotFix -ComputerName $server | Sort-Object -Property InstalledOn -Descending | Select-Object -First 1

    $InstalledOn =$patch.InstalledOn
    Write-Host "$server  't $InstalledOn"
    Add-Content -Path $output -Value "$server, $InstalledOn"

 }
 $tomy= "ashok.kokate@cognizant.com"
 $frommy= "ashoknoreply@cognizant.com"
 $smptpmy= "mail-2.trizetto.com"
 $subjectmy="last patch installed on report"
 $bodymy="PLease find attached report"
 Send-MailMessage -To $tomy -From $frommy -Subject $subjectmy -BodyAsHtml $bodymy -SmtpServer $smtpmy -Attachments $output
