###########################
$dir = Split-Path $Script:Myinvocation.mycommand.path
$outpath = ".\SCCMInstall.csv"
$sccmClientInstaller = ".\Client"
###########################

Remove-Item -Path $outpath -ErrorAction SilentlyContinue
New-Item -ItemTyp File -Path $outpath | Out-Null
Set-Content -Path $outpath -Value "Server,SCCM_Status"

$servers = Get-Content .\Servers.txt
$count = $servers.Count
$x = 0

$failedServers = @()
$validServers = @()
Write-Host "Total Servers: $count" -ForegroundColor Yellow
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f (($x/$count) * 100)
    Write-Progress -Activity "Uninstall SCCM Client" -Status "In Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    if( Test-Connection $server -Count 1 -Quiet){
        $dest = ""
        try{

                $s = $server
                $dest = "\\$s\c$\Temp\Client"
                Write-Host "$s" -ForegroundColor Yellow
                Write-Host "`t Deleting $dest"
                Remove-Item -Path $dest -Recurse -Force -ErrorAction SilentlyContinue
                
                Write-Host "`t Copying $sccmClientInstaller to $dest"
                Start-Process -FilePath XCopy -ArgumentList "$sccmClientInstaller $dest /E /C /I /Q /H /R /Y"
                #Copy-Item $sccmClientInstaller -Destination \\$s\c$\Temp\Client -Recurse  -force
                
                

                $validServers += $server

        }catch{
            $failedServers += $server
            Write-Host "`t $server `t Failed"
            Add-Content -Path $outpath -Value "$server,Failed"
        }

        
    }else{
        Write-Host "$server `t Ping Failed" -ForegroundColor Red
        Add-Content -Path $outpath -Value "$server,Ping Failed"
    }
    
}
