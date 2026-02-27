---
name: consul
description: HashiCorp Consul service mesh, service discovery, and networking for microservices and cloud environments
---

# HashiCorp Consul

This skill covers HashiCorp Consul, a service mesh and multi-networking tool for secure, dynamic service-to-service communication across microservices and cloud environments.

## When to Use This Skill

Use this skill when you need to:
- Implement service discovery for microservices
- Set up secure service-to-service communication with mTLS
- Manage service mesh across multiple data centers
- Monitor service health and implement failover logic
- Store configuration data with the KV store
- Enforce zero-trust networking policies

## What is Consul?

**Consul is the control plane for service mesh** and a **multi-networking tool** that helps with **secure, dynamic service-to-service communication** across microservice and cloud environments.

### Core Capabilities

Consul supports:
- **Service discovery** - Services register and discover each other dynamically
- **Health checks** - Automated monitoring of service and node health
- **Key/value (KV) storage** - Configuration storage and coordination
- **mTLS-based secure communication** - Automatic certificate management
- **Multi-datacenter networking** - Global, multi-region deployments

## What is a Service Mesh?

A **service mesh** is a dedicated **network layer** for managing **secure communication between services**.

### When You Need a Service Mesh

Service meshes are most useful in **microservices architectures** where services talk to each other frequently. Instead of embedding networking logic in each service, a service mesh handles it centrally.

### Service Mesh Components

A service mesh typically includes:

**Control Plane (Consul)**:
- Manages service discovery
- Handles access policies and intentions
- Issues and rotates certificates
- Maintains service catalog

**Data Plane (Proxies like Envoy)**:
- Handles the actual traffic between services
- Enforces security policies
- Provides metrics and observability

### Benefits of Service Mesh

- **Enforces zero trust networking** - No service-to-service communication without explicit permission
- **Enables fine-grained traffic control** - Route, split, and shape traffic dynamically
- **Provides observability** - Visibility into service-to-service communication
- **Handles failover, retries, and circuit-breaking** - Without changes to application code

## Key Features of Consul

| Feature | Description |
| --- | --- |
| **Service Discovery** | Services register themselves; others discover them via DNS/HTTP API |
| **Health Checks** | Monitors node and service health for intelligent routing |
| **KV Store** | Configuration storage, feature flags, coordination via HTTP API |
| **Secure Communication** | Issues mTLS certificates and uses intentions for access control |
| **Multi-Datacenter** | Built-in support for global, multi-region deployments |
| **Service Mesh** | Control plane for managing service-to-service communication |
| **Intentions** | Access control policies between services (which can talk to whom) |

## How Consul Works

### Architecture Components

| Component | Role |
| --- | --- |
| **Consul Agent** | Runs on every node (VM, container, etc.) as either a client or server |
| **Servers** | Maintain state (service catalog, health status, KV store) using Raft consensus |
| **Clients** | Register services, run health checks, forward to servers via gossip protocol |
| **Proxies** | Handle inbound/outbound traffic for services with dynamic configuration |

### High-Level Workflow

1. **Services Register** - Applications register with local Consul agent
2. **Health Checks** - Consul monitors service and node health
3. **Discovery** - Services query Consul to find healthy instances of dependencies
4. **Secure Communication** - Proxies use mTLS for encrypted service-to-service traffic
5. **Access Control** - Intentions define which services can communicate
6. **Observability** - Metrics and logs provide visibility into traffic patterns

## Installation & Setup

### Install Consul

**macOS (Homebrew):**
```bash
brew install consul
```

**Linux:**
```bash
# Download from releases
wget https://releases.hashicorp.com/consul/<version>/consul_<version>_linux_amd64.zip
unzip consul_<version>_linux_amd64.zip
sudo mv consul /usr/local/bin/
```

**Verify Installation:**
```bash
consul version
```

### Development Server

For local development, start a dev server (NOT for production):

```bash
consul agent -dev
```

This starts Consul in dev mode with:
- In-memory storage
- Single-node cluster
- UI accessible at http://127.0.0.1:8500/ui
- No ACLs enabled

### Production Setup

