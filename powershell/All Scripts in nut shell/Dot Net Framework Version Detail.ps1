$dir = Split-Path $Script:Myinvocation.Mycommand.path
Set-Location -Path $dir

$outfile = ".\Output-Dot Net.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "ServerName,Release,Version"

$servers = Get-Content .\Input.txt
$count = $servers.count
foreach($server in $servers){
    try{
        $framework = Invoke-Command -ComputerName $server -Authentication Negotiate -ScriptBlock {
            Get-ItemProperty -Path  'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\ndp\v4\Full\1033' -Name Release,Version | select release, version
        } -ErrorAction Stop
        $Release = $framework.Release
        $Version = $framework.Version
        Write-Host "$server `t $Version"
        Add-Content -Path $outfile -Value "$server,$Release,$Version"
    }catch{
        Write-Host "$server `t Error" -ForegroundColor Yellow
        Add-Content -Path $outfile -Value "$server,Error,Error"
    }
}

#$computers = Get-ADComputer -Server emb -Filter * | select -ExpandProperty dnshostname
#$computers | Out-File "E:\AdminTools\Pradeep\Dot Net Framework Version Detail\Input.txt"

#$framework = Get-ItemProperty -Path  'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\ndp\v4\Full\1033' -Name Release,Version | select release, version


