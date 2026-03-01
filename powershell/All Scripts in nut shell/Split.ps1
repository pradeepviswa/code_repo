$dir = Split-Path $Script:MyInvocation.MyCommand.path
Set-Location $dir
$servers = Get-Content ".\Input.txt"
$outFile = ".\output.txt"
$count = $servers.Count
$x = 1
$values = @()


foreach($server in $servers){

$x++
$percent = "{0:N2}" -f ($x/$count * 100)
Write-Progress -Activity "Split Line" -Status "$x of $count .. $percent%" -PercentComplete $percent -CurrentOperation $server
    $line = $server.split("(")[0]
    $line
    $values += $line
    

}
$values | Out-File $outFile
notepad $outFile



