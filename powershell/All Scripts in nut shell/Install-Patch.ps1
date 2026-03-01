<#
4012216	2012 R2
4012213	2012 R2
4012212	2008 R2 64 bit
4012215	2008 R2 64 bit
#>

$servers = "127.0.0.1"
$count = $servers.Count
$x = 0

foreach($server in $servers){

    $percent = "{0:N2}" -f ($x/$count * 100)
    Write-Progress -Activity "$server" -Status "Progress ($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation "Check Hotfix"

    try{
        
        $osname = Get-WmiObject -Class win32_operatingsystem -ComputerName $server | select *
        $os = Get-WmiObject -Class win32_operatingsystem -ComputerName $server -ErrorAction Stop| select  caption,OSArchitecture
        $osname = $os.caption
        $bit = $os.OSArchitecture



        if( $osname -match "2003") {
            $hotfixID = "KB4012598"
            $hotfix = Get-HotFix -ComputerName $server | where {$_.HotFixID -match $hotfixID}
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing" -ForegroundColor yellow
            }

        }


        #check  MS17-010 on Microsoft® Windows Server® 2008 Standard 32/64-bit
        if( $osname -match "2008") {

            $hotfixID = "4012212"
            $hotfix = Get-HotFix -ComputerName $server | where {$_.HotFixID -match $hotfixID}
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing" -ForegroundColor yellow
            }


            $hotfixID = "4012215"
            $hotfix = Get-HotFix -ComputerName $server | where {$_.HotFixID -match $hotfixID}
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname $bit,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing" -ForegroundColor yellow
            }

        }


        #check  MS17-006 on Microsoft Windows Server 2012 R2 Standard 64-bit
        if($osname -match "2012"){
            $hotfixID = "KB4012216"
            $hotfix = Get-HotFix -ComputerName $server | where {$_.HotFixID -match $hotfixID}
            if($hotfix.HotFixID -eq $hotfixID){
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Installed"
                Write-Host "$server `t $hotfixID Installed"
            }else{
                Add-Content -Path $outFile -Value "$server,$osname,$hotfixID Missing"
                Write-Host "$server `t $hotfixID Missing" -ForegroundColor yellow
            }
        }


        #check  MS17-008 on Microsoft Windows Server 2012 R2 Standard 64-bit
        if($osname -match "2012"){
            $hotfixID = "KB4012213"
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




