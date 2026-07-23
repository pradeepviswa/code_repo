$inputlist = "$env:temp\server_inputlist.txt"

#Start with blank input list. 
new-item $inputlist -type file -Force | Out-Null

notepad $inputList
Write-Host "Press any key to continue..." -fo cyan
$HOST.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | OUT-NULL
$HOST.UI.RawUI.Flushinputbuffer()
Do

{
$Servers = Get-Content $inputlist
""
Write-Host "1.) Paste server list."
Write-Host "2.) Save and close file to continue."
Start-Sleep 3
""
}
Until ($Servers.length -ne $null)
ForEach ($Servers in $inputlist)
{
  Connect-V
               Invoke-Command -ComputerName $Servers -ScriptBlock { Set-NetAdapterAdvancedProperty -DisplayName 'Speed & Duplex' -DisplayValue '10 gbps Full Duplex' } -Credential Joshi.admin
} 