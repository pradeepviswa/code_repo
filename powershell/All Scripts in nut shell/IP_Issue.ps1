import-module vmware.vimautomation.core
import-module VMware.VimAutomation.Common
$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir
$custs = Get-Content .\input.txt
$outfile = ".\Output-AllServers.csv"
Remove-Item -Path $outfile -Force -ErrorAction SilentlyContinue
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "server,IP,VC"
"Started..."
$count = 0
$servers = @()
foreach($cust in $custs){
     
    

    $vc = "10.80.201.215"
    connect-viserver $vc | Out-Null

    #$cust = "shp"
    $vc1 = Get-VM -Name abn-$cust* | Select Name,@{N="IPAddress";E={@($_.guest.IPAddress[0])}}
    $servers = $vc1
    foreach($server in $servers){
        Add-Content -Path $outfile -Value "$($server.name),$($server.IPAddress),$vc"
        $count++
    }

    $vc = "10.80.200.108"
    connect-viserver $vc | Out-Null
    $vc2 = Get-VM -Name abn-$cust* | Select Name,@{N="IPAddress";E={@($_.guest.IPAddress[0])}}
    $servers = $vc2
    foreach($server in $servers){
        Add-Content -Path $outfile -Value "$($server.name),$($server.IPAddress),$vc"
        $count++
    }

    Write-Host "$cust `t $($count)"

    $servers = @()
}

