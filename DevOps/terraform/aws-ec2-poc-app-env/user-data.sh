#!/bin/bash
set -e

# Update system
sudo yum update -y

# Install Git
sudo yum install -y git

# Install Docker using Amazon Linux extras (official method)
echo "Installing Docker via amazon-linux-extras..."
sudo amazon-linux-extras install docker -y

# Install Docker plugins via yum (native method)
echo "Installing Docker plugins..."
sudo yum install -y docker-buildx-plugin docker-compose-plugin || echo "Docker plugins not available via yum, will use manual installation"

sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Wait for Docker daemon to be ready
echo "Waiting for Docker daemon to start..."
until sudo docker info > /dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 2
done
echo "Docker daemon is ready"

# Install Docker Compose (Plugin version - recommended)
echo "Installing Docker Compose..."
# Try native installation first, fallback to manual if not available
if ! sudo docker compose version > /dev/null 2>&1; then
  echo "Docker Compose not available via package manager, installing manually..."
  mkdir -p ~/.docker/cli-plugins
  sudo mkdir -p /usr/local/lib/docker/cli-plugins

  # Download and install Docker Compose plugin with retry logic
  COMPOSE_URL="https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64"
  MAX_RETRIES=3
  RETRY_COUNT=0

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if sudo curl -fSL "$COMPOSE_URL" -o /tmp/docker-compose && [ -f /tmp/docker-compose ] && [ -s /tmp/docker-compose ]; then
      sudo mv /tmp/docker-compose /usr/local/lib/docker/cli-plugins/docker-compose
      sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
      echo "Docker Compose plugin installed successfully"
      break
    else
      RETRY_COUNT=$((RETRY_COUNT + 1))
      echo "Download attempt $RETRY_COUNT failed, retrying..."
      sleep 2
    fi
  done

  # Verify plugin installation
  if [ ! -x /usr/local/lib/docker/cli-plugins/docker-compose ]; then
    echo "WARNING: Docker Compose plugin installation failed, trying direct installation..."
    sudo curl -fSL "$COMPOSE_URL" -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
  fi

  # Also install as standalone binary for compatibility
  sudo curl -fSL "$COMPOSE_URL" -o /usr/local/bin/docker-compose
  sudo chmod +x /usr/local/bin/docker-compose
else
  echo "Docker Compose already installed via package manager"
fi

# Install Docker Buildx (version 0.17+ required for compose build)
echo "Installing Docker Buildx (version 0.17+)..."
mkdir -p ~/.docker/cli-plugins
sudo mkdir -p /usr/local/lib/docker/cli-plugins

# Check if Buildx is installed and get version
BUILDX_NEEDS_UPGRADE=false
if sudo docker buildx version > /dev/null 2>&1; then
  BUILDX_VERSION_OUTPUT=$(sudo docker buildx version 2>/dev/null)
  BUILDX_VERSION=$(echo "$BUILDX_VERSION_OUTPUT" | grep -o 'v[0-9]\+\.[0-9]\+' | head -1 | sed 's/v//' || echo "0.0")
  echo "Current Buildx version: $BUILDX_VERSION"
  
  # Compare version (check if it's less than 0.17)
  VERSION_MAJOR=$(echo "$BUILDX_VERSION" | cut -d. -f1)
  VERSION_MINOR=$(echo "$BUILDX_VERSION" | cut -d. -f2)
  
  if [ "$VERSION_MAJOR" -eq 0 ] && [ "$VERSION_MINOR" -lt 17 ]; then
    echo "Buildx version $BUILDX_VERSION is older than required 0.17, upgrading..."
    BUILDX_NEEDS_UPGRADE=true
  elif [ "$VERSION_MAJOR" -gt 0 ] || ([ "$VERSION_MAJOR" -eq 0 ] && [ "$VERSION_MINOR" -ge 17 ]); then
    echo "Buildx version $BUILDX_VERSION meets requirement (>= 0.17)"
  fi
else
  echo "Buildx not found, installing..."
  BUILDX_NEEDS_UPGRADE=true
fi

