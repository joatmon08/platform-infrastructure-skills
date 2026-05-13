---
name: container-testing
description: Use podman instead of Docker for container testing
---

## Container Runtime Preference

**ALWAYS use `podman` instead of `Docker` when testing with containers.**

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