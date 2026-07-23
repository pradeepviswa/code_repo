 $servers="csn-svc-util-08.services.tzghosting.net","csn-svc-util-07.services.tzghosting.net"
 
  foreach($server in $servers){
  
 $a=Get-WmiObject -Class win32_computerSystem -ComputerName $server | select -Property name,model
 $name=$a.name
 $mode= $a.model
  Write-Host "$name  $model"
}
