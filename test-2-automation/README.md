# Test 2- Infrastructure Automation

## Part A- Tool choice and why

### Which IaC tools did I use?
I used **Terraform, Vagrant and Ansible**:
- **Terraform** for defining and provisioning Iac
- **Vagrant** for managing the local VirtualBox VM lifecycle
- **Ansible** for configuring what runs on the VMs after provisioning

### Why did I combine them this way?
Each tool does something that the others don't:

- **Terraform** is the industry standard IaC tool and the one the team already uses. It handles infrastructure declaratively. I define the desired state and Terraform figures out how to get there. On Azure this would provision the VNet, subnets, VMs, NSGs and public IPs directly

- **Vagrant** was needed because I don't have an active Azure subscription. Vagrant works seamlessly with VirtualBox on Windows and let me provision real, running VMs locally. In a real Azure environment, Vagrant would be removed entirely and Terraform would talk directly to Azure

- **Ansible** configures what runs on the VMs after they exist. Terraform provisions the infrastructure, Ansible configures it. The common pattern is when Terraform and Ansible complement each other because Terraform is not designed for software configuration and Ansible is not designed for infrastructure provisioning

### How does my approach handle secrets and sensitive values?
- The `my_ip_address` variable is marked `sensitive = true` in variables.tf so Terraform never prints it in logs
- It is passed at runtime via the `-var` flag or environment variable and never hardcoded in code
- SSH keys are referenced by file path and never committed to the repo
- The `.terraform/` folder is in `.gitignore` so provider binaries and any cached credentials are never pushed to GitHub
- In production I would use Azure Key Vault or Terraform Cloud for secret storage and Ansible Vault for any secrets needed in playbooks

---

## Part B — What Was Provisioned

### Environment
Local VirtualBox environment using Vagrant and Terraform (VirtualBox provider)
Both VMs are running Ubuntu 20.04 (focal64)

### Resources Provisioned

**Virtual Network (simulated with VirtualBox networking):**
- Public network adapter on VM1 which is bridged to host network- this represents public accessibility
- Host-only network on both VMs at 192.168.56.0/24- this represents the private subnet
- VM2 has no bridged adapter, only the host-only network- no public IP

**VM1- Gateway (publicly accessible):**
- Name: `vm1-gateway`
- OS: Ubuntu 20.04
- 1 CPU, 1024MB RAM
- Network: bridged (public) + host-only at 192.168.56.10 (private)
- Hostname set to `sre-gateway` by Ansible

**VM2- App Server (internal only):**
- Name: `vm2-appserver`
- OS: Ubuntu 20.04
- 1 CPU, 1024MB RAM
- Network: host-only at 192.168.56.11 only and no public access

**Firewall rules (VirtualBox host-only network):**
- SSH (port 22) to VM1 accessible from host machine only
- HTTP (port 80) and HTTPS (port 443) to VM1 from anywhere
- All traffic allowed between VM1 and VM2 on the private subnet
- VM2 has no public interface. All other inbound traffic denied by default

### Ansible Configuration on VM1
After Vagrant provisioned the VMs, Ansible configured VM1 by:
- Installing and starting **nginx**
- Deploying a custom HTML page to prove nginx is working
- Setting the system **hostname** to `sre-gateway`
- Creating a **deploy user** with passwordless sudo access for CI/CD use

---

## How to Run

### Prerequisites
- VirtualBox installed
- Vagrant installed
- Ansible run from inside VM1- this is because Ansible doesn't run natively on Windows

### Step 1- Provision VMs with Vagrant
```bash
cd test-2-automation
vagrant up
```

### Step 2- Upload Ansible files to VM1
```bash
vagrant upload ansible/playbook.yml /home/vagrant/playbook.yml vm1_gateway
vagrant upload ansible/inventory.ini /home/vagrant/inventory.ini vm1_gateway
```

### Step 3- SSH into VM1 and run Ansible
```bash
vagrant ssh vm1_gateway
sudo apt update
sudo apt install -y ansible
ansible-playbook -i inventory.ini playbook.yml
```

### Step 4- Verify nginx is working
```bash
curl http://localhost
```

### Step 5- Verify VM2 is reachable from VM1
```bash
ping 192.168.56.11 -c 3
```

### For Azure deployment
Replace the Vagrantfile with the Azure Terraform provider and run:
```bash
cd test-2-automation/terraform
az login
terraform init
terraform plan -var="my_ip_address=YOUR_IP/32"
terraform apply -var="my_ip_address=YOUR_IP/32"
```

---

## What I would add in production
- Use Azure provider instead of VirtualBox. The Terraform code in `terraform/main.tf` is written for Azure and ready to use with real credentials
- Remote backend (Azure Storage Account) for Terraform state so the team can collaborate
- Terraform workspaces for dev/staging/prod environments
- Azure Key Vault integration for secrets management
- Ansible Vault for encrypting sensitive playbook variables
- Additional NSG rules for internal monitoring ports that is Prometheus and Grafana
- Auto-scaling configuration for the app server
- Load balancer in front of VM1 for high availability