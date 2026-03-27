# SRE / DevOps Assessment

This repository covers three tests: monitoring stack setup, infrastructure automation and troubleshooting scenarios

## Test 1- Monitoring Stack

**Location:** `test-1-monitoring/`

Set up a full logging and metrics monitoring stack using Docker Compose on a local Windows machine, simulating a containerised cluster environment

**Tools used:** Promtail, Loki, Prometheus and Grafana

**What's included:**
- All config files (docker-compose, prometheus, loki, promtail)
- 3 Grafana dashboards (Cluster Health, Application Logs, On-Call Overview)
- 3 Alert rules (CPU, CrashLoopBackOff, Memory)
- Screenshots showing the stack working
- Full README with tool justification and setup steps

---

## Test 2- Infrastructure Automation

**Location:** `test-2-automation/`

Provisioned a local VirtualBox environment using Terraform and Vagrant, then configured VM1 using Ansible

**Tools used:** Terraform + Vagrant + Ansible

**What's included:**
- Terraform files targeting Azure (main.tf, variables.tf, outputs.tf)
- Vagrantfile for local VirtualBox provisioning
- Ansible playbook configuring nginx, hostname and deploy user on VM1
- plan-output.txt from terraform plan
- Screenshots of both VMs running and Ansible playbook succeeding
- Full README with tool justification and run steps

---

## Test 3- Troubleshooting Scenarios

**Location:** `test-3-troubleshooting/`

Written troubleshooting answers covering a real AKS scenario where pods are running but the application is unreachable

**What's included:**
- `scenario-1.md`- debugging flow, kubectl commands, isolation steps and two Azure-specific causes
