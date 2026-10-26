# Terraform AWS Webserver

Deploys a simple NGINX web server on AWS EC2 using Terraform.
Built as a learning project to practice Infrastructure as Code on AWS.

## What it creates
- **EC2 instance** – `t3.micro`, latest Ubuntu 24.04 LTS, region `eu-north-1` (Stockholm)
- **Security Group** – allows SSH (22) and HTTP (80) inbound, all outbound traffic
- **Key pair** – uploads a local SSH public key for access
- **NGINX** – installed automatically on first boot via `user_data`

## Prerequisites
- Terraform installed
- AWS CLI installed and configured (`aws configure`)
- SSH key pair at `~/.ssh/aws_tf` (`ssh-keygen -t ed25519 -f ~/.ssh/aws_tf`)

## Usage
```bash
terraform init      # First run
terraform plan      # Check changes & validate
terraform apply     # & yes
```
The public IP is printed as an output. After 1–2 minutes the page is available at `http://<public_ip>`.

Run `terraform destroy` when finished to avoid unnecessary costs.

## What I learned
- **Data sources** – `aws_ami` finds the latest official Ubuntu image instead of hardcoding an AMI ID, which differs per region and changes with every release.
- **Security Group rules** – `ingress` controls inbound traffic to the instance (port + source CIDR), `egress` controls where the instance itself can connect.
- **Egress pitfall** – unlike the AWS console, Terraform does not add a default allow-all egress rule. Without it the instance has no internet access, so `apt install` fails.
- **`user_data` runs only on first boot** – changing it on an existing instance has no effect. `user_data_replace_on_change = true` makes Terraform rebuild the instance whenever the script changes.
- **Public IP is not static** – stopping or replacing an instance assigns a new public IP. A fixed address requires an Elastic IP.
- **HTML line breaks** – `\n` is not rendered in HTML; `<br>` is needed.