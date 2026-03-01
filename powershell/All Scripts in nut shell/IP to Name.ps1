$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir
$ips = Get-Content .\Input.txt
$FQDN = @()
$count = $ips.Count
$x = 0
foreach($ip in $ips){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "IP to FQDN" -Status "In Progress ($x of $count)...$percent" -PercentComplete $percent -CurrentOperation "$ip" 
    $obj = Get-WmiObject -Class Win32_Computersystem -ComputerName $ip
    $Domain = $obj.Domain
    $Name = $obj.Name
    "$Name.$Domain"
    $FQDN += "$Name.$Domain"
}

    $FQDN | Out-File .\Output.txt

    notepad.exe .\Output.txt