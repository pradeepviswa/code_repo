$ServersFile = import-csv "E:\AdminTools\Pradeep\Remediation\Weak.txt" -header ServerName
#$global:cred = Get-Credential
ForEach ($ServerLine in $ServersFile){
$Server = $($ServerLine.ServerName)
Invoke-Command  -ComputerName $Server -Authentication Negotiate -ScriptBlock {
param(
[string] $Server
        )
# Re-create the ciphers key.
#New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers' -Force | Out-Null
# Disable insecure/weak ciphers.
$insecureCiphers = @(
  'RC4 40/128',
  'RC4 56/128',
  #'RC4 64/128',
  'RC4 128/128'
)
Foreach ($insecureCipher in $insecureCiphers) {
  $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($insecureCipher)
  $key.SetValue('Enabled', 0, 'DWord')
  $key.close()
  Write-Host $Server "Weak cipher $insecureCipher has been disabled."
}

    } -ArgumentList $Server
}
