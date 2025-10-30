#!/bin/bash
# Production user data script for Amazon Linux 2

# Update system
yum update -y

# Install basic tools
yum install -y git curl wget htop amazon-cloudwatch-agent

# Configure CloudWatch agent (optional)
# /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
#   -a fetch-config \
#   -m ec2 \
#   -s \
#   -c ssm:AmazonCloudWatch-Config

# Install Docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Create production web server
cat > /opt/production-server.py << 'EOF'
#!/usr/bin/env python3
from http.server import HTTPServer, BaseHTTPRequestHandler
import socket
import json
from datetime import datetime

class ProductionHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {
            'status': 'healthy',
            'environment': 'production',
            'hostname': socket.gethostname(),
            'timestamp': datetime.now().isoformat()
        }
        self.wfile.write(json.dumps(response).encode())

    def log_message(self, format, *args):
        # Custom logging for production
        with open('/var/log/web-server.log', 'a') as f:
            f.write(f"{datetime.now().isoformat()} - {format % args}\n")

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 5000), ProductionHandler)
    print('Production server running on port 5000...')
    server.serve_forever()
EOF

chmod +x /opt/production-server.py

# Create systemd service for production
cat > /etc/systemd/system/web-server.service << 'EOF'
[Unit]
Description=Production Web Server
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt
ExecStart=/usr/bin/python3 /opt/production-server.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable web-server
systemctl start web-server

echo "Production user data script completed successfully" > /tmp/user-data-complete.txt