# Install or upgrade Buildx to 0.17+ if needed
if [ "$BUILDX_NEEDS_UPGRADE" = true ]; then
  echo "Installing/upgrading Buildx to latest version (0.17+)..."
  
  # Remove old buildx installations from all locations to avoid conflicts
  echo "Removing old Buildx installations..."
  sudo rm -f /usr/libexec/docker/cli-plugins/docker-buildx
  sudo rm -f /usr/lib/docker/cli-plugins/docker-buildx
  sudo rm -f /usr/local/lib/docker/cli-plugins/docker-buildx
  rm -f ~/.docker/cli-plugins/docker-buildx
  
  # Remove buildx plugin package if installed via yum (to avoid conflicts)
  sudo yum remove -y docker-buildx-plugin 2>/dev/null || echo "No docker-buildx-plugin package to remove"
  
  # Get latest Buildx version from GitHub releases
  BUILDX_VERSION=$(curl -s https://api.github.com/repos/docker/buildx/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v0.17.0")
  echo "Latest Buildx version: $BUILDX_VERSION"
  
  # Download latest buildx with retry logic
  BUILDX_URL="https://github.com/docker/buildx/releases/download/${BUILDX_VERSION}/buildx-${BUILDX_VERSION}.linux-amd64"
  MAX_RETRIES=3
  RETRY_COUNT=0

  while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if sudo curl -fL "$BUILDX_URL" -o /tmp/docker-buildx && [ -f /tmp/docker-buildx ] && [ -s /tmp/docker-buildx ]; then
      # Install to multiple locations to ensure Docker finds it
      sudo mkdir -p /usr/local/lib/docker/cli-plugins
      sudo cp /tmp/docker-buildx /usr/local/lib/docker/cli-plugins/docker-buildx
      sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx
      
      # Also install to system location (Docker checks this first)
      sudo mkdir -p /usr/libexec/docker/cli-plugins
      sudo cp /tmp/docker-buildx /usr/libexec/docker/cli-plugins/docker-buildx
      sudo chmod +x /usr/libexec/docker/cli-plugins/docker-buildx
      
      echo "Docker Buildx installed/upgraded successfully"
      break
    else
      RETRY_COUNT=$((RETRY_COUNT + 1))
      echo "Buildx download attempt $RETRY_COUNT failed, trying alternative URL..."
      # Try alternative URL format
      BUILDX_URL="https://github.com/docker/buildx/releases/latest/download/buildx-linux-amd64"
      sleep 2
    fi
  done

  # Also install to home directory for ec2-user
  curl -fL "$BUILDX_URL" -o ~/.docker/cli-plugins/docker-buildx 2>/dev/null || true
  chmod +x ~/.docker/cli-plugins/docker-buildx 2>/dev/null || true
  
  # Restart Docker to pick up new plugin
  sudo systemctl restart docker
  sleep 3
  
  # Final verification
  if sudo docker buildx version > /dev/null 2>&1; then
    FINAL_VERSION_OUTPUT=$(sudo docker buildx version 2>/dev/null)
    FINAL_VERSION=$(echo "$FINAL_VERSION_OUTPUT" | grep -o 'v[0-9]\+\.[0-9]\+' | head -1 | sed 's/v//' || echo "unknown")
    echo "Buildx installation verified: version $FINAL_VERSION"
    
    # Verify it's at least 0.17
    VERSION_MAJOR=$(echo "$FINAL_VERSION" | cut -d. -f1)
    VERSION_MINOR=$(echo "$FINAL_VERSION" | cut -d. -f2)
    if [ "$VERSION_MAJOR" -eq 0 ] && [ "$VERSION_MINOR" -lt 17 ]; then
      echo "WARNING: Buildx version $FINAL_VERSION is still less than 0.17"
    else
      echo "✓ Buildx version $FINAL_VERSION meets requirement (>= 0.17)"
    fi
  else
    echo "WARNING: Buildx verification failed"
  fi
else
  echo "Buildx already at required version (>= 0.17)"
fi

# Set up buildx builder instance
# Note: This needs to run after Docker is started and user is in docker group
# We'll create a script that runs on first login
cat > /tmp/setup-buildx.sh << 'BUILDX_EOF'
#!/bin/bash
# Wait for Docker to be ready
until docker info > /dev/null 2>&1; do
  sleep 1
done

# Create and use buildx builder
docker buildx version
docker buildx create --name mybuilder --use 2>/dev/null || docker buildx use mybuilder
docker buildx inspect --bootstrap
BUILDX_EOF
chmod +x /tmp/setup-buildx.sh
sudo mv /tmp/setup-buildx.sh /usr/local/bin/setup-buildx.sh

# Add to ec2-user's bashrc to run on login (only once)
echo 'if [ ! -f ~/.buildx-setup-done ]; then /usr/local/bin/setup-buildx.sh && touch ~/.buildx-setup-done; fi' | sudo tee -a /home/ec2-user/.bashrc

# Verify installations
echo "Verifying installations..."
git --version || echo "Git check failed"
docker --version || echo "Docker check failed"

# Verify Docker Compose works
echo "Verifying Docker Compose..."
# During user-data, we need to use sudo or check if command exists
if sudo docker compose version > /dev/null 2>&1; then
  echo "Docker Compose plugin is working"
  sudo docker compose version
elif sudo docker-compose version > /dev/null 2>&1; then
  echo "Docker Compose standalone is working"
  sudo docker-compose version
elif [ -x /usr/local/lib/docker/cli-plugins/docker-compose ]; then
  echo "Docker Compose plugin installed successfully"
  /usr/local/lib/docker/cli-plugins/docker-compose version
elif [ -x /usr/local/bin/docker-compose ]; then
  echo "Docker Compose standalone installed successfully"
  /usr/local/bin/docker-compose version
else
  echo "WARNING: Docker Compose verification failed"
fi

# Test Docker Compose with a minimal command
echo "Testing Docker Compose functionality..."
# Ensure Docker is ready before testing
until sudo docker info > /dev/null 2>&1; do
  sleep 1
done

cat > /tmp/test-compose.yml << 'TEST_EOF'
services:
  test:
    image: alpine:latest
    command: echo "test"
TEST_EOF

# Test both plugin and standalone versions
if sudo docker compose -f /tmp/test-compose.yml config > /dev/null 2>&1; then
  echo "Docker Compose plugin test passed"
  rm -f /tmp/test-compose.yml
elif sudo docker-compose -f /tmp/test-compose.yml config > /dev/null 2>&1; then
  echo "Docker Compose standalone test passed"
  rm -f /tmp/test-compose.yml
else
  echo "WARNING: Docker Compose test failed - may need manual verification"
  rm -f /tmp/test-compose.yml
fi

# Verify Buildx (optional, will be configured on first login)
docker buildx version > /dev/null 2>&1 && echo "Buildx is available" || echo "Buildx will be configured on first login"

# Create a simple test page (optional)
sudo mkdir -p /var/www/html
echo "<h1>EC2 Instance is Ready!</h1><p>Git, Docker, and Docker Compose are installed.</p>" | sudo tee /var/www/html/index.html

# Start a simple HTTP server (optional - for testing)
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd

