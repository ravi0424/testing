#!/bin/bash

# Define variables
APP_NAME="php-app"
DOCKER_IMAGE="ravikirangunnabattula/my-apk:latest" 
DOCKER_CONTAINER_NAME="php-app-container"
AWS_REGION="us-east-1" # Replace with your region
AWS_ECR_REPO="your-ecr-repository-name" # Optional if you're using ECR
PUBLIC_IP=$(curl -s http://checkip.amazonaws.com) # Get public IP of EC2 instance

# Step 1: Ensure the EC2 instance has Docker installed and running
echo "Checking if Docker is installed..."
if ! command -v docker &> /dev/null; then
    echo "Docker not found. Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y docker.io
    sudo systemctl enable --now docker
else
    echo "Docker is already installed."
fi

# Step 2: Login to AWS ECR (if using ECR for Docker images)
if [[ ! -z "$AWS_ECR_REPO" ]]; then
    echo "Logging into AWS ECR..."
    aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin <aws_account_id>.dkr.ecr.$AWS_REGION.amazonaws.com
fi

# Step 3: Pull the Docker image (either from Docker Hub or ECR)
echo "Pulling Docker image..."
sudo docker pull $DOCKER_IMAGE

# Step 4: Stop and remove any existing container (if exists)
echo "Stopping and removing old container if exists..."
sudo docker stop $DOCKER_CONTAINER_NAME
sudo docker rm $DOCKER_CONTAINER_NAME

# Step 5: Run the Docker container with port mapping
echo "Running the new Docker container..."
sudo docker run -d --name $DOCKER_CONTAINER_NAME -p 80:80 $DOCKER_IMAGE

# Step 6: Allow access to the application through the public IP
echo "Access the app via http://$PUBLIC_IP"

# Step 7: (Optional) Tail the logs of the container
echo "Tailing logs from the container..."
sudo docker logs -f $DOCKER_CONTAINER_NAME
