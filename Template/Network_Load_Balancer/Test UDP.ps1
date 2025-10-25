#UDP
$server = $NLBDNS
$port = 6380

$udpClient = New-Object System.Net.Sockets.UdpClient
$udpClient.Connect($server, $port)

# Send a test message
$message = [System.Text.Encoding]::ASCII.GetBytes("Hello UDP Server")
$udpClient.Send($message, $message.Length)

Write-Output "Message sent to $($server):$($port) via UDP"

$udpClient.Close()