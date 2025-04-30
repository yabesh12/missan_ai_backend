#!/bin/bash

# Define colors for success and error messages
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Update the system
echo "Updating system..."
if sudo apt-get update -y && sudo apt-get upgrade -y; then
    echo -e "${GREEN}System updated successfully.${NC}"
else
    echo -e "${RED}Error updating system.${NC}"
fi

# Install dependencies
echo "Installing dependencies..."
if ! dpkg -l | grep -q curl; then
    if sudo apt-get install -y curl apt-transport-https ca-certificates software-properties-common; then
        echo -e "${GREEN}Dependencies installed successfully.${NC}"
    else
        echo -e "${RED}Error installing dependencies.${NC}"
    fi
else
    echo -e "${GREEN}Dependencies already installed.${NC}"
fi

# Install Docker
echo "Installing Docker..."
if ! command -v docker &>/dev/null; then
    if curl -fsSL https://get.docker.com -o get-docker.sh && sudo sh get-docker.sh; then
        echo -e "${GREEN}Docker installed successfully.${NC}"
    else
        echo -e "${RED}Error installing Docker.${NC}"
    fi
else
    echo -e "${GREEN}Docker is already installed.${NC}"
fi

# Add user to Docker group (to avoid using sudo every time)
if ! groups $USER | grep -q docker; then
    if sudo usermod -aG docker $USER; then
        echo -e "${GREEN}User added to Docker group successfully.${NC}"
    else
        echo -e "${RED}Error adding user to Docker group.${NC}"
    fi
else
    echo -e "${GREEN}User is already in Docker group.${NC}"
fi

# Install Docker Compose
echo "Installing Docker Compose..."
DOCKER_COMPOSE_VERSION="1.29.2"
if ! command -v docker-compose &>/dev/null; then
    if sudo curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose; then
        echo -e "${GREEN}Docker Compose installed successfully.${NC}"
    else
        echo -e "${RED}Error installing Docker Compose.${NC}"
    fi
else
    echo -e "${GREEN}Docker Compose is already installed.${NC}"
fi

# Install K3s (Lightweight Kubernetes)
echo "Installing K3s..."
if ! command -v k3s &>/dev/null; then
    if curl -sfL https://get.k3s.io | sh -; then
        echo -e "${GREEN}K3s installed successfully.${NC}"
    else
        echo -e "${RED}Error installing K3s.${NC}"
    fi
else
    echo -e "${GREEN}K3s is already installed.${NC}"
fi

# Export Kube config to use kubectl
if ! [ -f ~/.kube/config ]; then
    if sudo mkdir -p ~/.kube && sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config && sudo chown $(id -u):$(id -g) ~/.kube/config; then
        echo -e "${GREEN}Kube config set successfully.${NC}"
    else
        echo -e "${RED}Error setting Kube config.${NC}"
    fi
else
    echo -e "${GREEN}Kube config is already set.${NC}"
fi

# Install Python 3 and pip (if not installed)
echo "Installing Python 3 and pip..."
if ! command -v python3 &>/dev/null; then
    if sudo apt-get install -y python3 python3-pip python3-dev; then
        echo -e "${GREEN}Python 3 and pip installed successfully.${NC}"
    else
        echo -e "${RED}Error installing Python 3 and pip.${NC}"
    fi
else
    echo -e "${GREEN}Python 3 is already installed.${NC}"
fi

# Install virtualenv
echo "Installing virtualenv..."
if ! command -v virtualenv &>/dev/null; then
    if sudo pip3 install virtualenv; then
        echo -e "${GREEN}Virtualenv installed successfully.${NC}"
    else
        echo -e "${RED}Error installing virtualenv.${NC}"
    fi
else
    echo -e "${GREEN}Virtualenv is already installed.${NC}"
fi

# Install PostgreSQL
echo "Installing PostgreSQL..."
if ! command -v psql &>/dev/null; then
    if sudo apt-get install -y postgresql postgresql-contrib; then
        echo -e "${GREEN}PostgreSQL installed successfully.${NC}"
    else
        echo -e "${RED}Error installing PostgreSQL.${NC}"
    fi
else
    echo -e "${GREEN}PostgreSQL is already installed.${NC}"
fi

# Set up PostgreSQL database
echo "Setting up PostgreSQL database..."
sudo -u postgres psql -c "CREATE DATABASE my_database;"
sudo -u postgres psql -c "CREATE USER my_user WITH PASSWORD 'my_password';"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE my_database TO my_user;"
echo -e "${GREEN}PostgreSQL database and user set up successfully.${NC}"

# Clone or pull your project from GitHub or copy it manually (You can skip this step if you already have your project files)
# git clone <YOUR_PROJECT_URL>

# Navigate to the project directory
cd ~/missan_ai_backend  # Replace with your project directory

