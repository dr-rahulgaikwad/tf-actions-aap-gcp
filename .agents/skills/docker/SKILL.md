---
name: docker
description: Docker containerization, development workflows, and troubleshooting for HashiCorp projects
---

# Docker Development

This skill covers Docker usage for HashiCorp development, including container management, debugging, performance monitoring, and troubleshooting common issues.

## When to Use This Skill

Use this skill when you need to:
- Manage Docker containers in development
- Debug container startup issues or crashes
- Monitor container performance and resource usage
- Clean up Docker disk space
- Troubleshoot Docker networking or volume issues
- Access shells inside running or stopped containers

## Installation & Setup

### Prerequisites
- Docker Desktop (Mac/Windows) or Docker Engine (Linux)
- Sufficient disk space (Docker images and volumes can consume significant space)

### Verify Installation
Check if Docker is correctly installed:

```bash
docker run hello-world
```

If this runs successfully, Docker is properly configured.

### System Information
Check Docker version and configuration:

```bash
docker info
docker --version
```

## Core Concepts

### Containers vs Images
- **Image**: A read-only template containing the application and dependencies
- **Container**: A running instance of an image

### Common Docker Objects
- **Containers**: Running or stopped application instances
- **Images**: Templates for creating containers
- **Volumes**: Persistent data storage
- **Networks**: Container networking configuration

## Essential Commands

### Container Management

**List running containers:**
```bash
docker ps
```

**List all containers (including stopped):**
```bash
docker ps -a
```

**Start a container:**
```bash
docker start <container_name>
```

**Stop a container:**
```bash
docker stop <container_name>
```

**Restart a container:**
```bash
docker restart <container_name>
```

**Stop all running containers:**
```bash
docker kill $(docker ps -q)
```

### Viewing Logs

**View container logs:**
```bash
docker logs <container_name>
```

**Follow logs in real-time:**
```bash
docker logs -f <container_name>
```

**Filter logs (example for specific text):**
```bash
docker logs -f <container_name> 2>&1 | grep ERROR
```

**Save logs to a file:**
```bash
docker logs <container_name> >& container.log
```

### Performance Monitoring

**Live performance stats for all containers:**
```bash
docker stats
```

**One-time stats for a specific container:**
```bash
docker stats --no-stream <container_name>
```

### Accessing Containers

**Get a shell inside a running container:**
```bash
docker exec -it <container_name> /bin/bash
```

**If bash is not available, try sh:**
```bash
docker exec -it <container_name> /bin/sh
```

**Run a command in a running container:**
```bash
docker exec -it <container_name> <command>
```

Example - run curl inside a container:
```bash
docker exec -it <container_name> curl http://localhost:8080/health
```

**Get a shell inside a stopped container:**
```bash
docker run -it <image_name> /bin/bash
```

**Override entrypoint for debugging:**
```bash
docker run -ti --entrypoint /bin/bash <image_name>
```

**Start an image and run a command:**
```bash
docker run --rm -it <image_name> <command>
```

## Disk Space Management

### Check Disk Usage

**See current Docker disk usage:**
```bash
docker system df
```

This shows space used by:
- Images
- Containers
- Volumes
- Build cache

### Clean Up Disk Space

**Remove unused containers, networks, and images (safe):**
```bash
docker system prune
```

**Remove unused volumes (be careful - this deletes data):**
```bash
docker volume prune
```

**Aggressive cleanup (removes everything not in use):**
```bash
docker system prune -a --volumes
```

⚠️ **Warning**: `docker system prune -a --volumes` will delete:
- All stopped containers
- All networks not used by at least one container
- All volumes not used by at least one container
- All images without at least one container
- All build cache

Only use this if you're certain you want to remove everything.

## Common Workflows

### Workflow 1: Debugging a Container That Won't Start

1. Check if the container is running:
   ```bash
   docker ps -a | grep <container_name>
   ```

2. View container logs to see the error:
   ```bash
   docker logs <container_name>
   ```

3. If needed, try starting with a shell to debug:
   ```bash
   docker run -it --entrypoint /bin/bash <image_name>
   ```

4. Check the container's configuration:
   ```bash
   docker inspect <container_name>
   ```

### Workflow 2: Investigating Performance Issues

1. Check real-time resource usage:
   ```bash
   docker stats
   ```

2. Look for containers using excessive CPU or memory

3. Check logs for errors or warnings:
   ```bash
   docker logs <container_name> 2>&1 | grep -i "error\|warning"
   ```

