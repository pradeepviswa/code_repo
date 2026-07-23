$dir = Split-Path $Script:Myinvocation.mycommand.path
Set-Location -Path $dir

$outFile = "$dir\Output-ComponentService-ValueREVERT.csv"
Remove-Item -Path $outFile -Force -ErrorAction SilentlyContinue
New-Item -ItemType file -Path $outFile | Out-Null
Set-Content -Path $outFile -Value "Server,Status,EnableDCOM,LegacyAuthenticationLevel,LegacyImpersonationLevel"
$servers = Import-Csv -Path .\Input.csv


$count = $servers.Count
if($count -lt 1){
    $count = 1
}
$x = 0

foreach($s in $servers){
    $server = $s.Server
    $EnableDCOM = $s.BeforeCHG_EnableDCOM
    $LegacyAuthenticationLevel = $s.BeforeCHG_LegacyAuthenticationLevel
    $LegacyImpersonationLevel = $s.BEforeCHG_LegacyImpersonationLevel
    
    $x++
    $percent = "{0:N2}" -f ($x / $count * 100)
    Write-Progress -Activity "Component Service value REVERT" -Status "Progress $x of $count...$percent%" -PercentComplete $percent -CurrentOperation $server

    if (Test-Connection -ComputerName $server -Count 1 -Quiet){

        try{
            $EnableDCOM_Existing = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock {(Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name EnableDCOM).EnableDCOM } -ErrorAction SilentlyContinue
            $LegacyAuthenticationLevel_Existing = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock { (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name LegacyAuthenticationLevel).LegacyAuthenticationLevel} -ErrorAction SilentlyContinue
            $LegacyImpersonationLevel_Existing = Invoke-Command  -ComputerName $server -Authentication Negotiate -ScriptBlock { (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name LegacyImpersonationLevel).LegacyImpersonationLevel} -ErrorAction SilentlyContinue

            $keyobjs = Invoke-Command -ArgumentList $EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel,$EnableDCOM_Existing,$LegacyAuthenticationLevel_Existing,$LegacyImpersonationLevel_Existing -ComputerName $server -Authentication Negotiate -ScriptBlock {
                Param(
                $EnableDCOM = $EnableDCOM,
                $LegacyAuthenticationLevel = $LegacyAuthenticationLevel,
                $LegacyImpersonationLevel = $LegacyImpersonationLevel,
                $EnableDCOM_Existing = $EnableDCOM_Existing,
                $LegacyAuthenticationLevel_Existing = $LegacyAuthenticationLevel_Existing,
                $LegacyImpersonationLevel_Existing = $LegacyImpersonationLevel_Existing
                )
                if( ($EnableDCOM_Existing -eq $null) ){
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "EnableDCOM" -Value "$EnableDCOM"
                }else{
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "EnableDCOM" -Value "$EnableDCOM"
                }

                if($LegacyAuthenticationLevel_Existing -eq $null){
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "LegacyAuthenticationLevel" -Value "$LegacyAuthenticationLevel" -PropertyType DWord
                }else{
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "LegacyAuthenticationLevel" -Value "$LegacyAuthenticationLevel"
                }

                if($LegacyImpersonationLevel_Existing -eq $null){
                    New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "LegacyImpersonationLevel" -Value "$LegacyImpersonationLevel" -PropertyType DWord
                }else{
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Ole" -Name "LegacyImpersonationLevel" -Value "$LegacyImpersonationLevel"
                }

                    
            } # invoke-command
            Write-Host "$server `t Registry Modified. Reboot Required `t Values:$EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel" -ForegroundColor Yellow
            Add-Content -Path $outFile -Value "$server,Registry Modified. Reboot Required,$EnableDCOM,$LegacyAuthenticationLevel,$LegacyImpersonationLevel"
            
        
        }catch{
                Write-Host "$server `t Connection Error" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Connection Error,-,-,-"
        }
    
    }else{
                Write-Host "$server `t Connection Error" -ForegroundColor Red
                Add-Content -Path $outFile -Value "$server,Connection Error,-,-,-"
    }

}



#$to = "Burbure, Pranay (Cognizant) <Pranay.Burbure@cognizant.com>","Chavan, Manoj (Cognizant) <Manoj.Chavan2@cognizant.com>","Deshpande, Amardip (Cognizant) <Amardip.Deshpande@cognizant.com>","Deshpande, Madhusudhan (Cognizant) <Madhusudhan.Deshpande@cognizant.com>","Joshi, Abhijeet (Cognizant) <Abhijeet.Joshi5@cognizant.com>","Kadam, Santosh (Cognizant) <Santosh.Kadam@cognizant.com>","Kambli, Vighnesh (Cognizant) <Vighnesh.Kambli@cognizant.com>","Kharge, Dhananjay (Cognizant) <Dhananjay.Kharge@cognizant.com>","Limaye, Mahesh (Cognizant) <Mahesh.Limaye@cognizant.com>","More, Dinesh (Cognizant) <Dinesh.More3@cognizant.com>","Mulik, Sachin (Cognizant) <Sachin.Mulik@cognizant.com>","Naik, Parag (Cognizant) <Parag.Naik@cognizant.com>","Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
#$to = "Viswanathan, Pradeep (Cognizant) <PRADEEP.VISWANATHAN@cognizant.com>"
#$to = "CISTZInfraWindowsOperations@cognizant.com"
#$from = "MWNoreplyHOC2@cognizant.com"
#Send-MailMessage -Attachments $outFile -To $to -From $from -SmtpServer 'mail-2.trizetto.net' -Subject 'Component-Service Value REVERT' -BodyAsHtml "PFA File"


