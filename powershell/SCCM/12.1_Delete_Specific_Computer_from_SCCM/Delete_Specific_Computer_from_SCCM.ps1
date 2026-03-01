$dir = Split-Path $Script:Myinvocation.Mycommand.path


#Import required modules
Write-Host "Loading Modules ConfigurationManager, ActiveDirectory..... Please wait" -ForegroundColor Yellow
Import-Module ConfigurationManager
Import-Module ActiveDirectory

Set-Location csn:

Write-Host "Loading all devices..."
$servers = Get-Content "$dir.\Input.txt"


#output File
$outFile = "$dir\Output-Delete Computer.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Status"

$x = 0
$count = $servers.Count
if($count -lt 1){$count = 1}
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x/$count *100)
    Write-Progress -Activity "Delete Computer from SCCM" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

    try{
        $netBios = $server.Split(".")[0]
        if((Get-CMDevice -Name $netBios) -eq  $null){
            Write-Host "$server `t Not Found in SCCM"
            Add-Content -Path $outFile -Value "$server,Not Found in SCCM"
        }else{
            Remove-CMDevice -Name $netBios -Force -ErrorAction Stop
            Write-Host "$server `t Deleted"
            Add-Content -Path $outFile -Value "$server,Deleted"
        }

    
    }catch{
            Write-Host "$server `t Error" -ForegroundColor Yellow
            Add-Content -Path $outFile -Value "$server,Error"
    
    }
}
