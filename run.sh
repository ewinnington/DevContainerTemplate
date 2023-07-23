#!/bin/bash

# Docker image (replace "<YOUR_IMAGE_NAME>" with your docker image name) 
docker_image="<YOUR_IMAGE_NAME>:latest"
  
# Push the Docker image to a container registry (replace "<YOUR_REGISTRY_URL>" with your registry URL)
registry="<YOUR_REGISTRY_URL>.azurecr.io"

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Function to verify dependencies
verify_dependencies() {
  # Check if required commands are available
  required_commands=("docker" "terraform" "az")

  echo "Verifying dependencies..."
  for cmd in "${required_commands[@]}"; do
    if ! command_exists "$cmd"; then
      echo "❌   Error: $cmd command not found. Please install it and try again."
      exit 1
    fi
    echo "✔  $cmd is present"
  done

  echo "Dependencies verified."
}

docker_login() 
{
    sudo docker login $registry
}

azure_login()
{
    az login --use-device-code
}

# Function to build and push Docker image
docker_build_and_push() {
  cd img || exit 1
  echo "Building and pushing Docker image..."

  # Build the Docker image
  sudo docker build -t "$docker_image" .
 
  sudo docker push "$registry/$docker_image"
  
  echo "Docker image built and pushed."
  cd ..
}

# Function to execute Terraform plan and apply
terraform_plan_and_apply() {
  echo "Executing Terraform plan and apply..."
  
  # Change to the Terraform directory where your .tf files are located
  cd tf_infra || exit 1
  
  # Initialize Terraform
  terraform init
  
  # Create a Terraform plan
  terraform plan -out=tfplan
  
  # Apply the Terraform plan
  terraform apply "tfplan"
  
  echo "Terraform plan and apply completed."
  cd ..
}

terraform_destroy(){
  echo "Executing Terraform destroy..."
  
  # Change to the Terraform directory where your .tf files are located
  cd tf_infra || exit 1
  
  # Initialize Terraform
  terraform destroy./
  
  echo "Terraform destroy completed."
  cd ..
}

# Main function to call all steps
main() {
  # Verify dependencies
  verify_dependencies

  # Check if a command is provided as an argument
  if [ -z "$1" ]; then
    echo "Error: Please provide a command (e.g., build, login, all, destroy, clean)."
    exit 1
  fi

  # Use a case statement to dispatch based on the provided command
  case "$1" in
    "build")
     docker_build_and_push
      ;;
    "login")
      docker_login
      azure_login
      ;;
    "all")
      terraform_plan_and_apply
      docker_build_and_push
      ;;
    "destroy")
      terraform_destroy
      ;;
    "infra")
      terraform_plan_and_apply
      echo "Remember to configure the docker repository and image name from the outputs" 
      ;;
    "clean")
      echo "🚧 clean is not implemented"
      ;;
    *)
      echo "Error: Unknown command '$1'. Supported commands: build, login, infra, all, destroy, clean."
      exit 1
      ;;
  esac
}

# Call the main function to start the deployment process with the provided command
main "$@"