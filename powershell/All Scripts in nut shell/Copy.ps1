Set-Location -Path E:\AdminTools\Pradeep\Copy -ErrorAction SilentlyContinue
$lines = Import-Csv .\input.csv
$output = ".\Output.csv"
Set-Content -Path $output -Value "Server,Status"
foreach($line in $lines){
    $source = $line.Source
    $dest = $line.Dest
    $server = $line.server
    try{
        $session = New-PSSession -ComputerName $server -Authentication Negotiate
        Copy-Item -Path $source -Destination $dest -ToSession $session -Recurse -Force
        Add-Content -Path $output -Value "$server,Copied"
        Write-Host "$server `t Copy success"
     $session | Remove-PSSession
    }catch{
        Add-Content -Path $output -Value "$server,Copy Failed"
        Write-Host "$server `t Copy Failed" -ForegroundColor Yellow
    }
}
