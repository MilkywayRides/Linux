#!/bin/bash
set -e

echo "Installing BlazeNeuro GUI..."

# Copy to system
cp -r gui /opt/blazeneuro/
chmod +x /opt/blazeneuro/gui/terminal/jarvis.sh
chmod +x /opt/blazeneuro/gui/web/start.sh

# Create launcher
cat > /usr/local/bin/blazeneuro << 'EOF'
#!/bin/bash
/opt/blazeneuro/gui/terminal/jarvis.sh
EOF
chmod +x /usr/local/bin/blazeneuro

# Auto-start on boot
echo "/usr/local/bin/blazeneuro" >> /etc/profile

echo "✓ GUI installed! Run 'blazeneuro' to launch"
