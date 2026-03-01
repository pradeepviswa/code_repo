$dir = Split-Path $Script:Myinvocation.Mycommand.Path
Set-Location $dir


$servers = Get-Content .\Input.txt
$output = ".\Output_OS.csv"
Set-Content -Path $output -Value "Server,OS"

foreach($server in $servers){
    $a = $server.Split(".")
    $domain = "$($a[1]).$($a[2]).$($a[3])"
    $name = $a[0]

    try{
        $obj = Get-ADComputer -Server $domain -Filter {name -eq $name} -Properties * -ErrorAction Stop
        $os = $obj.OperatingSystem
        Write-Host "$server `t $os"
        Add-Content -Path $output -Value "$server,$os"
    }catch{
    
        Write-Host "$server `t Error" -ForegroundColor Yellow
        Add-Content -Path $output -Value "$server,Error"

    }
        
}

