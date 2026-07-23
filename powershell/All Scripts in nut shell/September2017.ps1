
$ServersFile = import-csv "E:\AdminTools\Pradeep\Remediation\Sept2017.txt" -header ServerName
#$global:cred = Get-Credential
ForEach ($ServerLine in $ServersFile){
$Server = $($ServerLine.ServerName)
    Invoke-Command  -ComputerName $Server -Authentication Negotiate -ScriptBlock {
        param(
        [string] $Server
                )
        Write-Host "Updating Registry on $Server"
       hostname
        New-Item "HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX" -Force | Out-Null
        New-Item "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX"  -Force | Out-Null
        New-ItemProperty -path 'HKLM:\SOFTWARE\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX' -name 'iexplore.exe' -value '1' -PropertyType 'DWord' -Force | Out-Null
        New-ItemProperty -path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Internet Explorer\Main\FeatureControl\FEATURE_ENABLE_PRINT_INFO_DISCLOSURE_FIX' -name ' iexplore.exe' -value 1 -PropertyType 'DWord' -Force | Out-Null
        
     
        Write-Host "Completed Updating Registry on $Server"
        } -ArgumentList $Server
}


