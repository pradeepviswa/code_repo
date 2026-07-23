import-module vmware.vimautomation.core
import-module VMware.VimAutomation.Common


$dir = Split-Path $Script:Myinvocation.MyCommand.path
Set-Location -Path $dir

$servers = Get-Content .\input.txt
$flag = 0
foreach($server in $servers){

    $vc = "10.80.201.215" #abn-svc-vc-09.services.tzghosting.net
    connect-viserver $vc | Out-Null
    $vm = Get-VM $server -ErrorAction SilentlyContinue
    if ($($vm.count) -eq 1){
        $flag = 1
        try{
            Start-VM $server -ErrorAction Stop -ErrorVariable er
            
            Write-Host "$server `t started `t VC $vc"
        }catch{
            
            Write-Host "$server `t Poweron failed `t VC $vc (Current state: $($vm.PowerState))" -ForegroundColor Yellow
            
        }
    
    }


    if($flag -eq 0){
        $vc = "10.80.200.108" #vc-05
        connect-viserver $vc | Out-Null

        $vm = Get-VM $server -ErrorAction SilentlyContinue
        if ($($vm.count) -eq 1){
            $flag = 1
            try{
                Start-VM $server -ErrorAction Stop -ErrorVariable er
                
                Write-Host "$server `t started `t VC $vc "
            }catch{
                
                Write-Host "$server `t Poweron failed `t VC $vc (Current state: $($vm.PowerState))" -ForegroundColor Yellow
                
            }
    
        }


    }

    if($flag -eq 0){
        Write-Host "$server `t not found" -ForegroundColor Yellow
    }

    $flag = 0

}

