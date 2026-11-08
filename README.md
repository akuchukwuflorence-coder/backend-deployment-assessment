
# Backend Deployment Assessment
## AltSchool Africa — Cloud Engineering

### Project Overview

This project demonstrates the deployment of a containerized Go backend application on AWS using Terraform for Infrastructure as Code (IaC).

The infrastructure follows a multi-tier architecture with public and private subnets, an Application Load Balancer (ALB), a Bastion host, a backend EC2 instance, and a MongoDB EC2 instance.

The deployment includes secure network access, Docker containerization, infrastructure provisioning, and application health verification.

## Technologies Used

- AWS EC2
- Amazon VPC
- AWS Application Load Balancer
- AWS Security Groups
- Internet Gateway and NAT Gateway
- Terraform
- Docker and Docker Compose
- Go (Golang)
- MongoDB
- SSH
- Git and GitHub

## Infrastructure Architecture

The AWS infrastructure was provisioned in the `us-east-1` region.

```text
                  Internet
                     |
           Application Load Balancer
                     |
              Port 8080 (HTTP)
                     |
             Backend EC2 Instance
              Private Subnet
                10.0.3.89
                     |
              MongoDB (27017)
                     |
             MongoDB EC2 Instance
              Private Subnet
                10.0.4.188


Administrator
     |
  SSH (22)
     |
Bastion Host (Public Subnet)
     |
  SSH (22)
     |
Backend EC2 (Private Subnet)
```

### Network Configuration

The network consists of:

- VPC: `startuptech-vpc`
- VPC CIDR: `10.0.0.0/16`
- Two public subnets across two Availability Zones
- Two private subnets across two Availability Zones
- Internet Gateway for public connectivity
- NAT Gateway for outbound connectivity from private subnets
- Public and private route tables

### EC2 Instances

Three EC2 instances were deployed:

| Instance | Network | IP Address |
|---|---|---|
| Bastion Host | Public subnet | 44.220.22.220 |
| Backend Server | Private subnet | 10.0.3.89 |
| MongoDB Server | Private subnet | 10.0.4.188 |

The Bastion host provides administrative SSH access to private instances without exposing them directly to the internet.

## Security Groups

The infrastructure uses separate security groups to control traffic.

| Security Group | Allowed Traffic |
|---|---|
| ALB | HTTP 80 and HTTPS 443 |
| Bastion | SSH 22 from administrator IP |
| Backend | Application port 8080 from ALB; SSH 22 from Bastion |
| MongoDB | Port 27017 from Backend |

These rules restrict access between infrastructure components.

## Terraform Infrastructure Deployment

Terraform was used to provision and manage the AWS resources.

### Prerequisites

- Terraform installed
- AWS CLI installed and configured
- AWS account with appropriate permissions
- EC2 SSH key pair

### Deployment Commands

Navigate to the Terraform directory:

```powershell
cd terraform
```

Initialize Terraform:

```powershell
terraform init
```

Validate the configuration:

```powershell
terraform validate
```

Preview infrastructure changes:

```powershell
terraform plan
```

Apply the configuration:

```powershell
terraform apply
```

Terraform provisions the VPC, networking components, security groups, EC2 instances, and Application Load Balancer.

## Bastion Host and SSH Access

The Bastion host is deployed in a public subnet, while the backend instance is deployed in a private subnet.

The backend was successfully accessed through the Bastion host using SSH ProxyCommand.

The successful connection was verified using:

```bash
whoami
hostname
```

The backend instance returned:

```text
ec2-user
ip-10-0-3-89.ec2.internal
```

This confirms successful SSH access to the private backend instance.

## Docker Deployment

Docker and Docker Compose were installed on the backend EC2 instance.

Docker installation was verified using:

```bash
docker --version
docker compose version
```

The Docker service was verified using:

```bash
sudo systemctl status docker --no-pager
```

The service reported:

```text
Active: active (running)
```

The backend application was deployed in a Docker container.

Container status was checked using:

```bash
sudo docker ps
```

