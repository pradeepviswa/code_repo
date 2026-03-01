import-module vmware.vimautomation.core
import-module VMware.VimAutomation.Common
$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir
$servers = Get-Content .\Input.txt
$outfile = ".\Output-RebootStatus.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "server,VC,RebotoStatus"
"Started..."
$count = 0
#$cred = Get-Credential -Credential a01\vighnesh.kambli
foreach($server in $servers){
        
        $flag = 0
        $netbios = $server.Split(".")[0]

        $vc = "A01mgtvca0002.a01.cishoc.com"
        $VCconnection = connect-viserver $vc -Credential $cred -Force

        $vm = Get-VM -Name $netbios -Server $VCconnection -ErrorAction SilentlyContinue
        if($vm -ne $null){
            $flag = 1
            Restart-VM $vm -Confirm:$false | Out-Null
            Add-Content -Path $outfile -Value "$server,$vc,Restarted"
            Write-Host "$server `t Restarted"
        }

        if($flag -eq 0){
            $vc = "A01mgtvca0004.a01.cishoc.com"
            $VCconnection = connect-viserver $vc -Credential $cred -Force
            $vm = Get-VM -Name $netbios -Server $VCconnection -ErrorAction SilentlyContinue
            if($vm -ne $null){
                $flag = 1
                Restart-VM $vm -Confirm:$false | Out-Null
                Add-Content -Path $outfile -Value "$server,$vc,Restarted"
                Write-Host "$server `t Restarted"
            }
        
        }


        if($flag -eq 0){
            $vc = "A01mgtvca0001.a01.cishoc.com"
            $VCconnection = connect-viserver $vc -Credential $cred -Force
            $vm = Get-VM -Name $netbios -Server $VCconnection -ErrorAction SilentlyContinue
            if($vm -ne $null){
                $flag = 1
                Restart-VM $vm -Confirm:$false | Out-Null
                Add-Content -Path $outfile -Value "$server,$vc,Restarted"
                Write-Host "$server `t Restarted"
            }
        
        }

        if($flag -eq 0){
            $vc = "A01mgtvca0003.a01.cishoc.com"
            $VCconnection = connect-viserver $vc -Credential $cred -Force
            $vm = Get-VM -Name $netbios -Server $VCconnection -ErrorAction SilentlyContinue
            if($vm -ne $null){
                $flag = 1
                Restart-VM $vm -Confirm:$false | Out-Null
                Add-Content -Path $outfile -Value "$server,$vc,Restarted"
                Write-Host "$server `t Restarted"
            }
        
        }

        if($flag -eq 0){
                Add-Content -Path $outfile -Value "$server,,Server not found in any VC"
                Write-Host "$server `t Server not found in any VC" -ForegroundColor Yellow
        
        }
    

}

Get-Command -verb get -Noun *vmotion*

