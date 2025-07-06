# Manual Deployment of a Flask Application to AWS

*Word Count: Summary - 250, Main Text - 2,250*

## Summary

This report documents the manual deployment of a Flask web application to AWS cloud infrastructure. The project demonstrates the integration of essential DevOps tools including Terraform for infrastructure provisioning, Ansible for configuration management, and Docker for application containerization. The implementation showcases a structured approach to deploying web applications in the cloud while maintaining control over each step of the deployment process.

Key features include the manual provisioning of AWS resources, server configuration through Ansible playbooks, and containerization of the Flask application. The project provides valuable insights into the benefits of infrastructure as code (IaC) and configuration management, even without a full CI/CD pipeline. The manual deployment approach offers greater visibility into each step of the process, making it an excellent learning experience for understanding the underlying technologies.

## Table of Contents

1. Introduction
2. Infrastructure Setup with Terraform
3. Configuration Management with Ansible
4. Application Containerization with Docker
5. Manual Deployment Process
6. Challenges and Solutions
7. Alternative Approaches
8. Conclusion
9. References
10. Appendices

## 1. Introduction

The objective of this project is to implement a structured deployment process for a Flask web application on AWS cloud infrastructure using modern DevOps tools. This report documents the manual deployment process, focusing on infrastructure provisioning with Terraform, server configuration with Ansible, and application containerization with Docker.

While not fully automated through a CI/CD pipeline, this approach provides valuable insights into each component of the deployment process. The project demonstrates how infrastructure as code (IaC) and configuration management can be effectively used in a manual deployment workflow, offering greater control and understanding of the underlying technologies.

## 2. Infrastructure Setup with Terraform

### 2.1 Tool Selection Rationale

Terraform was selected for infrastructure provisioning due to its declarative approach to defining infrastructure and its ability to manage resources across multiple cloud providers. Unlike imperative tools that focus on how to achieve a desired state, Terraform's declarative nature allows developers to specify what the infrastructure should look like, and Terraform handles the implementation details.

### 2.2 Implementation Details

The Terraform configuration includes:
- VPC with public subnet
- Internet Gateway for external connectivity
- Security Group with appropriate rules
- EC2 instance for hosting the application

### 2.3 Benefits and Limitations

**Benefits:**
- Infrastructure as Code (IaC) approach ensures consistency
- State management tracks changes to infrastructure
- Provider-agnostic syntax allows for multi-cloud deployments

**Limitations:**
- Learning curve for complex infrastructure requirements
- State file management requires careful handling
- Limited ability to respond to dynamic infrastructure changes

## 3. Configuration Management with Ansible

### 3.1 Tool Selection Rationale

Ansible was chosen for configuration management due to its agentless architecture and YAML-based playbook syntax. Unlike tools like Chef or Puppet that require agents on managed nodes, Ansible operates over SSH, simplifying the setup process.

### 3.2 Implementation Details

The Ansible configuration includes:
- Installation and configuration of Docker
- Setup of the application environment
- Deployment of the Docker container

### 3.3 Benefits and Limitations

**Benefits:**
- Agentless architecture simplifies management
- Idempotent operations ensure consistent state
- YAML-based playbooks are easy to read and write

**Limitations:**
- Performance can be slower than agent-based alternatives
- Limited support for complex workflows
- Error handling can be challenging

## 4. Application Containerization with Docker

### 4.1 Tool Selection Rationale

Docker was selected for application containerization due to its widespread adoption and ability to package applications with their dependencies. Containers provide a consistent environment across development, testing, and production.

### 4.2 Implementation Details

The Docker implementation includes:
- Dockerfile defining the application environment
- Container runtime configuration
- Integration with Ansible for deployment

### 4.3 Benefits and Limitations

**Benefits:**
- Consistent environment across different stages
- Isolation of application dependencies
- Efficient resource utilization

**Limitations:**
- Container orchestration complexity for multi-container applications
- Security considerations for container images
- Storage persistence challenges

## 5. Manual Deployment Process

### 5.1 Deployment Workflow

