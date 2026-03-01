$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir

$outFile = "$dir\Output-BAT-File.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Status"
$servers = Get-Content -Path .\Input.txt

$count = $servers.Count
$x = 0

foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Check Component Service value" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $server

    if (Test-Connection -ComputerName $server -Count 1 -Quiet){
        try{
                Copy-Item -Path "\\csn-svc-util-07.services.tzghosting.net\C$\Scripts\Patch2008.bat" -Destination "\\$server\C$\Temp" -Force
                Copy-Item -Path "\\csn-svc-util-07.services.tzghosting.net\C$\Scripts\Patch2012.bat" -Destination "\\$server\C$\Temp" -Force
                $keyObj = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock {
                    Start-Process -FilePath "C:\temp\Patch2012.bat"
                    


                } # invoke-command
                $keyObj
                Write-Host "$server `t BAT Executed"
                Add-Content -Path $outFile -Value "$server,BAT Executed"
            
        
        }catch{
                Write-Host "$server `t Invoke Command Failed" -ForegroundColor red
                Add-Content -Path $outFile -Value "$server,Invoke Command Failed"
        }
    
    }else{
                Write-Host "$server `t Ping Failed" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Ping Failed"
    }

}
