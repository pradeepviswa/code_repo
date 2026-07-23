$ServersFile = import-csv "E:\AdminTools\Pradeep\Remediation\Sweet32.txt" -header ServerName
$outfile = "E:\SecRemediationScripts\output.txt"
New-Item -ItemType File -Path $outfile -Force | Out-Null
#$global:cred = Get-Credential
ForEach ($ServerLine in $ServersFile){
    $Server = $($ServerLine.ServerName)
    try{
        Invoke-Command  -ComputerName $Server -Authentication Negotiate -ScriptBlock {
        param(
        [string] $Server
                )
        # Re-create the ciphers key.
        #New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers' -Force | Out-Null
        # Disable insecure/weak ciphers.
        $insecureCiphers = @(
            'Triple DES 168',
            'Triple DES 168/168'
        )
        Foreach ($insecureCipher in $insecureCiphers) {
            $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($insecureCipher)
            $key.SetValue('Enabled', 0, 'DWord')
            $key.close()
            Write-Host $Server "Weak cipher $insecureCipher has been disabled."
  
        }

            } -ArgumentList $Server

            
            Add-Content -Path $outfile -Value "$Server Weak cipher $insecureCipher has been disabled."
    }catch{
        Add-Content -Path $outfile -Value "$Server Error"
    }


}