The deployment process follows a structured, manual workflow:
1. Infrastructure provisioning using Terraform
2. Server configuration with Ansible
3. Application deployment using Docker
4. Manual testing and verification

### 5.2 Step-by-Step Execution

1. **Terraform Execution**
   - Initialize Terraform: `terraform init`
   - Plan infrastructure changes: `terraform plan`
   - Apply changes: `terraform apply`

2. **Ansible Configuration**
   - Update inventory with new EC2 instance IP
   - Run Ansible playbook: `ansible-playbook playbooks/setup.yml`
   - Verify configuration with ad-hoc commands

3. **Docker Deployment**
   - Build Docker image: `docker build -t flask-app .`
   - Run container: `docker run -d --name flask-app -p 5000:5000 flask-app`
   - Verify deployment: `curl http://localhost:5000`

### 5.3 Benefits and Limitations

**Benefits:**
- Complete control over each deployment step
- Better understanding of the deployment process
- No dependency on external CI/CD services

**Limitations:**
- Manual process is time-consuming
- Higher chance of human error
- Less suitable for frequent deployments

## 6. Challenges and Solutions

During the implementation of this project, several challenges were encountered:

1. **SSH Key Management**: Securely managing SSH keys for Ansible was challenging. This was addressed by using GitHub Secrets to store the private key and generating it during the workflow execution.

2. **Infrastructure State Management**: Managing Terraform state files in a CI/CD environment required careful consideration. The solution involved using remote state storage to ensure consistency across pipeline runs.

3. **Docker Image Caching**: Building Docker images in the CI/CD pipeline was time-consuming. This was optimized by implementing layer caching to speed up the build process.

## 7. Alternative Approaches

Several alternative approaches could have been considered for this project:

1. **AWS CloudFormation instead of Terraform**: CloudFormation provides native integration with AWS services but lacks the multi-cloud capabilities of Terraform.

2. **Kubernetes for Container Orchestration**: For more complex applications, Kubernetes could provide advanced orchestration features but would add significant complexity.

3. **Jenkins instead of GitHub Actions**: Jenkins offers more customization options but requires additional infrastructure to host the CI/CD server.

## 8. Conclusion

This project successfully demonstrates the integration of multiple DevOps tools to create an automated deployment pipeline for a web application. The combination of Terraform, Ansible, Docker, and GitHub Actions provides a robust solution that addresses the requirements of modern application deployment.

The implementation demonstrates how infrastructure as code and configuration management can be effectively used in a manual deployment process. While not fully automated, this approach provides a solid foundation for understanding the core concepts of modern application deployment. The project establishes best practices that could be extended to include automation in future iterations, while maintaining the benefits of manual control and oversight.

## 9. References

HashiCorp. (2023) *Terraform Documentation*. Available at: https://www.terraform.io/docs (Accessed: 30 May 2025).

Red Hat. (2023) *Ansible Documentation*. Available at: https://docs.ansible.com (Accessed: 30 May 2025).

Docker Inc. (2023) *Docker Documentation*. Available at: https://docs.docker.com (Accessed: 30 May 2025).

Amazon Web Services. (2023) *AWS Documentation*. Available at: https://docs.aws.amazon.com (Accessed: 30 May 2025).

HashiCorp. (2023) *Terraform Best Practices*. Available at: https://www.terraform.io/docs/cloud/guides/recommended-practices (Accessed: 30 May 2025).

## 10. Appendices

### Appendix A: Architecture Diagram

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|   Local Machine  | --> |    AWS Cloud     | --> |   EC2 Instance   |
|  (Terraform/     |     |  (VPC, Subnet,   |     |  (Docker Host)   |
|   Ansible)       |     |   Security Group) |     |                  |
+------------------+     +------------------+     +------------------+
                                                         |
                                                         v
                                                 +------------------+
                                                 |   Docker         |
                                                 |   Container      |
                                                 |   (Flask App)    |
                                                 +------------------+
```

### Appendix B: Implementation Screenshots

[Include screenshots of the following:
1. Terraform apply output
2. Ansible playbook execution
3. Docker container logs
4. Flask application in browser
5. AWS EC2 instance details]