The output confirmed:

```text
IMAGE: muchtodo-backend:latest
NAME: muchtodo-backend
STATUS: Up
PORTS: 8080->8080/tcp
```

## MongoDB Integration

The backend application communicates with MongoDB hosted on a separate private EC2 instance.

MongoDB connectivity is restricted through the MongoDB security group, which allows database traffic on port 27017 from the backend security group.

The backend health endpoint reported the database status as operational.

## Application Health Check

The backend application exposes a health endpoint:

```text
/health
```

Health verification was performed on the backend instance:

```bash
curl -i http://localhost:8080/health
```

The response was:

```text
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"cache":"disabled","database":"ok"}
```

This confirms that the backend application was responding successfully and reported successful database connectivity.

## Application Load Balancer

An AWS Application Load Balancer was configured to route HTTP requests to the backend EC2 instance on port 8080.

The ALB target group uses:

- Target type: Instance
- Protocol: HTTP
- Port: 8080
- Health check path: `/health`

The target group was verified in the AWS Management Console.

**Target health status: Healthy**

The application was also tested through the ALB DNS name:

```text
http://startuptech-alb-588419916.us-east-1.elb.amazonaws.com/health
```

The ALB returned:

```text
HTTP/1.1 200 OK

{"cache":"disabled","database":"ok"}
```

This confirms that the load balancer successfully forwarded requests to the backend application.

## Deployment Evidence

The `screenshots` directory contains evidence of the deployed infrastructure and successful verification.

### Infrastructure Screenshots

- [ALB Health Check](screenshots/01-alb-health-check.png)
- [VPC](screenshots/02-vpc.png)
- [Subnets](screenshots/03_1-subnets.png)
- [Private Route Table](screenshots/04-private-route-table.png)
- [Public Route Table](screenshots/05-public-route-table.png)
- [Internet Gateway](screenshots/06-internet-gateway.png)
- [NAT Gateway](screenshots/07-nat-gateway.png)
- [EC2 Instances](screenshots/08-ec2-instances.png)
- [Bastion Instance](screenshots/09-bastion-details.png)
- [Backend Instance](screenshots/10-backend-details.png)
- [MongoDB Instance](screenshots/11-mongodb-details.png)
- [Security Groups](screenshots/12_1-security-groups.png)
- [Terraform State](screenshots/17-terraform-state-list.png)
- [Healthy ALB Target](screenshots/18-alb-target-healthy.png)

### Deployment Verification Screenshots

- [Successful Bastion SSH](screenshots/19-bastion-ssh-success.png)
- [Running Docker Container](screenshots/20-docker-container-running.png)
- [Backend Health Check](screenshots/21-backend-health-check.png)
- [Bastion-to-Backend SSH](screenshots/22-private-backend-ssh.png)

Additional subnet and security group screenshots are available in the same directory.

## Security Considerations

- Backend and MongoDB instances are hosted in private subnets.
- Administrative access is provided through the Bastion host.
- Security groups restrict access to required ports and sources.
- The backend is exposed publicly through the Application Load Balancer rather than a public EC2 IP.
- SSH private keys, AWS credentials, Terraform state files, and other sensitive files must not be committed to a public repository.
- Production deployments should use HTTPS with a valid TLS certificate.

## Infrastructure Cleanup

After completing the assessment and capturing the required evidence, AWS resources can be removed using:

```powershell
cd terraform
terraform plan -destroy
terraform destroy
```

## Conclusion

This assessment demonstrates practical experience with:

- AWS infrastructure provisioning using Terraform
- VPC and subnet architecture
- Secure access to private EC2 instances through a Bastion host
- Docker container deployment
- Backend-to-database communication
- Application Load Balancer configuration
- Application health monitoring
- GitHub documentation and deployment evidence

The backend was successfully deployed and verified through both its local health endpoint and the public Application Load Balancer.

## Author

AltSchool Africa Cloud Engineering Student
NDUBUISI FLORENCE
ALT/SOE/BAR/026/0042

