$dir = Split-Path $Script:MyInvocation.MyCommand.path
Set-Location $dir
$servers = Get-Content ".\servers.txt"
$outFile = ".\output.txt"
$count = $servers.Count
$x = 1
$ServerFQDN = @()


foreach($server in $servers){

$x++
$percent = "{0:N2}" -f ($x/$count * 100)
Write-Progress -Activity "Get FQDN" -Status "$x of $count .. $percent%" -PercentComplete $percent -CurrentOperation $server

    # SET DOMAIN NAME OF THOSE WHOSE NAMING CONVENSION DO NOT MATCH THEIR DOMAIN NAME

    $customerName = "$($server.Split("-")[1])"  
    $domain = "$customerName.tzghosting.net"
    if( ($customerName -match "SVC") ){
        $domain = "services.tzghosting.net"
    }elseif( ($customerName -match "CES") ){
        $domain = "qic.tzghosting.net"
    }elseif( ($customerName -match "DMS") ){
        $domain = "Cust.tzghsp.net"
    }elseif( ($customerName -match "TPC") ){
        $domain = "tpzhsp.net"
    }
        

    # COVERT INTO FQDN
    if(Test-Connection -ComputerName "$server.custhsp.tzghosting.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.custhsp.tzghosting.net"
    }elseif(Test-Connection -ComputerName "$server.cust.tzghsp.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.cust.tzghsp.net"
    }elseif(Test-Connection -ComputerName "$server.custft.tzghosting.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.custft.tzghosting.net"
    }elseif(Test-Connection -ComputerName "$server.saas.tzghosting.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.saas.tzghosting.net"
    }elseif(Test-Connection -ComputerName "$server.services.tzghosting.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.services.tzghosting.net"
    }elseif(Test-Connection -ComputerName "$server.cvs.tzghsp.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.cvs.tzghsp.net"
    }elseif(Test-Connection -ComputerName "$server.topaz.tpzhsp.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.topaz.tpzhsp.net"
    }elseif(Test-Connection -ComputerName "$server.demo.tzghosting.net" -Count 1 -Quiet){
        $ServerFQDN += "$server.demo.tzghosting.net"
    }elseif(Test-Connection -ComputerName "$server.ode.trizetto.com" -Count 1 -Quiet){
        $ServerFQDN += "$server.demo.tzghosting.net"
    }elseif($server -notmatch "-"){
        $ServerFQDN += $server
    }else{
        $ServerFQDN += "$server.$domain"
    }

}


$ServerFQDN | Out-File $outFile
$ServerFQDN
notepad $outFile



