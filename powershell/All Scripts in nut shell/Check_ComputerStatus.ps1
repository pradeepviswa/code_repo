$lines = Import-Csv -Path "E:\AdminTools\Pradeep\Check_ComputerStatus\Input.csv"

$outfile = "E:\AdminTools\Pradeep\Check_ComputerStatus\Output.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "server,Enabled,fqdn,Description"
$x = 0
$count = $lines.Count
foreach($line in $lines){
    $percent = "{0:N2}" -f ($x/$count *100)
    Write-Progress -Activity "Check Computer Object" -Status "Progress($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $line
    $domain = $line.domain
    $server = $line.server

    $Enabled = ""
    $dnshostname = ""
    try{
        $obj = Get-ADComputer -Server $domain -Identity $server -ErrorAction Stop -Properties *
        $Enabled =  $obj.Enabled
        $dnshostname = $obj.dnshostname
        $Description = $obj.Description
        Write-Host "$dnshostname `t $Enabled"
        Add-Content -Path $outfile -Value "$server,$Enabled,$dnshostname,$Description"
    }catch{
        Write-Host "$server `t Error" -ForegroundColor Yellow
        Add-Content -Path $outfile -Value "$server,Error"

    }   
    $x++ 
}


Get-ADComputer -Identity CSN-ACC-XEN-03 -Server qic -Properties *
