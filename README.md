# AWS Flask Deployment with Terraform, Ansible, and Docker

## Table of Contents
1. [Project Overview](#project-overview)
2. [Prerequisites](#prerequisites)
3. [Project Structure](#project-structure)
4. [Getting Started](#getting-started)
5. [Workflow Explanation](#workflow-explanation)
6. [Network Architecture](#network-architecture)
7. [Detailed Component Breakdown](#detailed-component-breakdown)
8. [Troubleshooting](#troubleshooting)
9. [Cleanup](#cleanup)
10. [Contributing](#contributing)

## Project Overview

This project demonstrates a complete infrastructure-as-code (IaC) solution for deploying a Flask web application on AWS. It uses:

- **Terraform**: For provisioning and managing AWS infrastructure
- **Ansible**: For configuration management and application deployment
- **Docker**: For containerizing the Flask application
- **AWS**: As the cloud provider

The project follows best practices for infrastructure as code, configuration management, and continuous deployment.

## Prerequisites

Before you begin, ensure you have the following installed:

1. **AWS Account** with appropriate permissions
2. **AWS CLI** configured with your credentials
3. **Terraform** (v1.0+)
4. **Ansible** (v2.9+)
5. **Docker** (for local testing)
6. **Git**
7. **Python 3.8+**
8. **SSH key pair** in AWS and locally at `~/.ssh/networkingCaOne.pem`

## Project Structure

```
networkingCaOne/
├── ansible/
│   ├── ansible.cfg           # Ansible configuration
│   ├── inventory.ini          # Inventory file for Ansible
│   └── playbooks/
│       ├── setup.yml        # Main playbook
│       └── roles/
│           ├── app/         # Application deployment role
│           └── docker/       # Docker installation role
├── app/
│   ├── app.py                # Flask application
│   ├── requirements.txt      # Python dependencies
│   ├── Dockerfile            # Docker configuration
│   └── templates/
│       └── index.html      # HTML template
├── terraform/
│   ├── main.tf             # Main Terraform configuration
│   ├── variables.tf          # Variable declarations
│   ├── terraform.tfvars      # Variable values
│   └── .terraform.lock.hcl   # Terraform lock file
└── docs/
    ├── architecture-diagram.txt  # Network architecture
    └── report-template.md     # Project report template
```

## Getting Started

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd networkingCaOne
```

### 2. Configure AWS Credentials

Ensure your AWS credentials are configured:

```bash
aws configure
```

### 3. Initialize and Apply Terraform

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Review changes
terraform plan

# Apply changes (creates AWS resources)
terraform apply

# Note the EC2 public IP from the output
terraform output public_ip
```

### 4. Update Ansible Inventory

Update the inventory file with your EC2 instance's public IP:

```bash
cd ../ansible

# Edit inventory.ini and replace the IP address with your EC2 instance's public IP
# The file should look like this:
# [webserver]
# YOUR_EC2_IP ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/networkingCaOne.pem
```
[webserver]
3.250.239.10 ansible_user=ec2-user ansible_ssh_private_key_file=~/.ssh/networkingCaOne.pem
### 5. Run Ansible Playbook

```bash
# Run the playbook to configure the EC2 instance and deploy the application
ansible-playbook playbooks/setup.yml

ansible-playbook -i ansible/inventory.ini ansible/playbooks/setup.yml # arham in WSL
```

### 6. Verify Flask App Directory Structure

Ensure the Flask app has the correct directory structure on the EC2 instance:

```bash
# Connect to your EC2 instance
ssh -i ~/.ssh/networkingCaOne.pem ec2-user@YOUR_EC2_IP

# Check if templates directory exists
ls -la /home/ec2-user/app/

# If index.html exists in app directory, move it to templates
mv /home/ec2-user/app/index.html /home/ec2-user/app/templates/

# Rebuild and restart the Docker container
cd /home/ec2-user/app
docker stop flask-app
docker rm flask-app
docker build -t flask-app .
docker run -d --name flask-app -p 5000:5000 flask-app
```

### 7. Verify Deployment

```bash
# Check Docker container status
docker ps

# View container logs
docker logs flask-app
```

### 8. Access the Application

Once deployment is complete, access the application in your browser at:
```
http://YOUR_EC2_IP:5000
```

Replace `YOUR_EC2_IP` with the public IP address of your EC2 instance.

## Workflow Explanation

1. **Infrastructure Provisioning (Terraform)**:
   - Creates VPC, subnets, and security groups
   - Launches EC2 instance with proper IAM roles
   - Configures networking and security rules

2. **Configuration Management (Ansible)**:
   - Connects to the EC2 instance via SSH
   - Installs Docker and required dependencies
   - Configures the system for Docker
   - Deploys the Flask application using Docker

3. **Application Deployment (Docker)**:
   - Builds a Docker image from the provided Dockerfile
   - Runs the Flask application in a container
   - Maps container port 5000 to host port 5000

4. **CI/CD Pipeline (GitHub Actions)**:
   - Triggered on code push to main branch
   - Validates Terraform configuration
   - Applies infrastructure changes
   - Runs Ansible playbook for deployment
   - Performs health checks

## Network Architecture

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|  GitHub          |     |  GitHub Actions  |     |  AWS Cloud       |
|  Repository      +---->+  CI/CD Pipeline  +---->+                  |
|                  |     |                  |     |                  |
+------------------+     +------------------+     |  +-------------+ |
                                                  |  |             | |
                                                  |  |  VPC        | |
                                                  |  |             | |
                                                  |  |  +-------+  | |
                                                  |  |  |       |  | |
                                                  |  |  |  EC2  |  | |
                                                  |  |  |       |  | |
                                                  |  |  +---+---+  | |
                                                  |  |      |      | |
                                                  |  |  +---v---+  | |
                                                  |  |  |       |  | |
                                                  |  |  |Docker |  | |
                                                  |  |  |       |  | |
                                                  |  |  +---+---+  | |
                                                  |  |      |      | |
                                                  |  |  +---v---+  | |
                                                  |  |  |       |  | |
                                                  |  |  | Flask |  | |
                                                  |  |  |  App  |  | |
                                                  |  |  |       |  | |
                                                  |  |  +-------+  | |
                                                  |  |             | |
                                                  |  +-------------+ |
                                                  |                  |
                                                  +------------------+

```

## Detailed Component Breakdown

### 1. GitHub Repository
- **Purpose**: Version control and collaboration
- **Key Files**:
  - `.github/workflows/deploy.yml`: Defines the CI/CD pipeline
  - `README.md`: Project documentation

### 2. Terraform Configuration (`/terraform`)
- **Purpose**: Infrastructure as Code (IaC)
- **Key Files**:
  - `main.tf`: Defines AWS resources (VPC, EC2, security groups)
  - `variables.tf`: Declares input variables
  - `terraform.tfvars`: Contains variable values
  - `.terraform.lock.hcl`: Lock file for provider versions

### 3. Ansible Configuration (`/ansible`)
- **Purpose**: Configuration management and deployment
- **Key Files**:
  - `ansible.cfg`: Configuration settings for Ansible
  - `inventory.ini`: Defines target hosts
  - `playbooks/setup.yml`: Main playbook
  - `playbooks/roles/`: Contains reusable roles

### 4. Application Code (`/app`)
- **Purpose**: The Flask web application
- **Key Files**:
  - `app.py`: Main application code
  - `requirements.txt`: Python dependencies
  - `Dockerfile`: Container configuration
  - `templates/index.html`: HTML template

### 5. Documentation (`/docs`)
- **Purpose**: Project documentation
- **Key Files**:
  - `architecture-diagram.txt`: Network architecture
  - `report-template.md`: Project report template

## Troubleshooting

### Common Issues

1. **SSH Connection Issues**
   - Verify the key pair exists in AWS and locally
   - Check security group allows SSH (port 22)
   - Ensure the EC2 instance is running

2. **Docker Permission Issues**
   - Ensure the user is added to the docker group
   - Restart the Docker service if needed

3. **Application Not Accessible**
   - Check if the container is running: `docker ps`
   - Check container logs: `docker logs <container_id>`
   - Verify security group allows traffic on port 5000

## Cleanup

To avoid unnecessary AWS charges, destroy the infrastructure when done:

```bash
cd terraform
terraform destroy
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Ansible Flow chart
ansible/
├── ansible.cfg                # Main Ansible configuration file
├── inventory.ini              # List of target hosts (EC2 instance IPs)
└── playbooks/
    ├── setup.yml              # Main playbook that runs all roles
    └── roles/
        ├── docker/
        │   └── tasks/
        │       └── main.yml   # Tasks for installing/configuring Docker
        └── app/
            └── tasks/
                └── main.yml   # Tasks for deploying the Flask app
