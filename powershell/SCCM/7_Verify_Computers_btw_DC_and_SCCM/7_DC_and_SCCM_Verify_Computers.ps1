Import-Module ConfigurationManager
Set-Location csn:

$outfile = "E:\AdminTools\SCCM_Script\7_Verify_Computers_btw_DC_and_SCCM\Output.csv"
Remove-Item -Path $outfile -ErrorAction SilentlyContinue 
New-Item -ItemType File -Path $outfile | Out-Null
Set-Content -Path $outfile -Value "Server,Discovered_In_SCCM,Clietn_Installed,Active_in_SCCM,LastActiveTime,Domain"

$servers = Get-Content "E:\AdminTools\SCCM_Script\7_Verify_Computers_btw_DC_and_SCCM\Input.txt"

$decomServers = Get-Content "E:\AdminTools\PatchingMW\MW_Scripts\Input\DecomServers.txt"

$x = 0
$count = $servers.Count
foreach($server in $servers){
    $percent = "{0:N2}" -f ($x / $count * 100)

    Write-Progress -Activity "Check server in SCCM" -Status "In Progress($x of $count)...$percent%" -PercentComplete $percent -CurrentOperation $server

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

            Add-Content -Path $outfile -Value "$server,Yes,$isclient,$SCCMIsActive,$LastActiveTime,$domain"

            Write-Host "$server `t $SCCMIsActive"
        

        }else{
            Add-Content -Path $outfile -Value "$server,No"
            Write-Host "$server not in SCCM" -ForegroundColor Red
        }#if $sccm.count
    
    }#if decom

    $x++
}#foreach $servers

$to = “Pranay.Burbure@cognizant.com”, “Manoj.Chavan2@cognizant.com”,”Amardip.Deshpande@cognizant.com”, “Madhusudhan.Deshpande@cognizant.com”, “Abhijeet.Joshi5@cognizant.com”, “Santosh.Kadam@cognizant.com”, “Vighnesh.Kambli@cognizant.com”, “Mahesh.Limaye@cognizant.com”, “Parag.Naik@cognizant.com”, “PRADEEP.VISWANATHAN@cognizant.com”
$cc = 'pradeep.viswanathan@cognizant.com'
$from = "automated-script@trizetto.com"
$subject = "SCCM Report - SCCM Client Status in SCCM Servers"
$body = "Checked each server in SCCM Server"
$smtp = "mail-2.trizetto.net"

Send-MailMessage -Attachments $outfile `
-To $to `
-Cc $cc `
-From $from `
-Subject $subject `
-Body $body `
-SmtpServer $smtp

