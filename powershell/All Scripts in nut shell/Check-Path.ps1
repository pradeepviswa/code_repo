$dir = Split-Path $Script:Myinvocation.Mycommand.Path
Set-Location -path $dir

$outfile = ".\Check-Patch.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue 
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,Path,Status"

$servers = Get-Content .\Input.txt

foreach($server in $servers){
    $flag = $false
    $path = "\\$server\c$\Program Files\Wireshark"
    if(Test-Path -Path $path){
        $flag = $true
    }elseif(Test-Path -Path "\\$server\D$\Program Files\Wireshark"){
        $flag = $true
        $path = "\\$server\c$\Program Files\Wireshark"
    }
    $fgcolor = "yellow"
    if($flag){
        $fgcolor = "white"
    }
    Add-Content -Path $outfile -Value "$server,$path,$flag"
    Write-Host "$server `t $flag" -ForegroundColor $fgcolor


}
