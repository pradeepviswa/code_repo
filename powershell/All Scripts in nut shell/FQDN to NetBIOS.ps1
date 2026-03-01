$servers = Get-Content "E:\AdminTools\Pradeep\FQDN to NetBIOS\Servers.txt"
$NetBIOS = @()
$count = $servers.Count
$x = 0
foreach($server in $servers){
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity $server -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent
    
    $serverArray = $server.Split("-")
    $serverArray2 = ($serverArray[3].Split("."))[0]
    
    $NetBIOS += "$($serverArray[0])-$($serverArray[1])-$($serverArray[2])-$serverArray2"
    $NetBIOS

    $x++
}

$NetBIOS | Out-File "E:\AdminTools\Pradeep\FQDN to NetBIOS\output.txt"
$NetBIOS
notepad "E:\AdminTools\Pradeep\FQDN to NetBIOS\output.txt"

