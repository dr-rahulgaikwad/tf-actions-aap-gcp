---
name: kubernetes
description: Using HashiCorp products with Kubernetes (EKS/AKS/GKE, Terraform, Vault, Consul, Nomad, Boundary, Waypoint). Use for Kubernetes workflows, provisioning, and platform integration.
---

# Kubernetes with HashiCorp

Guide to using HashiCorp products with Kubernetes.

## HashiCorp Products on Kubernetes

**Terraform**: Provision and manage Kubernetes clusters and resources
**Vault**: Secrets management, PKI, encryption for K8s workloads
**Consul**: Service mesh on Kubernetes with Consul Connect
**Nomad**: Alternative workload orchestrator (or alongside K8s)
**Boundary**: Secure access to K8s clusters and pods
**Waypoint**: Deploy applications to Kubernetes

## Kubernetes Providers

**Managed Kubernetes Services**:
- **AWS**: EKS (Elastic Kubernetes Service)
- **Azure**: AKS (Azure Kubernetes Service)
- **GCP**: GKE (Google Kubernetes Engine)

See `/aws`, `/azure`, and `/gcp` skills for cloud-specific K8s deployment.

## Common Workflows

### Terraform for Kubernetes

**Provision EKS cluster**:
```hcl
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 19.0"

  cluster_name    = "my-cluster"
  cluster_version = "1.28"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    default = {
      min_size     = 1
      max_size     = 3
      desired_size = 2

      instance_types = ["t3.medium"]
    }
  }
}
```

**Manage K8s resources**:
```hcl
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
  }
}

resource "kubernetes_namespace" "app" {
  metadata {
    name = "my-app"
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name      = "web"
    namespace = kubernetes_namespace.app.metadata[0].name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "web"
      }
    }

    template {
      metadata {
        labels = {
          app = "web"
        }
      }

      spec {
        container {
          name  = "web"
          image = "nginx:latest"
        }
      }
    }
  }
}
```

### Vault on Kubernetes

**Install Vault via Helm**:
```bash
# Add HashiCorp Helm repo
helm repo add hashicorp https://helm.releases.hashicorp.com

# Install Vault in HA mode
helm install vault hashicorp/vault \
  --set server.ha.enabled=true \
  --set server.ha.replicas=3 \
  --set server.ha.raft.enabled=true
```

**Kubernetes Auth Method**:
```bash
# Enable Kubernetes auth
vault auth enable kubernetes

# Configure with K8s API
vault write auth/kubernetes/config \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

# Create role for pods
vault write auth/kubernetes/role/app-role \
  bound_service_account_names=app-sa \
  bound_service_account_namespaces=default \
  policies=app-policy \
  ttl=24h
```

**Vault Agent Sidecar Injection**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  annotations:
    vault.hashicorp.com/agent-inject: "true"
    vault.hashicorp.com/role: "app-role"
    vault.hashicorp.com/agent-inject-secret-db: "database/creds/readonly"
    vault.hashicorp.com/agent-inject-template-db: |
      {{- with secret "database/creds/readonly" -}}
      username: {{ .Data.username }}
      password: {{ .Data.password }}
      {{- end }}
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: my-app:latest
```

**Vault CSI Provider**:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
spec:
  serviceAccountName: app-sa
  containers:
  - name: app
    image: my-app:latest
    volumeMounts:
    - name: secrets
      mountPath: "/mnt/secrets"
      readOnly: true
  volumes:
  - name: secrets
    csi:
      driver: secrets-store.csi.k8s.io
      readOnly: true
      volumeAttributes:
        secretProviderClass: "vault-database"
```

### Consul on Kubernetes

**Install Consul via Helm**:
```bash
# Install Consul with service mesh
helm install consul hashicorp/consul \
  --set global.name=consul \
  --set connectInject.enabled=true \
  --set client.enabled=true \
  --set server.replicas=3 \
  --set ui.enabled=true
```

**Service Mesh Injection**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: web
spec:
  selector:
    app: web
  ports:
  - port: 80
    targetPort: 8080
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
      annotations:
        "consul.hashicorp.com/connect-inject": "true"
    spec:
      containers:
      - name: web
        image: my-web-app:latest
        ports:
        - containerPort: 8080
```

**Service Intentions (L7 policies)**:
```yaml
apiVersion: consul.hashicorp.com/v1alpha1
kind: ServiceIntentions
metadata:
  name: web-to-database
spec:
  destination:
    name: database
  sources:
  - name: web
    action: allow
```

### Waypoint on Kubernetes

**waypoint.hcl for K8s**:
```hcl
project = "my-app"

app "web" {
  build {
    use "docker" {}
  }

  deploy {
    use "kubernetes" {
      replicas = 3

      probe_path = "/health"

      service_port = 8080

      resources {
        requests = {
          memory = "256Mi"
          cpu    = "250m"
        }
      }
    }
  }

  release {
    use "kubernetes" {
      ingress {
        host = "myapp.example.com"
      }
    }
  }
}
```

**Deploy**:
```bash
# Initialize Waypoint
waypoint init

# Build, deploy, and release
waypoint up
```

### Boundary for Kubernetes Access

**Access K8s API without kubectl config**:
```bash
# Create target for K8s API
boundary targets create tcp \
  -name="k8s-api" \
  -default-port=6443 \
  -address="api.k8s.example.com"

