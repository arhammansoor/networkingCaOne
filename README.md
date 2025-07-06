# AWS Flask Deployment with Terraform, Ansible, and Docker

## Table of Contents

1. [Project Overview](#project-overview)  
2. [Prerequisites](#prerequisites)  
3. [Project Structure](#project-structure)  
4. [Getting Started](#getting-started)  
   - [1. Clone the Repository](#1-clone-the-repository)  
   - [2. Configure AWS (only if running Terraform manually)](#2-configure-aws-only-if-running-terraform-manually)  
   - [3. Provision Infrastructure (Manual Terraform Option)](#3-provision-infrastructure-manual-terraform-option)  
   - [4. Update Ansible Inventory](#4-update-ansible-inventory)  
   - [5. Push Code to Trigger GitHub Actions](#5-push-code-to-trigger-github-actions)  
   - [6. CI/CD Pipeline Execution](#6-cicd-pipeline-execution)  
   - [7. Flask App Verification (Inside EC2 - if needed)](#7-flask-app-verification-inside-ec2---if-needed)  
   - [8. Access the Application](#8-access-the-application)  
5. [Workflow Explanation](#workflow-explanation)  
6. [Network Architecture](#network-architecture)  
7. [Detailed Component Breakdown](#detailed-component-breakdown)  
   - [GitHub Actions (.github/workflows/deploy.yml)](#github-actions-githubworkflowsdeployyml)  
   - [Ansible (ansible/)](#ansible-ansible)  
   - [Flask App (app/)](#flask-app-app)  
   - [Terraform (terraform/)](#terraform-terraform)  
8. [Troubleshooting](#troubleshooting)  
9. [Cleanup](#cleanup)  
10. [Contributing](#contributing)  
11. [License](#license)  
12. [Notes](#notes)  
13. [Ansible Flow chart](#ansible-flow-chart)  


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

## **Getting Started**

### **1\. Clone the Repository**

git clone &lt;your-repo-url&gt;

cd networkingCaOne

### **2\. Configure AWS (only if running Terraform manually)**

aws configure

### **3\. Provision Infrastructure (Manual Terraform Option)**

If provisioning manually:

cd terraform

terraform init

terraform plan

terraform apply

Save the output EC2 public IP.

### **4\. Update Ansible Inventory**

Update ansible/inventory.ini:

\[webserver\]

3.250.239.10 ansible_user=ec2-user ansible_ssh_private_key_file=/home/runner/.ssh/networkingCaOne.pem

### **5\. Push Code to Trigger GitHub Actions**

git status

git add .

git commit -m "Final deployment"

git push origin main

### **6\. CI/CD Pipeline Execution**

- GitHub Actions runs automatically upon push
- It sets up SSH, installs Ansible, and executes the playbook
- The playbook installs Docker and deploys the Flask app inside a container

### **7\. Flask App Verification (Inside EC2 - if needed)**

ssh -i ~/.ssh/networkingCaOne.pem ec2-user@3.250.239.10

\# Confirm app directory and template file

ls -la /home/ec2-user/app/

\# Move index.html to templates/ if needed

mv /home/ec2-user/app/index.html /home/ec2-user/app/templates/

\# Rebuild and run container manually (optional)

cd /home/ec2-user/app

docker stop flask-app

docker rm flask-app

docker build -t flask-app .

docker run -d --name flask-app -p 5000:5000 flask-app

### **8\. Access the Application**

Visit:

<http://3.250.239.10:5000>


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

## **Detailed Component Breakdown**

### **GitHub Actions (.github/workflows/deploy.yml)**

- Triggers pipeline
- Loads SSH key from GitHub Secrets
- Installs Ansible and runs playbook

### **Ansible (ansible/)**

- inventory.ini: IP and SSH config
- setup.yml: Executes docker + app roles
- roles/docker: Docker installation
- roles/app: Flask container deployment

### **Flask App (app/)**

- app.py, Dockerfile, requirements.txt
- templates/index.html as homepage

### **Terraform (terraform/)**

- main.tf, variables.tf, terraform.tfvars
- Provisions EC2 and SG for SSH + HTTP

## **Troubleshooting**

- **SSH Failures**: Check key path and permission (chmod 600)
- **App Not Showing**:
  - Is container running? docker ps
  - Logs: docker logs flask-app
  - Is port 5000 open in SG?

## **Cleanup**

To destroy EC2 instance:

cd terraform

terraform destroy

## **Contributing**

1. Fork repo
2. Create feature branch
3. Commit changes
4. Open PR

## **License**

MIT License – see LICENSE file.

## **Notes**

- Deployment is automated via GitHub Actions
- Uses Amazon Linux 2, user: ec2-user
- CI/CD tested in GitHub-hosted runner (Ubuntu)

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
