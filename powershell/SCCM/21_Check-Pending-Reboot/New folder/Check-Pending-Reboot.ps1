$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir
$servers = Get-Content .\Input-Check-Pending-Reboot.txt

$outfile = ".\Output-Check-Pending-Reboot.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,RebootStatus"


$count = $servers.Count
$x = 0
foreach($server in $servers){
    $server = $server.Trim()
    
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Check reboot required" -Status "In progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server


    if(Test-Connection -ComputerName $server -Count 1 -Quiet){
        try{
            $path = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
            #$name = 'PendingFileRenameOperations'
            $key = Invoke-Command -ComputerName $server -ErrorAction Stop  -ScriptBlock{
               #Get-ItemProperty -Path $using:path -Name $using:name
               Test-Path $using:path
               #write-host "$($using:path)"
            } -Authentication Negotiate
            if($key ){
                Add-Content -Path $outfile -Value "$server,Reboot Required"
                Write-Host "$server `t Reboot Required" -ForegroundColor Yellow
            }else{
                Add-Content -Path $outfile -Value "$server,Reboot Not Required"
                Write-Host "$server `t Reboot Not Required"
            }
        }catch{
            Write-Host "$server `t Connection-Error"
            Add-Content -Path $outfile -Value "$server,Connection-Error"
        }
    }else{
        Write-Host "$server `t Ping-Failed"
        Add-Content -Path $outfile -Value "$server,Ping-Failed"
    }
}
