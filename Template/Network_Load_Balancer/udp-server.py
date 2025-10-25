#!/usr/bin/env python
import socket
import sys

# Server configuration
UDP_IP = '0.0.0.0'
UDP_PORT = 6380
# Use a unique message to identify this specific server instance
MESSAGE = b'Hello from UDP server #1!'

# Create a UDP socket
try:
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    sock.bind((UDP_IP, UDP_PORT))
    print(f"UDP Server listening on {UDP_IP}:{UDP_PORT}")

    while True:
        # Wait for data (packet size 1024)
        data, addr = sock.recvfrom(1024) 
        
        # Print the received message
        print("received message: %s" % data.decode())
        
        # Send a response back to the client's address
        sock.sendto(MESSAGE, addr)

except socket.error as e:
    print(f"Socket error: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("\nServer shutting down.")
    sock.close()
    sys.exit(0)