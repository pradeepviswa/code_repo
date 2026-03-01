$hint = "KB4012216"
$servers = Get-Content "E:\AdminTools\Pradeep\Check_Specific_Hotfix\$hint\servers.txt"
$outFile = "E:\AdminTools\Pradeep\Check_Specific_Hotfix\$hint\Output-$hint.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "ServerName,OS,Patch"

$count = $servers.Count
$x = 0

foreach($server in $servers){

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "Folder $hint" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "Checking $server"

    try{
        $osname = Get-WmiObject -Class win32_operatingsystem -ComputerName $server | select *
        $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction Stop| select  caption,OSArchitecture
        $osname = $os.caption
        $bit = $os.OSArchitecture


        
        if($osname -match "2012"){
            $hotfixID = $hint
            $hotfix = Get-HotFix -ComputerName $server | where {$_.HotFixID -match $hotfixID}
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing" -ForegroundColor yellow
            }
        }

    
    }catch{
                Add-Content -Path $outFile -Value "$server,Connection Error"
                Write-Host "$server `t Connection Error" -ForegroundColor red
    
    }
    $x++
}




