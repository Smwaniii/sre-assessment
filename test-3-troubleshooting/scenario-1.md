   # Scenario 1: Pods Running But Application is Unreachable

I've seen this before and usually it's either the Service selector not matching pod labels or the Service exposing the wrong port. Since there were no code changes, I'd lean more towards something at the network layer, like an Azure NSG rule silently dropping traffic. The fact that pods are Running but unreachable usually means the app itself is fine but something upstream is blocking


## 1. First 3 kubectl commands to run to start investigating

I start with these three in order:
```bash
# 1. Check detailed pod status: "Running" doesn't always mean "healthy"
kubectl describe pods -n <namespace>

# 2. Look at Service endpoints: To check if there are any pods actually backing it
kubectl get endpoints -n <namespace>

# 3. Check if the Ingress has an IP assigned and rules are correct
kubectl get ingress -n <namespace> -o wide
```

The second command `get endpoints` is the way to see if the Service is connecting to any pods


## 2. Resources to check first and why

My debugging flow: Service- Endpoints- Ingress- NSG

**Service first:** I check if it has any endpoints. If `kubectl get endpoints` shows nothing, I know that the selector doesn't match the pod labels

**Service ports next:** I verify the `targetPort` matches the container port my app actually listens on

**Ingress third:** If the Service has endpoints, I check the Ingress host/path rules. Sometimes the backend service name is wrong or the TLS secret is missing

**NSG last:** This is Azure-specific and often gets overlooked. Even if everything in Kubernetes looks perfect, the NSG on the AKS node subnet might be blocking traffic


## 3. Testing whether the problem is at the pod level, the service level or the ingress/network layer

My thought process:

**Pod level-** first, confirm the app itself is responding:
```bash
kubectl exec -it <any-pod> -n <namespace> -- curl http://<pod-ip>:<container-port>
```

If I can't get a response here, the app might not be listening on the port I think it is. If it works, I move up

**Service level-** Hit the Service's ClusterIP from inside the cluster:
```bash
kubectl exec -it <any-pod> -n <namespace> -- curl http://<cluster-ip>:<port>
```

If this works, the Service is routing traffic correctly. If it fails, I double-check the Service configuration

**Ingress/Network level-** Check if the external IP exists:
```bash
kubectl get svc -n <namespace>  
kubectl describe ingress -n <namespace>
```

If the LoadBalancer IP is `<pending>`, the problem is with Azure provisioning: Quotas, subnet IP exhaustion or something similar


## 4. Two Azure-specific things that could cause this even when the Kubernetes resources all look correct

1. **NSG (Network Security Group) blocking traffic** — The AKS nodes are protected by an NSG. If there's a rule blocking port 80 or 443 to the node subnet or load balancer, external requests get dropped before they ever hit the cluster. Everything looks fine from a kubectl perspective, but traffic never arrives. It is easy to miss because kubectl gives you no indication and you have to go check the Azure portal directly

2. **Azure Load Balancer not provisioned / wrong SKU** — When you create a Service with type `LoadBalancer`, AKS provisions an Azure Load Balancer in the background. This can fail if the subscription has quota limits, the SKU doesn't match the cluster or the subnet is out of IPs. The external IP stays stuck at `<pending>`. I would run `az network lb list` to confirm whether the LB was actually created