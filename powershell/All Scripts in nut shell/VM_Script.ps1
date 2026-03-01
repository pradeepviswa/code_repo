<#
ABNSVCHBV01
csn-svc-vc-09
abn-svc-vc-02
1. Search VM / VM Status
2. Export all VMs
4. VCenter Server List
5. Restart VM
6. Reset VM
0. Exit 

#>

Write-Host "1. Search VM"
main

function main{
    try{
        [int]$option = Read-Host "Choose your option" -ErrorAction SilentlyContinue
        if($option -eq 0){
            exit
        }elseif($option -eq 1){
            Search_VM
        }elseif($option -eq 2){
            Search_VM
        }
    }catch{
        Write-Host "Enter valid option"
        main
    }
    
}

Function Search_VM{
    #read from user
    $name = Read-Host "Enter VM Name"

    Import-Module VMware.VimAutomation.Core

    #add vcenter servers here
    $vcenterServers = @()
    $vcenterServers += "csn-svc-vc-09.services.tzghosting.net"
    $vcenterServers += "abn-svc-vc-09.services.tzghosting.net"
    $vcenterServers += "csnsvchbv01.services.tzghosting.net"
    $vcenterServers += "abnsvchbv01.services.tzghosting.net"
    
    #Connect-VIServer -Server "csn-svc-vc-09.services.tzghosting.net"
    foreach($vcenterServer in $vcenterServers){
        #connect vcenter server
        $con = Connect-VIServer -Server $vcenterServer
        $IsConnected = $con.IsConnected
        
        $VMs=""
        if($IsConnected){
            Write-Host "vCenter Connected: $vcenterServer"
    
            $VMs = Get-VM -Name $name -Server $con -ErrorAction SilentlyContinue | select name, powerstate,NumCPU,MemoryGB | Format-Table -AutoSize
    
            #disconnect vcenter server
            $con |Disconnect-VIServer -Force -Confirm:$false

            if($VMs.Count -gt 0){
                $VMs
                exit
            }
    
        }else{
            Write-Host "vCenter Connect Failed: $vcenterServer" -ForegroundColor Yellow
        }




    }#foreach vcenterServer

}