4. Inspect network or volume issues:
   ```bash
   docker network ls
   docker volume ls
   ```

### Workflow 3: Cleaning Up Development Environment

1. Stop all running containers:
   ```bash
   docker kill $(docker ps -q)
   ```

2. Check disk usage:
   ```bash
   docker system df
   ```

3. Remove unused resources:
   ```bash
   docker system prune
   ```

4. If more space is needed, remove volumes (be careful):
   ```bash
   docker volume prune
   ```

## Troubleshooting

### Issue 1: "Cannot connect to Docker daemon"

**Symptoms:**
- `docker ps` or other commands fail
- Error: "Cannot connect to the Docker daemon at unix:///var/run/docker.sock"

**Cause:**
- Docker service is not running
- Docker socket has incorrect permissions

**Solution:**
```bash
# Restart Docker service (Linux)
sudo systemctl daemon-reload
sudo service docker restart

# Check Docker socket permissions
ls -l /var/run/docker.sock

# Verify Docker is running
ps -eaf | grep docker
```

For Docker Desktop (Mac/Windows), restart the application.

### Issue 2: Out of Disk Space

**Symptoms:**
- Error: "no space left on device"
- Builds failing due to disk space
- Slow Docker performance

**Cause:**
- Too many old images, containers, or volumes

**Solution:**
```bash
# Check what's using space
docker system df

# Clean up unused resources
docker system prune

# If still out of space, remove volumes (careful!)
docker volume prune

# Most aggressive cleanup
docker system prune -a --volumes
```

### Issue 3: Container Exits Immediately

**Symptoms:**
- Container starts but exits right away
- `docker ps` doesn't show the container

**Cause:**
- Application crashes on startup
- Misconfigured entrypoint or command

**Solution:**
```bash
# View exit logs
docker logs <container_name>

# Try running with an interactive shell
docker run -it --entrypoint /bin/bash <image_name>

# Check the container's last state
docker inspect <container_name>
```

### Issue 4: Networking Issues

**Symptoms:**
- Container can't connect to other containers
- Can't access container from host

**Cause:**
- Network configuration issues
- Firewall blocking Docker

**Solution:**
```bash
# List Docker networks
docker network ls

# Inspect network configuration
docker network inspect <network_name>

# Ensure firewall allows Docker (Linux)
sudo iptables -A INPUT -i docker0 -j ACCEPT

# Restart Docker networking
sudo service docker restart
```

## Diagnostic Process

When encountering Docker issues, follow this systematic approach:

### 1. Identify Error Type

**Container Issues:**
- Won't start? Check logs: `docker logs <container_name>`
- Exits immediately? Check exit code: `docker inspect <container_name> | grep ExitCode`
- Running but not working? Check logs and exec into container

**Build Issues:**
- Build failing? Review build output for specific error
- Slow builds? Check for large context or missing `.dockerignore`
- Cache issues? Try `docker build --no-cache`

**Network Issues:**
- Can't connect between containers? Check network: `docker network inspect <network>`
- Can't reach from host? Check port mappings: `docker port <container_name>`
- DNS issues? Check `/etc/resolv.conf` inside container

**Performance Issues:**
- High CPU/Memory? Check `docker stats`
- Disk space? Check `docker system df`
- Slow I/O? Check volume mounts and drivers

### 2. Check Recent Changes

**Questions to ask:**
- Did you update Docker recently?
- Did you change the Dockerfile or docker-compose.yml?
- Did you add new dependencies or volumes?
- Did you change network configuration?
- Did system resources (disk, memory) decrease?

**Check recent Docker activity:**
```bash
# Recent container activity
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"

# Recent images
docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}"

# System events
docker events --since 1h
```

### 3. Isolate Issue

**Reproduce the problem:**
```bash
# Try stopping and starting
docker stop <container_name>
docker start <container_name>

# Try recreating the container
docker rm <container_name>
docker run ...  # with same configuration

# Try with minimal configuration
docker run -it --rm <image_name> /bin/bash
```

**Test in isolation:**
```bash
# Run container by itself (not in compose)
docker run -it <image_name>

# Test without volumes
docker run -it <image_name>  # no -v flags

# Test without custom network
docker run -it <image_name>  # no --network flag

# Test on different host (if available)
```

**Environment-specific?**
- Does it work locally but fail in CI/CD?
- Does it work on one machine but not another?
- Does it work with different Docker versions?

### 4. Apply Solution