# Connect and use kubectl
boundary connect tcp -target-id ttcp_abc123 -- kubectl get pods
```

**Exec into pods via Boundary**:
```bash
# Create target for pod
boundary targets create tcp \
  -name="app-pod" \
  -default-port=8080 \
  -address="pod-ip.namespace.pod.cluster.local"

# Port forward
boundary connect tcp -target-id ttcp_abc123
```

## Kubernetes Integration Patterns

### Secrets Management

**Options**:
1. **Vault Agent Injector**: Sidecar pattern, automatic secret injection
2. **Vault CSI Provider**: Mount secrets as volumes
3. **External Secrets Operator**: Sync Vault secrets to K8s secrets

**Best practice**: Use Vault Agent Injector for dynamic secrets, CSI for static configs

### Service Mesh

**Consul vs Istio**:
- **Consul**: Multi-platform (K8s + VMs), HashiCorp ecosystem integration
- **Istio**: Kubernetes-native, larger ecosystem

**Consul advantages**:
- Works across K8s and VMs (hybrid deployments)
- Integrates with Vault for mTLS certificates
- Consistent experience across clouds

### Workload Identity

**Authenticate K8s pods to Vault**:
1. Pod gets JWT from K8s service account
2. Vault validates JWT with K8s API
3. Vault issues token with policies
4. Pod uses token to access secrets

**No static credentials needed**

## Best Practices

### For Vault on K8s

1. **Use Vault Agent Injector**: Automatic secret injection, rotation
2. **Enable auto-unseal**: Use cloud KMS for auto-unsealing
3. **Run in HA mode**: 3+ replicas with Raft storage
4. **Separate namespaces**: Vault in `vault` namespace
5. **Use service accounts**: K8s native auth, no static tokens

### For Consul on K8s

1. **Enable Connect**: Service mesh for mTLS and traffic management
2. **Use intentions**: Control service-to-service communication
3. **Federate clusters**: Multi-cluster service discovery
4. **Integrate with Vault**: Dynamic TLS certificates
5. **Monitor with metrics**: Prometheus integration

### For Terraform K8s

1. **Separate cluster and apps**: Different Terraform workspaces/projects
2. **Use modules**: Reusable EKS/AKS/GKE modules
3. **Manage RBAC**: Terraform for ClusterRoles, RoleBindings
4. **Version pin**: Lock K8s provider version
5. **Use Helm provider**: Manage Helm releases with Terraform

## Troubleshooting

### Vault Pods Not Starting

**Problem**: Vault pods crash or won't start.

**Solutions**:
1. Check pod logs: `kubectl logs vault-0 -n vault`
2. Verify storage class exists and is available
3. Check init/unseal status: `kubectl exec vault-0 -n vault -- vault status`
4. Verify service account has correct permissions
5. Check Raft peer configuration

### Consul Sidecar Injection Failing

**Problem**: Consul sidecar not injected into pods.

**Solutions**:
1. Verify annotation: `consul.hashicorp.com/connect-inject: "true"`
2. Check webhook is running: `kubectl get mutatingwebhookconfigurations`
3. Review inject logs: `kubectl logs -l component=connect-injector -n consul`
4. Ensure namespace not in deny list
5. Verify TLS certificates for webhook

### Vault Agent Unable to Auth

**Problem**: Vault Agent sidecar can't authenticate.

**Solutions**:
1. Verify service account exists and mounted
2. Check Vault K8s auth configuration
3. Validate role bindings: service account → namespace → role
4. Review agent logs in init container
5. Ensure Vault is reachable from pods

### Terraform K8s Provider Auth Issues

**Problem**: Terraform can't authenticate to K8s cluster.

**Solutions**:
1. Verify kubeconfig or exec auth configured correctly
2. Check cloud provider credentials (for EKS/AKS/GKE)
3. Ensure cluster endpoint is reachable
4. Validate certificate authority data
5. Try manual kubectl to verify config

## Additional Resources

### HashiCorp Documentation
- [Vault on Kubernetes](https://developer.hashicorp.com/vault/docs/platform/k8s)
- [Consul on Kubernetes](https://developer.hashicorp.com/consul/docs/k8s)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs)
- [Waypoint on Kubernetes](https://developer.hashicorp.com/waypoint/docs/platforms/kubernetes)

### Helm Charts
- [Vault Helm Chart](https://github.com/hashicorp/vault-helm)
- [Consul Helm Chart](https://github.com/hashicorp/consul-k8s)

### Internal Resources
- [Kubernetes Guide](https://hashicorp.atlassian.net/wiki/spaces/~361427045/pages/2523725975/Kubernetes)

### Related Skills
- `/terraform` - Infrastructure as Code
- `/vault` - Secrets management
- `/consul` - Service mesh
- `/waypoint` - Application deployment
- `/boundary` - Secure access
- `/aws` - EKS on AWS
- `/azure` - AKS on Azure
- `/gcp` - GKE on GCP

---

*For HashiCorp internal use. Contribute at [hashicorp-agent-skills](https://github.com/hashicorp/hashicorp-agent-skills).*
