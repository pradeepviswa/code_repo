$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir

$outFile = "$dir\Output-ComponentService-ValuejustCheck.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Status,BeforeCHG_EnableDCOM,BeforeCHG_LegacyAuthenticationLevel,BEforeCHG_LegacyImpersonationLevel"
$servers = Get-Content -Path .\Input-ServerName.txt

#create blank array to store problem servers
$problemList = @()

$count = $servers.Count
$x = 0
foreach($server in $servers){
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Just Check Component Service value" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $server

    if (Test-Connection -ComputerName $server -Count 1 -Quiet){
        $EnableDCOM = ""
        $LegacyAuthenticationLevel = ""
        $LegacyImpersonationLevel = ""

        try{
            $EnableDCOM = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock {(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name EnableDCOM).EnableDCOM } -ErrorAction SilentlyContinue
            $LegacyAuthenticationLevel = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock { (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name LegacyAuthenticationLevel).LegacyAuthenticationLevel} -ErrorAction SilentlyContinue
            $LegacyImpersonationLevel = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock { (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name LegacyImpersonationLevel).LegacyImpersonationLevel} -ErrorAction SilentlyContinue
            $flag = ($EnableDCOM -eq "Y") -and ($LegacyAuthenticationLevel -eq $null) -and ($LegacyImpersonationLevel -eq "2")
            if($LegacyAuthenticationLevel -ne $null){
                $flag = $LegacyAuthenticationLevel -eq "2"
            }
            if($flag){
                Write-Host "$server `t No Change required"
                Add-Content -Path $outFile -Value "$server,No Change required,$EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel"
            }else{

                Write-Host "$server `t Values: $EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel `t Change Required" -ForegroundColor Yellow
                Add-Content -Path $outFile -Value "$server,Change Required,$EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel"
                $problemList += "$server,Change Required,$EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel"
            }
        
        }catch{
                Write-Host "$server `t Connection Error" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,-,-,-,Connection Error"
        }
    
    }else{
                Write-Host "$server `t Ping Failed" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,-,-,-,Ping Failed"
    }

}



#$to = "Chavan, Manoj (Cognizant) <Manoj.Chavan2@cognizant.com>","Deshpande, Amardip (Cognizant) <Amardip.Deshpande@cognizant.com>","Deshpande, Madhusudhan (Cognizant) <Madhusudhan.Deshpande@cognizant.com>","Joshi, Abhijeet (Cognizant) <Abhijeet.Joshi5@cognizant.com>","Kadam, Santosh (Cognizant) <Santosh.Kadam@cognizant.com>","Kambli, Vighnesh (Cognizant) <Vighnesh.Kambli@cognizant.com>","Kharge, Dhananjay (Cognizant) <Dhananjay.Kharge@cognizant.com>","Limaye, Mahesh (Cognizant) <Mahesh.Limaye@cognizant.com>","More, Dinesh (Cognizant) <Dinesh.More3@cognizant.com>","Mulik, Sachin (Cognizant) <Sachin.Mulik@cognizant.com>","Naik, Parag (Cognizant) <Parag.Naik@cognizant.com>","Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
#$to = "Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
#$to = "CISTZInfraWindowsOperations@cognizant.com"
#$from = 'MWNoreplyHOC2@cognizant.com'
$loopServers = ""
foreach($line in $problemList){
    $splitLine = $line.split(",")
    
    $loopServers += "<tr><Td> $($splitLine[0]) </td><Td> $($splitLine[1]) </td><Td> $($splitLine[2]) </td><Td> $($splitLine[3]) </td><Td> $($splitLine[4]) </td></tr>"

}
$body = "
<center>
    <b> Change Componenet value on these Servers </b> <br>
    Input : <b> $count Servers </b> <br>
    Reg. Change required on : <b> $($problemList.Count) Servers </b> <br>
    <i>
    (Registry path: HKLM:\SOFTWARE\Microsoft\Ole <br>
    Current values mentioned below, this will be used to revert the change.)
    </i>
    <br> <br> <br>

    <table border=1 align=center>
        <Tr bgcolor=#552211>
            <td>Server</td>
            <td>Change Required</td>
            <td>EnableDCOM</td>
            <td>LegacyAuthenticationLevel</td>
            <td>LegacyImpersonationLevel</td>
        </tr>
    $loopServers
    </table>
</center>

"
#Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer 'mail-2.trizetto.net' -Subject 'Component-Service Value Just Check. Do not Modify' -BodyAsHtml $body



