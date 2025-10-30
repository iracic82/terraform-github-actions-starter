#!/bin/bash
# Basic user data script for Amazon Linux 2
# This runs on first boot

# Update system
yum update -y

# Install basic tools
yum install -y git curl wget htop

# Install Docker (optional)
# amazon-linux-extras install docker -y
# systemctl start docker
# systemctl enable docker
# usermod -a -G docker ec2-user

# Install Node.js (optional)
# curl -sL https://rpm.nodesource.com/setup_18.x | bash -
# yum install -y nodejs

# Create a simple web server for testing
cat > /tmp/server.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import socket

class SimpleHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/html')
        self.end_headers()
        hostname = socket.gethostname()
        html = f"""
        <html>
        <body>
        <h1>Hello from AWS Dev Environment!</h1>
        <p>Hostname: {hostname}</p>
        <p>This server is managed by Terraform</p>
        </body>
        </html>
        """
        self.wfile.write(html.encode())

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 5000), SimpleHandler)
    print('Server running on port 5000...')
    server.serve_forever()
EOF

chmod +x /tmp/server.py

# Run the web server in the background (optional)
# nohup python3 /tmp/server.py > /tmp/server.log 2>&1 &

echo "User data script completed successfully" > /tmp/user-data-complete.txt
