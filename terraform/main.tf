# What cloud service provider to use?
provider "aws" {
  region = var.aws_region
}

# 1: Create a virtual private cloud
# vpc_cidr_block is the range of IP addresses for the VPC
# Enabling DNS means that amazon will have a domain name along with an IP address

resource "aws_vpc" "app_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "app-vpc"
  }
}

# Create an internet gateway
# Internet gateway is a virtual router that connects EC2 instances to the internet
resource "aws_internet_gateway" "app_igw" {
  vpc_id = aws_vpc.app_vpc.id
  tags = {
    Name = "app-igw"
  }
}

# 3: Create a public subnet to ensure instances launched in this subnet get public IPs
# Subnet is a range of IP addresses used by the network
resource "aws_subnet" "app_subnet" {
  vpc_id                  = aws_vpc.app_vpc.id
  cidr_block              = var.subnet_cidr_block
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"
  tags = {
    Name = "app-subnet"
  }
}

# 4: Create a route table allowing instances to access the internet
# 0.0.0.0/0 means all IP addresses 
resource "aws_route_table" "app_route_table" {
  vpc_id = aws_vpc.app_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.app_igw.id
  }
  tags = {
    Name = "app-route-table"
  }
}

# 5: Associate the route table with the subnet
# that links the route table to the public subnet, enabling internet access.


resource "aws_route_table_association" "app_route_table_association" {
  subnet_id      = aws_subnet.app_subnet.id
  route_table_id = aws_route_table.app_route_table.id
}

# Create a security group
# Ingress	Inbound	Traffic coming in to the instance
# Egress	Outbound	Traffic leaving the instance

resource "aws_security_group" "app_sg" {
  name        = "app-sg"
  description = "Allow inbound traffic for the application"
  vpc_id      = aws_vpc.app_vpc.id

  # Allow SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH"
  }

  # Allow HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP"
  }

  # Allow Flask app access
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Flask App"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "app-sg"
  }
}


# Create an EC2 instance
resource "aws_instance" "app_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = "networkingCaOne"  # Direct reference to existing key pair
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = aws_subnet.app_subnet.id

  tags = {
    Name = "app-instance"
  }

  # Generate the Ansible inventory file
  # Terraform writes an Ansible inventory.ini file to use for deployment.
  provisioner "local-exec" {
    command = <<-EOT
      echo "[webserver]" > ../ansible/inventory.ini
      echo "${self.public_ip} ansible_user=ec2-user ansible_ssh_private_key_file=${var.private_key_path}" >> ../ansible/inventory.ini
    EOT
  }
}

# Output the public IP address of the EC2 instance
# Useful for connecting via SSH or accessing your deployed app
output "public_ip" {
  value = aws_instance.app_instance.public_ip
}