**Start with least disruptive fixes:**
```bash
# 1. Restart container
docker restart <container_name>

# 2. Restart Docker daemon (if needed)
sudo systemctl restart docker  # Linux
# Or restart Docker Desktop (Mac/Windows)

# 3. Clear caches and rebuild
docker builder prune
docker build --no-cache -t <image_name> .

# 4. Remove and recreate
docker rm <container_name>
docker run ...
```

**More aggressive fixes (if needed):**
```bash
# Remove unused resources
docker system prune

# Remove specific images/volumes
docker rmi <image>
docker volume rm <volume>

# Reset Docker (last resort - loses all data)
docker system prune -a --volumes
```

### 5. Verify Fix

**Confirm resolution:**
```bash
# Container runs successfully
docker ps | grep <container_name>

# No errors in logs
docker logs <container_name>

# Application responds correctly
docker exec <container_name> curl http://localhost:8080/health

# Resources are normal
docker stats --no-stream <container_name>
```

**Document the solution:**
- Note what fixed the issue
- Update documentation if configuration changed
- Share with team if it's a common problem

## Common Docker Patterns to Check

Quick reference for common Docker configurations and mistakes.

### Container Configuration

**Proper entrypoint and cmd:**
```dockerfile
# Dockerfile - use exec form (preferred)
ENTRYPOINT ["nginx"]
CMD ["-g", "daemon off;"]

# Not shell form (creates extra process)
ENTRYPOINT nginx -g 'daemon off;'
```

**Health checks:**
```dockerfile
# Add health check to Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

Check health status:
```bash
docker inspect --format='{{.State.Health.Status}}' <container_name>
```

**Environment variables:**
```bash
# Pass environment variables
docker run -e DATABASE_URL=postgres://... <image>

# From file
docker run --env-file .env <image>

# Check what's set
docker exec <container_name> env
```

### Volume Configuration

**Named volumes (preferred for data):**
```bash
# Create named volume
docker volume create my-data

# Use in container
docker run -v my-data:/data <image>

# Inspect volume
docker volume inspect my-data
```

**Bind mounts (for development):**
```bash
# Mount local directory
docker run -v $(pwd):/app <image>

# With read-only flag
docker run -v $(pwd):/app:ro <image>
```

**Common volume issues:**
```bash
# Check if volume exists
docker volume ls | grep my-data

# Check volume permissions
docker run --rm -v my-data:/data alpine ls -la /data

# Fix permissions (run as root)
docker run --rm -v my-data:/data alpine chown -R 1000:1000 /data
```

### Network Configuration

**Container networking:**
```bash
# Create custom network
docker network create my-network

# Run containers on same network
docker run --network my-network --name app <image>
docker run --network my-network --name db <image>

# Containers can reach each other by name
docker exec app ping db
```

**Port mapping:**
```bash
# Map host port to container port
docker run -p 8080:80 <image>

# Multiple ports
docker run -p 8080:80 -p 8443:443 <image>

# Bind to specific interface
docker run -p 127.0.0.1:8080:80 <image>

# Check mapped ports
docker port <container_name>
```

**Common network issues:**
```bash
# Check container's network
docker inspect <container_name> | grep -A 10 Networks

# Test connectivity from container
docker exec <container_name> ping google.com
docker exec <container_name> nslookup google.com

# Check DNS resolution
docker exec <container_name> cat /etc/resolv.conf
```

### Resource Limits

**Set CPU and memory limits:**
```bash
# Limit memory
docker run -m 512m <image>

# Limit CPU
docker run --cpus="1.5" <image>

# Both
docker run -m 512m --cpus="1.0" <image>

# Check limits
docker inspect <container_name> | grep -A 5 Memory
```

**In docker-compose.yml:**
```yaml
services:
  app:
    image: my-app
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 512M
        reservations:
          cpus: '0.5'
          memory: 256M
```

### Logging

**Configure logging driver:**
```bash
# Check current logging driver
docker inspect --format='{{.HostConfig.LogConfig.Type}}' <container_name>

# Run with specific logging
docker run --log-driver json-file --log-opt max-size=10m --log-opt max-file=3 <image>
```

**Access logs:**
```bash
# View logs
docker logs <container_name>

# Last 100 lines
docker logs --tail 100 <container_name>

# Since timestamp
docker logs --since 2024-01-01T00:00:00 <container_name>

