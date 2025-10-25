
#TEST TCP
$server = $NLBDNS
$port = 6381

$tcp = New-Object System.Net.Sockets.TcpClient
$tcp.Connect($server, $port)

$stream = $tcp.GetStream()
$reader = New-Object System.IO.StreamReader($stream)
$writer = New-Object System.IO.StreamWriter($stream)

# Send a message
$writer.WriteLine("Hello TCP Server")
$writer.Flush()

# Read response
$response = $reader.ReadLine()
Write-Output "Server replied: $response"

# Close connection
$reader.Close()
$writer.Close()
$tcp.Close()
