---
name: container-testing
description: Use podman instead of Docker for container testing
---

## Container Runtime Preference

**ALWAYS use `podman` instead of `Docker` when testing with containers.**

### When Working with Containers

Whenever you need to:
- Build container images
- Run containers for testing
- Push/pull container images
- Manage container lifecycle
- Execute commands in containers
- Inspect container logs or status

### Use Podman Commands

Replace Docker commands with their Podman equivalents:

| Docker Command | Podman Command |
|----------------|----------------|
| `docker build` | `podman build` |
| `docker run` | `podman run` |
| `docker ps` | `podman ps` |
| `docker images` | `podman images` |
| `docker pull` | `podman pull` |
| `docker push` | `podman push` |
| `docker exec` | `podman exec` |
| `docker logs` | `podman logs` |
| `docker stop` | `podman stop` |
| `docker rm` | `podman rm` |
| `docker rmi` | `podman rmi` |

### Example Usage

```bash
# Build an image
podman build -t myapp:latest .

# Run a container
podman run -d -p 8080:8080 --name myapp myapp:latest

# View running containers
podman ps

# Execute command in container
podman exec -it myapp /bin/bash

# View logs
podman logs myapp

# Stop and remove
podman stop myapp
podman rm myapp
```

### Docker Compose Alternative

For multi-container applications, use `podman-compose`:

```bash
# Instead of docker-compose
podman-compose up -d
podman-compose down
```

Or use Podman's native pod support:

```bash
# Create a pod (similar to docker-compose)
podman pod create --name myapp-pod -p 8080:8080

# Run containers in the pod
podman run -d --pod myapp-pod --name web nginx
podman run -d --pod myapp-pod --name db postgres