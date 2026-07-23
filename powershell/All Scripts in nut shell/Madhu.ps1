$inputlist = "c:\temp\names.txt"
$Servers = Get-Content $inputlist

ForEach ($serv in $Servers)
{
 echo  $serv


             Invoke-Command -ComputerName $serv -ScriptBlock { Set-NetAdapterAdvancedProperty -DisplayName 'Speed & Duplex' -DisplayValue '10 gbps Full Duplex' } -Credential Joshi.admin
}
