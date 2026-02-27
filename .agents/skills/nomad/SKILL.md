---
name: nomad
description: HashiCorp Nomad workload orchestrator for deploying and managing containerized and legacy applications
---

# HashiCorp Nomad

This skill covers HashiCorp Nomad, a flexible workload orchestrator and scheduler that runs both containerized and legacy applications using a unified, declarative workflow.

## When to Use This Skill

Use this skill when you need to:
- Orchestrate Docker containers and other workloads
- Run both modern and legacy applications on a single platform
- Deploy applications across hybrid cloud environments
- Schedule batch jobs, long-running services, or system jobs
- Manage GPU/ML workloads with device plugins
- Implement multi-region application deployments

## What is Nomad?

**Nomad is a flexible workload orchestrator and scheduler** that can run both **containerized and legacy applications** using a **unified, declarative workflow**.

### What Makes Nomad Unique

Unlike Kubernetes (containers-only), Nomad supports:
- **Docker containers**
- **VMs and raw executables**
- **Java applications**
- **Batch jobs**
- **Windows workloads**
- **GPUs and specialized hardware**

All with a **single binary** and **unified workflow**.

## Key Features

| Feature | Description |
| --- | --- |
| **Mixed Workloads** | Orchestrates both **containerized** and **non-containerized** (legacy) apps |
| **Simple & Lightweight** | **Single binary**, no external dependencies, resilient via leader election |
| **Device & GPU Support** | Supports **ML/AI workloads** via plugins for GPU, FPGA, TPU hardware |
| **Multi-region Federation** | Natively supports **federated clusters** across regions |
| **High Scalability** | Optimistically concurrent – scales to **10,000+ nodes** and millions of containers |
| **HashiCorp Ecosystem Integration** | Works with **Terraform**, **Consul**, and **Vault** |
| **Simple Architecture** | No external services required (no etcd, ZooKeeper, etc.) |
| **Multi-platform** | Runs on Linux, Windows, macOS - supports hybrid environments |

## How Nomad Works

### Architecture

**Single binary** for both servers and clients:
- **Servers** - Manage cluster state, schedule workloads, leader election (3 or 5 servers)
- **Clients** - Execute allocated tasks, report health, fingerprint resources

**No external dependencies** required:
- State stored in servers using Raft consensus
- No need for etcd, ZooKeeper, or external databases

**Unix philosophy**:
- Focus on **scheduling and orchestration**
- Other concerns handled by ecosystem:
  - **Service mesh** → Consul
  - **Secrets** → Vault
  - **Provisioning** → Terraform

### Workflow

1. **Write Job Specification** - Define workload in HCL or JSON
2. **Submit Job** - Send to Nomad servers
3. **Evaluation** - Servers create execution plan
4. **Scheduling** - Place tasks on appropriate clients
5. **Execution** - Clients run tasks and report status
6. **Monitoring** - Continuous health checking and rescheduling

## Installation & Setup

### Install Nomad

**macOS (Homebrew):**
```bash
brew install nomad
```

**Linux:**
```bash
# Download from releases
wget https://releases.hashicorp.com/nomad/<version>/nomad_<version>_linux_amd64.zip
unzip nomad_<version>_linux_amd64.zip
sudo mv nomad /usr/local/bin/
```

**Verify Installation:**
```bash
nomad version
```

### Development Server

For local development, start a dev server:

```bash
nomad agent -dev
```

This starts Nomad in dev mode with:
- Combined server + client in one process
- In-memory storage
- UI accessible at http://127.0.0.1:4646
- No ACLs enabled

### Production Setup

For production, you need:
1. **Server nodes** (3 or 5 for quorum)
2. **Client nodes** for running workloads
3. **ACLs enabled** for security
4. **TLS** for encrypted communication
5. **Integration** with Consul and Vault

