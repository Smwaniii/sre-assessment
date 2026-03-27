# Test 1- Monitoring Stack

## Environment
I used the local Docker Compose setup on Windows. All services run as Docker containers simulating a containerised cluster environment. Screenshots are included in 
the `screenshots/` folder

## Tool Selection and why?

### Logging Tools: Promtail, Loki and Grafana
I chose this stack over Fluentd, Elasticsearch and Kibana (EFK) 
because:
- **Ease of setup** -Loki is much simpler to configure than Elasticsearch
- **Resource usage** - Loki uses less memory and CPU than EFK, which matters on a shared AKS cluster
- **AKS compatibility** - Promtail runs as a DaemonSet on AKS, collecting logs from every node automatically
- **Cost** -all three tools are open source and free
- **Maintenance** - the team only needs to learn one UI (Grafana) for both logs and metrics

### Metrics Tools: Prometheus and Grafana
- **Prometheus** is the industry standard for Kubernetes metrics. It also scrapes and stores metrics
- **Grafana** connects to both Prometheus and Loki, so one tool covers everything
- On a real AKS cluster I would also consider **Azure Monitor** as a complement 
  since it integrates natively with AKS and requires no extra setup


## Setup Steps
1. Clone the repo
2. Make sure Docker Desktop is running
3. Navigate to `test-1-monitoring/config/`
4. Run `docker-compose up -d`
5. Open Grafana at `http://localhost:3000` (admin/admin)
6. Add Prometheus data source: `http://prometheus:9090`
7. Add Loki data source: `http://loki:3100`
8. Import dashboard JSONs from `dashboards/` folder

## Dashboards

### Dashboard 1- Cluster Health Overview
Shows CPU usage, memory usage, running containers and failed containers
Useful for a quick health check of the cluster at any time

### Dashboard 2- Application Logs
Shows all container logs filterable by container name and job
Includes an error count over time panel to spot error spikes quickly

### Dashboard 3- On-Call Overview
I chose this dashboard because on on-call, one needs to easily see which containers are generating the most logs and how many errors have occurred in the last hour. Log rate spikes most times indicate a problem before metrics do

## Alerts

### Alert 1- Node CPU Exceeds 80%
Fires when CPU usage exceeds 80% for more than 3 minutes
Sustained high CPU usually means a runaway process or traffic spike

### Alert 2- Pod CrashLoopBackOff
Fires when a pod has been crashing repeatedly for more than 5 minutes
CrashLoopBackOff is one of the most common and critical pod failure states

### Alert 3- High Memory Usage (My Choice)
Fires when memory exceeds 500MB. I chose this because memory leaks in containerised apps are common and often go unnoticed until the container is OOMKilled. Early detection prevents unexpected restarts.

## What I Would Improve
- Set up Promtail to collect real Docker container logs automatically- I experienced some difficulty with Windows but I'm sure it works different on Linux
- Add alerting notification channels like Slack
- Add more metrics using node-exporter for real hardware metrics
- Set up persistent alert history