# Install Python dependencies from requirements.txt
echo "Installing Python dependencies..."
if [ -f requirements.txt ]; then
    if pip3 install -r requirements.txt; then
        echo -e "${GREEN}Python dependencies installed successfully.${NC}"
    else
        echo -e "${RED}Error installing Python dependencies.${NC}"
    fi
else
    echo -e "${RED}requirements.txt not found.${NC}"
fi

# Install Keycloak (Docker)
echo "Setting up Keycloak via Docker..."
if ! docker images | grep -q quay.io/keycloak/keycloak; then
    if docker pull quay.io/keycloak/keycloak:latest; then
        echo -e "${GREEN}Keycloak Docker image pulled successfully.${NC}"
    else
        echo -e "${RED}Error pulling Keycloak Docker image.${NC}"
    fi
else
    echo -e "${GREEN}Keycloak Docker image already exists.${NC}"
fi

# Run or start Keycloak Docker container
echo "Running Keycloak container..."
if docker ps -a --format '{{.Names}}' | grep -q '^keycloak$'; then
    # Container exists (running or stopped)
    if docker ps --format '{{.Names}}' | grep -q '^keycloak$'; then
        echo -e "${GREEN}Keycloak container is already running.${NC}"
    else
        if docker start keycloak; then
            echo -e "${GREEN}Keycloak container started successfully (existing container).${NC}"
        else
            echo -e "${RED}Error starting existing Keycloak container.${NC}"
        fi
    fi
else
    # Container doesn't exist; create and run it
    if docker run -d -p 8180:8080 -e KEYCLOAK_USER=admin -e KEYCLOAK_PASSWORD=admin --name keycloak quay.io/keycloak/keycloak:latest; then
        echo -e "${GREEN}Keycloak container started successfully.${NC}"
    else
        echo -e "${RED}Error starting new Keycloak container.${NC}"
    fi
fi

# Wait for Keycloak to start (optional sleep time to give Keycloak time to initialize)
echo "Waiting for Keycloak to initialize..."
sleep 30  # Adjust the time based on your machine's performance

# Inform the user
echo "Keycloak is now running at http://localhost:8180"
echo "Login using the admin credentials: admin/admin"


# (Optional) Install kubectl if it's not installed already
echo "Checking if kubectl is installed..."
if ! command -v kubectl &>/dev/null; then
    echo "Installing kubectl..."
    if sudo apt-get install -y kubectl; then
        echo -e "${GREEN}kubectl installed successfully.${NC}"
    else
        echo -e "${RED}Error installing kubectl.${NC}"
    fi
else
    echo -e "${GREEN}kubectl is already installed.${NC}"
fi

# (Optional) Start K3s services if necessary
echo "Starting K3s services..."
if sudo systemctl is-enabled k3s &>/dev/null; then
    echo -e "${GREEN}K3s services are already enabled.${NC}"
else
    if sudo systemctl enable k3s && sudo systemctl start k3s; then
        echo -e "${GREEN}K3s services started successfully.${NC}"
    else
        echo -e "${RED}Error starting K3s services.${NC}"
    fi
fi

# Install Helm
echo "Installing Helm..."
if ! command -v helm &>/dev/null; then
    if curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash; then
        echo -e "${GREEN}Helm installed successfully.${NC}"
    else
        echo -e "${RED}Error installing Helm.${NC}"
    fi
else
    echo -e "${GREEN}Helm is already installed.${NC}"
fi

# Install PostgreSQL using Helm
echo "Installing PostgreSQL using Helm..."
# Add the Bitnami Helm repository (contains PostgreSQL chart)
if ! helm repo list | grep -q bitnami; then
    if helm repo add bitnami https://charts.bitnami.com/bitnami; then
        echo -e "${GREEN}Bitnami Helm repository added successfully.${NC}"
    else
        echo -e "${RED}Error adding Bitnami Helm repository.${NC}"
    fi
else
    echo -e "${GREEN}Bitnami Helm repository already exists.${NC}"
fi

# Update Helm repositories
echo "Updating Helm repositories..."
if helm repo update; then
    echo -e "${GREEN}Helm repositories updated successfully.${NC}"
else
    echo -e "${RED}Error updating Helm repositories.${NC}"
fi

# Install PostgreSQL using Helm
echo "Installing PostgreSQL using Helm chart..."
if ! helm list -n default | grep -q postgres; then
    if helm install postgres bitnami/postgresql \
      --set auth.postgresPassword=postgres \
      --set auth.username=myuser \
      --set auth.password=mypassword \
      --set auth.database=mydb \
      --set persistence.size=1Gi; then
        echo -e "${GREEN}PostgreSQL installed successfully via Helm.${NC}"
    else
        echo -e "${RED}Error installing PostgreSQL via Helm.${NC}"
    fi
else
    echo -e "${GREEN}PostgreSQL Helm release already exists.${NC}"
fi

# Notify completion
echo -e "${GREEN}Setup completed! Docker, Docker Compose, K3s, Keycloak, PostgreSQL (both local and via Helm), Python environment, and Helm are ready.${NC}"

# End of script