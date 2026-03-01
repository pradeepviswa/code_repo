Import-Module ConfigurationManager
Set-Location -Path csn:

$outfile = "E:\AdminTools\SCCM_Script\7_Verify_Computers_btw_DC_and_SCCM\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue 
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,Discovered_In_SCCM,ClietnInstalled,Active_in_SCCM,LastActiveTime,Domain,OS"

$domains = Get-Content "E:\AdminTools\SCCM_Script\7_Verify_Computers_btw_DC_and_SCCM\Input.txt"
Write-Host "Generating computer list from DC..." -ForegroundColor Yellow
$servers = @()

foreach($domain in $domains){
    
    $ADComputers = Get-ADComputer -Server $domain -Filter * -Properties *| 
        Where-Object -FilterScript {
            (
                ($_.Enabled) -and 
                ($_.DnsHostName -notmatch "CLUS") -and
                ($_.DnsHostName -notmatch "nas")
            ) -and
            (
                ($_.DnsHostName -match "csn-") -or
                ($_.DnsHostName -match "CSN-") -or
                ($_.DnsHostName -match "abn-") -or
                ($_.DnsHostName -match "abn-")
            )
        }
    write-host "$domain `t $($ADComputers.count)"
    #$servers += $ADComputers.DnsHostName
    $servers += $ADComputers
    
}

Write-Host "Total Servers: $($servers.Count)" -ForegroundColor Yellow

$decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"



#------------------
$x = 0
$count = $servers.Count
foreach($line in $servers){
    $percent = "{0:N2}" -f ($x / $count * 100)

    Write-Progress -Activity "Check server in SCCM" -Status "In Progress($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server
    $server = $line.dnshostname
    $s=""
    $domain=""
    if($decomServers -contains $server){
        Write-Host "$server `t Decom Server" -ForegroundColor Yellow
        Add-Content -Path $outfile -Value "$server,Decom"
    }else{
        try{
            $s = ($server.Split("."))[0]
            $tmp = $server.Split(".")
            $domain = "$($tmp[1]).$($tmp[2]).$($tmp[3])"
        }catch{}
        
        
        $sccm = Get-CMDevice -Name $s
        
        $SCCMIsActive = ""
        $isclient = ""
        if($sccm.count){
            if($sccm.IsActive){
                $SCCMIsActive = $sccm.IsActive
            }else{
                $SCCMIsActive = "False"
            }
            $isclient = $sccm.isclient
        
            $LastActiveTime = $sccm.LastActiveTime
            
            $os = $line.OperatingSystem

            Add-Content -Path $outfile -Value "$server,Yes,$isclient,$SCCMIsActive,$LastActiveTime,$domain,$os"

            Write-Host "$server `t $SCCMIsActive"
        

        }else{
            Add-Content -Path $outfile -Value "$server,No"
            Write-Host "$server not in SCCM" -ForegroundColor Yellow
        }#if $sccm.count
    
    }#if decom

    $x++
}#foreach $servers

#$to = 'hs-sysadmin-windows-offshore@trizetto.com'
#$cc = 'Daniel.Villalobos@trizetto.com'
$to = 'pradeep.viswanathan@cognizant.com'
$cc = 'pradeep.viswanathan@trizetto.com'
$from = "SCCM@trizetto.com"
$subject = "SCCM Report - Check DC Vs SCCM Servers"
$body = "Extracted computer list from DC and checked each server in SCCM Server"
$smtp = "mail-2.trizetto.net"


Send-MailMessage -Attachments $outfile `
-To $to `
-Cc $cc `
-From $from `
-Subject $subject `
-Body $body `
-SmtpServer $smtp

