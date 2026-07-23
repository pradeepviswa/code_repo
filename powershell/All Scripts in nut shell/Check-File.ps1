# edit these 2 lines
$path = "E:\AdminTools\Pradeep\Check-File\Logs"
$outfile = "E:\AdminTools\Pradeep\Check-File\Output.csv"
#--------------------------------

Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -Path $outfile -ItemType File | Out-Null
Set-Content -Path $outfile -Value "FileName,Line"

$files = Get-ChildItem $path | 
            where {$_.Attributes -eq "Archive"} | 
            select name, fullname
$count = $files.Count
$x = 0
foreach($file in $files){
    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Check File... Connected to" `
        -Status "In Progress($x of $count...$percent%)" `
        -PercentComplete $percent `
        -CurrentOperation $file

    $content = Get-Content $file.FullName
    $filename = $file.Name
    foreach($line in $content){
        if($line -match "Connected to"){
            Add-Content -Path $outfile -Value  "$filename, $line"
        }
    }#foreach content
    $x++
    
}#foreach files
Write-Host "Done" -ForegroundColor Yellow


$to = "atul.wagh@trizetto.com"
$from = "script@trizetto.com"
$smtp ="mail-2.trizetto.net"
$subject = "Check-File"
$body = "PFA file"

Send-MailMessage -To $to -From $from -SmtpServer $smtp -Subject $subject -Body $body -Attachments $outfile
Write-Host "Email sent to $to" -ForegroundColor Yellow

