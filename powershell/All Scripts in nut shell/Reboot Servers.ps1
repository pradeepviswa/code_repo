$dir = Split-Path $Script:Myinvocation.mycommand.path
$servers = Get-Content "$dir\Servers.txt"
#$cred = Get-Credential -Credential services\viswanathan.admin
$x = 0
$i = 1
$count = $servers.Count
foreach($server in $servers){
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Reboot" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    Invoke-Command -ComputerName $server -ScriptBlock {
        Restart-Computer -Force
    } -AsJob -Authentication Negotiate

    $i++
    $set = 100
    if($i -eq $set){
        Write-Host "Set of $set servers. Total $count. waiting for 5 secs" -ForegroundColor Yellow
        Start-Sleep -Seconds 5
        $i = 1
    }

    $x++
}

<#
$id = 13539
Get-Job -Id $id
receive-job -id $id

$server = @()
$server += "ABN-HZN-ADC-02.hzn.tzghosting.net"

    Invoke-Command -ComputerName $server -ScriptBlock {
        Restart-Computer -Force
    } -Authentication Negotiate
     

#>