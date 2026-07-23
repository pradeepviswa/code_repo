$dir = Split-Path $script:Myinvocation.Mycommand.Path
Set-Location -Path $dir


$servers = Get-Content ".\Input.txt"
$output = "Output.csv"

Set-Content -Path $output -Value "Domain,TimeZone"

$count = $servers.Count
$x = 1
foreach($server in $servers){
    
    $percent = "{0:N2}" -f ($x/$count*100)
    Write-Progress -Activity "Time Zone Check" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    
    try{
        
        $obj = Get-WmiObject -Class Win32_TimeZone -ComputerName $server
        $tz = $obj.Caption
        Write-Host "$x) $server `t $tz"
        Add-Content -Path $output -Value "$server,$tz"
    
    }catch{
        Write-Host "$x) $server `t Error" -ForegroundColor Yellow
        Add-Content -Path $output -Value "$server,Error"
    
    }
    
$x++
}




