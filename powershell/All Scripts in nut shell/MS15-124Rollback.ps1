
$ServersFile = import-csv "E:\AdminTools\Remediation\MS15-124.txt" -header ServerName
#$global:cred = Get-Credential
ForEach ($ServerLine in $ServersFile){
$Server = $($ServerLine.ServerName)
    Invoke-Command  -ComputerName $Server -Authentication Negotiate -ScriptBlock {
        param(
        [string] $Server
                )
        Write-Host "Updating Registry on $Server"
       hostname
        Remove-Item "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" -Force | Out-Null
        Remove-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING" -Force | Out-Null
        Remove-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -name ' iexplore.exe' -value '1' -PropertyType 'DWord' -Force | Out-Null
        Remove-ItemProperty -path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ALLOW_USER32_EXCEPTION_HANDLER_HARDENING' -name ' iexplore.exe' -value 1 -PropertyType 'DWord' -Force | Out-Null
              
        Write-Host "Completed Updating Registry on $Server"
        } -ArgumentList $Server
}


