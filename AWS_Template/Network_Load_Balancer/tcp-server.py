#!/usr/bin/env python
import socket
import sys

# Server configuration
TCP_IP = '0.0.0.0'
TCP_PORT = 6381
BUFFER_SIZE = 20 # Small buffer for testing fast response

# Create a TCP/IP socket
try:
    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.bind((TCP_IP, TCP_PORT))
    s.listen(1)
    print(f"TCP Server listening on {TCP_IP}:{TCP_PORT}")

    while True:
        # Wait for a connection
        conn, addr = s.accept()
        print('Connection address:', addr)
        
        # Handle connection
        while True:
            # Receive data
            data = conn.recv(BUFFER_SIZE)
            if not data:
                break
            
            # Print received data and echo it back
            print('received data:', data.decode())
            response = f'Returned from TCP server #1: {data.decode()}'
            conn.sendall(response.encode())
        
        # Close the connection
        conn.close()

except socket.error as e:
    print(f"Socket error: {e}")
    sys.exit(1)
except KeyboardInterrupt:
    print("\nServer shutting down.")
    s.close()
    sys.exit(0)