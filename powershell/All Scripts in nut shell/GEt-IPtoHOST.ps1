$results = @() 
 
Foreach ($c in Get-Content C:\Users\joshi.admin\EMB\EMB.txt) 
{ 
trap { continue; } 
$IPaddress = $c 
$FQDN = [System.Net.Dns]::GetHostEntry("$c")| Select-Object HostName 
 
$out = New-Object psobject 
$out | Add-Member -NotePropertyName IP $IPaddress 
$out | Add-Member -NotePropertyName DNS $FQDN 
 
$results += $out 
} 
 
$results | Export-Csv -NoTypeInformation -Path C:\Users\joshi.admin\EMB\EMB.csv 