# Follow logs with timestamps
docker logs -f --timestamps <container_name>
```

### Build Optimization

**.dockerignore (must have):**
```
# .dockerignore file
node_modules/
npm-debug.log
.git/
.env
*.md
.DS_Store
coverage/
.pytest_cache/
__pycache__/
*.pyc
```

**Multi-stage builds:**
```dockerfile
# Build stage
FROM golang:1.21 AS builder
WORKDIR /app
COPY . .
RUN go build -o myapp

# Runtime stage (smaller)
FROM alpine:latest
COPY --from=builder /app/myapp /usr/local/bin/
CMD ["myapp"]
```

**Layer optimization:**
```dockerfile
# Bad - creates many layers
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get clean

# Good - single layer
RUN apt-get update && \
    apt-get install -y curl git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
```

**Build cache usage:**
```dockerfile
# Copy dependency files first (cached if unchanged)
COPY package.json package-lock.json ./
RUN npm ci

# Copy application code last (changes frequently)
COPY . .
```

### Security

**Run as non-root user:**
```dockerfile
# Create user in Dockerfile
RUN adduser -D -u 1000 appuser
USER appuser

# Or in docker run
docker run --user 1000:1000 <image>
```

**Read-only filesystem:**
```bash
# Run with read-only root filesystem
docker run --read-only -v /tmp <image>
```

**Drop capabilities:**
```bash
# Drop all capabilities, add only what's needed
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE <image>
```

**Secrets management:**
```bash
# Use Docker secrets (Swarm)
echo "my-secret" | docker secret create db-password -

# Use environment variables (less secure)
docker run -e DB_PASSWORD=$(cat password.txt) <image>

# Use mounted file (better)
docker run -v $(pwd)/secrets:/secrets:ro <image>
```

### Common Mistakes to Avoid

**1. Not cleaning up:**
```bash
# Always use --rm for temporary containers
docker run --rm <image>

# Or clean up manually
docker container prune
```

**2. Using `latest` tag:**
```bash
# Bad - unpredictable
docker run my-app:latest

# Good - specific version
docker run my-app:v1.2.3
```

**3. Exposing unnecessary ports:**
```dockerfile
# Only expose what's needed
EXPOSE 8080

# Not all internal ports
```

**4. Large images:**
```dockerfile
# Use minimal base images
FROM alpine:latest  # ~5MB
# Instead of
FROM ubuntu:latest  # ~70MB
```

**5. Running as root:**
```dockerfile
# Always create and use non-root user
USER appuser
```

## Best Practices

- **Use named volumes** for data that needs to persist
- **Clean up regularly** to avoid disk space issues
- **Use `.dockerignore`** to exclude unnecessary files from builds
- **Tag images** with meaningful versions, not just `latest`
- **Monitor container logs** for errors and warnings
- **Use health checks** in production containers
- **Limit container resources** (CPU/memory) to prevent resource hogging
- **Keep images small** by using multi-stage builds and minimal base images

## HashiCorp-Specific Tips

Many HashiCorp products run in containers:
- **Terraform Cloud/Enterprise**: Uses containers for runs and workers
- **Vault**: Can run in containers for development
- **Consul**: Often deployed in containerized environments
- **Nomad**: Orchestrates Docker containers

When working with HashiCorp products in containers:
- Check product-specific documentation for recommended Docker configurations
- Use official HashiCorp images from Docker Hub when available
- Be aware of authentication requirements (e.g., Doormat for private registries)

## Additional Resources

- **Official Docker Documentation**: https://docs.docker.com
- **Docker CLI Reference**: https://docs.docker.com/engine/reference/commandline/cli/
- **HashiCorp Docker Images**: https://hub.docker.com/u/hashicorp
- **Internal Confluence**: https://hashicorp.atlassian.net/wiki/spaces/~361427045/pages/2269315449/Docker

## Summary

**Most Common Commands:**
```bash
# Container management
docker ps                                    # List running containers
docker logs -f <container_name>              # Follow logs
docker exec -it <container_name> /bin/bash   # Get shell in container
docker restart <container_name>              # Restart container

# Performance monitoring
docker stats                                 # Live container stats

# Cleanup
docker system df                             # Check disk usage
docker system prune                          # Clean up unused resources

# Debugging
docker inspect <container_name>              # Detailed container info
docker run -it --entrypoint /bin/bash <image> # Debug image
```

**Remember:**
- Always check logs first when debugging: `docker logs <container_name>`
- Use `docker stats` to identify performance issues
- Clean up regularly with `docker system prune` to avoid disk space problems
- Use `docker exec -it` to access running containers for debugging