For production, you need:
1. **Multiple server nodes** (3 or 5 for quorum)
2. **Client agents** on each application node
3. **ACLs enabled** for security
4. **TLS/mTLS** for encryption
5. **Service mesh** configuration
6. **Health checks** defined

See [Consul deployment guide](https://developer.hashicorp.com/consul/docs/install) for details.

## Developer Experience

One of Consul's key benefits is simplifying the developer experience:

### For Developers

Applications point to **localhost** for communication; the proxy handles everything:

```go
// Application code - just call localhost
resp, err := http.Get("http://localhost:8080")
// Traffic automatically goes through the Consul sidecar proxy
```

Consul handles:
- **Service discovery** - Finding the right service instances
- **mTLS certificates** - Including automatic rotation
- **Failover logic** - Routing around unhealthy instances
- **Load balancing** - Distributing requests

**Result**: Developers focus on **business logic**, not network wiring.

## Common Commands

### Agent Operations

**Start Consul agent:**
```bash
# Development server
consul agent -dev

# Production server
consul agent -server -config-file=/etc/consul.d/server.hcl

# Client agent
consul agent -config-file=/etc/consul.d/client.hcl
```

**Check agent members:**
```bash
consul members
```

**Check cluster status:**
```bash
consul operator raft list-peers
```

### Service Discovery

**Register a service:**
```bash
consul services register service.json
```

Example service definition (`service.json`):
```json
{
  "service": {
    "name": "web",
    "port": 8080,
    "check": {
      "http": "http://localhost:8080/health",
      "interval": "10s"
    }
  }
}
```

**Query for a service:**
```bash
# Via DNS
dig @127.0.0.1 -p 8600 web.service.consul

# Via HTTP API
curl http://localhost:8500/v1/catalog/service/web

# Via CLI
consul catalog services
consul catalog nodes -service=web
```

### Key/Value Store

**Write a key:**
```bash
consul kv put myapp/config/db_host postgres.example.com
```

**Read a key:**
```bash
consul kv get myapp/config/db_host
```

**List keys:**
```bash
consul kv get -recurse myapp/
```

**Delete a key:**
```bash
consul kv delete myapp/config/db_host
```

### Intentions (Access Control)

**Create an intention (allow web to call api):**
```bash
consul intention create -allow web api
```

**List intentions:**
```bash
consul intention list
```

**Check if communication is allowed:**
```bash
consul intention check web api
```

## Common Workflows

### Workflow 1: Setting Up Service Discovery

1. **Start Consul agent:**
   ```bash
   consul agent -dev
   ```

2. **Register a service:**
   ```bash
   cat > web.json <<EOF
   {
     "service": {
       "name": "web",
       "port": 8080,
       "check": {
         "http": "http://localhost:8080/health",
         "interval": "10s"
       }
     }
   }
   EOF

   consul services register web.json
   ```

3. **Query the service:**
   ```bash
   consul catalog services
   dig @127.0.0.1 -p 8600 web.service.consul
   ```

### Workflow 2: Enabling Service Mesh with Proxies

1. **Configure service with sidecar proxy:**
   ```json
   {
     "service": {
       "name": "web",
       "port": 8080,
       "connect": {
         "sidecar_service": {}
       }
     }
   }
   ```

2. **Start the proxy:**
   ```bash
   consul connect proxy -sidecar-for web
   ```

3. **Configure intentions:**
   ```bash
   consul intention create -allow web api
   ```

4. **Application connects via localhost** - Consul handles the rest

### Workflow 3: Multi-Datacenter Setup

1. **Configure primary datacenter** with WAN gossip
2. **Join secondary datacenter** to primary
3. **Enable mesh gateways** for cross-DC traffic
4. **Configure replication** for ACLs and intentions

See [Multi-DC guide](https://developer.hashicorp.com/consul/tutorials/datacenter-deploy/multi-datacenter) for details.

## Troubleshooting

### Issue 1: Service Not Discovered

**Symptoms:**
- DNS queries return no results
- Service not showing in catalog

**Cause:**
- Service not registered
- Health check failing
- Agent not running

**Solution:**
```bash
# Check if service is registered
consul catalog services

# Check service health
consul catalog nodes -service=myservice

# Verify agent is running
consul members

# Check logs
consul monitor
```

### Issue 2: Service Mesh Connection Failures

**Symptoms:**
- Services can't communicate
- mTLS errors
- Connection refused

**Cause:**
- Intentions blocking traffic
- Proxy not running
- Certificate issues

**Solution:**
```bash
# Check intentions
consul intention list
consul intention check source-service dest-service

# Verify proxy is running
consul connect proxy -sidecar-for myservice

# Check proxy logs
journalctl -u consul-proxy
```

### Issue 3: Cluster Not Forming

**Symptoms:**
- Servers not joining cluster
- No leader elected

**Cause:**
- Network connectivity issues
- Incorrect configuration
- Port blocking

**Solution:**
```bash
# Check cluster members
consul members

# Check raft peers
consul operator raft list-peers

# Verify network connectivity
telnet <server-ip> 8300

# Check logs
consul monitor -log-level=debug
```

## Best Practices

### Service Discovery
- **Use health checks** for all services to ensure traffic goes to healthy instances
- **Set appropriate check intervals** - Too frequent causes overhead, too infrequent misses failures
- **Use DNS for discovery** when possible - It's simpler than HTTP API

### Service Mesh
- **Enable intentions** to enforce zero-trust networking
- **Use sidecar proxies** for automatic mTLS and traffic management
- **Monitor proxy metrics** for visibility into service communication
- **Rotate certificates regularly** (Consul handles this automatically)

### High Availability
- **Run 3 or 5 servers** for production (odd numbers for quorum)
- **Distribute servers** across availability zones
- **Monitor server health** and replace failed servers promptly
- **Enable autopilot** for automatic server management

### Security
- **Enable ACLs** in production environments
- **Use TLS** for all Consul communication
- **Implement intentions** for service-to-service authorization
- **Rotate tokens and certificates** regularly

## HashiCorp-Specific Tips

### Integration with Other HashiCorp Tools

**With Terraform:**
- Use Consul for service discovery in Terraform deployments
- Store Terraform remote state in Consul KV
- Register Terraform-managed resources as Consul services

**With Vault:**
- Use Vault as Consul's CA provider for certificates
- Store Consul ACL tokens in Vault
- Use Consul for Vault's storage backend

**With Nomad:**
- Nomad integrates natively with Consul for service discovery
- Consul Connect works with Nomad for service mesh
- Nomad can automatically register tasks as Consul services

### HCP Consul

**HCP Consul** is the managed Consul service offering:
- Fully managed control plane
- Automatic upgrades and patches
- Built-in observability
- Multi-cloud support

See [HCP Consul docs](https://developer.hashicorp.com/hcp/docs/consul) for details.

## Additional Resources

- **Official Consul Documentation**: https://developer.hashicorp.com/consul
- **Consul Learn**: https://developer.hashicorp.com/consul/tutorials
- **Consul API Reference**: https://developer.hashicorp.com/consul/api-docs
- **Service Mesh Guide**: https://developer.hashicorp.com/consul/tutorials/get-started-kubernetes
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~7120203b08a819769e47afa57115b188ef7efc/pages/4058415290/Consul

## Summary

**Most Common Commands:**
```bash
# Agent operations
consul agent -dev                          # Start dev server
consul members                             # List cluster members
consul monitor                             # Stream logs

# Service discovery
consul services register service.json      # Register service
consul catalog services                    # List services
dig @127.0.0.1 -p 8600 web.service.consul # DNS query

# Key/Value store
consul kv put key value                    # Write key
consul kv get key                          # Read key
consul kv get -recurse prefix/             # List keys

# Intentions (Service Mesh)
consul intention create -allow web api     # Allow traffic
consul intention check web api             # Verify access
```

**Remember:**
- Consul provides service discovery, health checking, and service mesh capabilities
- Service mesh uses a control plane (Consul) and data plane (proxies)
- Developers connect to localhost; Consul handles routing and security
- Use intentions to enforce zero-trust networking
- Health checks are critical for reliable service discovery
- Integration with Vault, Nomad, and Terraform provides a complete platform