See [Nomad deployment guide](https://developer.hashicorp.com/nomad/docs/install) for details.

## Common Commands

### Agent Operations

**Start Nomad server:**
```bash
nomad agent -server -config=server.hcl
```

**Start Nomad client:**
```bash
nomad agent -client -config=client.hcl
```

**Check cluster members:**
```bash
nomad server members     # Server nodes
nomad node status        # Client nodes
```

### Job Management

**Run a job:**
```bash
nomad job run example.nomad
```

**Check job status:**
```bash
nomad job status example
```

**Stop a job:**
```bash
nomad job stop example
```

**View job history:**
```bash
nomad job history example
```

**Plan a job (dry-run):**
```bash
nomad job plan example.nomad
```

### Allocation Management

**List allocations:**
```bash
nomad alloc status
```

**View specific allocation:**
```bash
nomad alloc status <alloc-id>
```

**View allocation logs:**
```bash
nomad alloc logs <alloc-id>
```

**Get shell in allocation:**
```bash
nomad alloc exec <alloc-id> /bin/sh
```

### Node Operations

**List nodes:**
```bash
nomad node status
```

**Drain a node (for maintenance):**
```bash
nomad node drain -enable <node-id>
```

**Mark node eligible again:**
```bash
nomad node drain -disable <node-id>
```

## Job Specification Example

Here's a simple web service job:

```hcl
job "webapp" {
  datacenters = ["dc1"]
  type = "service"

  group "web" {
    count = 3

    network {
      port "http" {
        to = 8080
      }
    }

    service {
      name = "webapp"
      port = "http"

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "server" {
      driver = "docker"

      config {
        image = "myapp:latest"
        ports = ["http"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
```

## Common Workflows

### Workflow 1: Deploying a Docker Application

1. **Create job file (`webapp.nomad`):**
   ```hcl
   job "webapp" {
     datacenters = ["dc1"]

     group "web" {
       task "app" {
         driver = "docker"

         config {
           image = "nginx:latest"
           ports = ["http"]
         }

         resources {
           cpu    = 500
           memory = 256
         }
       }
     }
   }
   ```

2. **Plan the job:**
   ```bash
   nomad job plan webapp.nomad
   ```

3. **Run the job:**
   ```bash
   nomad job run webapp.nomad
   ```

4. **Check status:**
   ```bash
   nomad job status webapp
   ```

### Workflow 2: Running a Batch Job

1. **Create batch job:**
   ```hcl
   job "data-processing" {
     type = "batch"

     group "process" {
       task "worker" {
         driver = "exec"

         config {
           command = "/usr/bin/python3"
           args    = ["process_data.py"]
         }
       }
     }
   }
   ```

2. **Submit and monitor:**
   ```bash
   nomad job run data-processing.nomad
   nomad job status data-processing
   ```

### Workflow 3: Multi-Region Deployment

1. **Configure federation** between regions
2. **Create multi-region job:**
   ```hcl
   job "global-app" {
     datacenters = ["dc1", "dc2"]
     multiregion {
       strategy {
         max_parallel = 1
         on_failure   = "fail_all"
       }

       region "us-west" {
         count = 2
       }

       region "us-east" {
         count = 2
       }
     }
   }
   ```

3. **Deploy globally:**
   ```bash
   nomad job run global-app.nomad
   ```

## Job Types

Nomad supports different job types for different use cases:

| Type | Description | Use Case |
| --- | --- | --- |
| **service** | Long-running applications | Web servers, APIs, databases |
| **batch** | Short-lived tasks | Data processing, ETL, analytics |
| **system** | Runs on every node | Monitoring agents, log collectors |
| **sysbatch** | Batch job on every node | System maintenance, updates |

## Troubleshooting

### Issue 1: Job Not Scheduling

**Symptoms:**
- Job shows as "pending"
- No allocations created

**Cause:**
- Insufficient resources on clients
- Constraints not met
- No eligible nodes

**Solution:**
```bash
# Check why job isn't placing
nomad job status example

# View detailed placement information
nomad job plan example.nomad

# Check node resources
nomad node status

# View node details
nomad node status <node-id>
```

### Issue 2: Allocation Failing

**Symptoms:**
- Allocations keep restarting
- Tasks failing health checks

**Cause:**
- Application errors
- Resource limits too low
- Missing dependencies

**Solution:**
```bash
# Check allocation logs
nomad alloc logs <alloc-id>

# View allocation status
nomad alloc status <alloc-id>

# Get shell for debugging
nomad alloc exec <alloc-id> /bin/sh

# Check events
nomad alloc status <alloc-id> | grep Events
```

### Issue 3: Nodes Not Joining

**Symptoms:**
- Client nodes not appearing in cluster
- Server members not forming quorum

**Cause:**
- Network connectivity issues
- Incorrect configuration
- Firewall blocking ports

**Solution:**
```bash
# Check server members
nomad server members

# Verify client configuration
nomad node status

# Check logs
journalctl -u nomad

# Test connectivity
telnet <server-ip> 4647
```

## Best Practices

### Job Design
- **Use service jobs** for long-running applications
- **Use batch jobs** for finite tasks
- **Set resource limits** appropriately (CPU, memory)
- **Define health checks** for service reliability
- **Use update strategies** for zero-downtime deployments

### Resource Management
- **Size resources appropriately** - Too small causes OOM, too large wastes capacity
- **Use affinity rules** to influence placement
- **Set constraints** for specific requirements (OS, hardware, etc.)
- **Monitor resource utilization** and adjust

### High Availability
- **Run 3 or 5 servers** for production
- **Distribute across availability zones**
- **Use group count > 1** for critical services
- **Implement health checks** for automatic recovery
- **Plan for node failures** with appropriate spread

### Integration
- **Use Consul** for service discovery and health checking
- **Use Vault** for secrets management
- **Use Terraform** for infrastructure provisioning
- **Enable ACLs** for security in production

## HashiCorp-Specific Tips

### Integration with Other Tools

**With Consul:**
- Automatic service registration
- Service mesh via Consul Connect
- Health check integration
- DNS-based service discovery

**With Vault:**
- Automatic secret injection
- Dynamic database credentials
- PKI certificate management
- Encryption key rotation

**With Terraform:**
- Provision Nomad infrastructure
- Manage job deployments
- Configure cluster settings
- Automate scaling

### Device Plugins

Nomad supports specialized hardware:
- **NVIDIA GPUs** for ML/AI workloads
- **FPGAs** for specialized computing
- **TPUs** for TensorFlow workloads

Example GPU allocation:
```hcl
resources {
  device "nvidia/gpu" {
    count = 1
  }
}
```

## Why Customers Use Nomad

- **Unified orchestration** for all app types on single infrastructure
- **Low operational overhead** with simple architecture
- **Fast time-to-market** through HashiCorp ecosystem integration
- **Suitable for hybrid environments** (Linux, Windows, on-prem, cloud)
- **Simpler than Kubernetes** for many use cases
- **Scales to very large deployments** (10,000+ nodes)

## Additional Resources

- **Official Nomad Documentation**: https://developer.hashicorp.com/nomad
- **Nomad Learn**: https://developer.hashicorp.com/nomad/tutorials
- **Nomad API Reference**: https://developer.hashicorp.com/nomad/api-docs
- **Job Specification**: https://developer.hashicorp.com/nomad/docs/job-specification
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~7120203b08a819769e47afa57115b188ef7efc/pages/4058415301/Nomad

## Summary

**Most Common Commands:**
```bash
# Agent operations
nomad agent -dev                       # Start dev server
nomad server members                   # List servers
nomad node status                      # List clients

# Job management
nomad job run example.nomad            # Deploy job
nomad job status example               # Check job status
nomad job stop example                 # Stop job
nomad job plan example.nomad           # Dry-run

# Allocation management
nomad alloc status                     # List allocations
nomad alloc logs <alloc-id>           # View logs
nomad alloc exec <alloc-id> /bin/sh   # Get shell

# Node operations
nomad node drain -enable <node-id>     # Drain node
nomad node status <node-id>            # Node details
```

**Remember:**
- Nomad orchestrates any workload type (containers, VMs, executables, batch jobs)
- Single binary with no external dependencies required
- Integrates seamlessly with Consul (service mesh) and Vault (secrets)
- Supports multi-region federation natively
- Simpler operational model than Kubernetes for many use cases
- Scales to very large deployments efficiently
