# Docker Setup: Acquisitions API with Neon Database

Complete guide for running the Acquisitions API in Docker with Neon Database for both development and production environments.

## 📋 Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Development Environment](#development-environment)
- [Production Environment](#production-environment)
- [Common Commands](#common-commands)
- [Troubleshooting](#troubleshooting)

---

## Overview

This project uses Docker to containerize a Node.js Express API that connects to PostgreSQL via Neon Database.

### Two-Environment Setup

| Aspect | Development | Production |
|--------|-------------|-----------|
| Database | Neon Local (in Docker) | Neon Cloud |
| Connection | `postgres://neon:npg@neon-local:5432/neondb` | `postgres://<user>:<pass>@<endpoint>.neon.tech/...` |
| Branches | Ephemeral branches auto-created | Direct cloud connection |
| Reload | Hot-reload with nodemon | No reload, stable production |
| Logging | Info level | Warn level |
| User | root (dev convenience) | nodejs (non-root, secure) |
| Health Check | Basic connectivity | Full HTTP health check |

---

## Prerequisites

### Required

- **Docker Desktop** (includes Docker Engine + Docker Compose)
  - [Download Docker Desktop](https://www.docker.com/products/docker-desktop)
  - Verify installation: `docker --version` and `docker compose version`

- **Neon Account** (for production)
  - [Sign up for Neon](https://console.neon.tech/sign_up)

### For Development (Optional but Recommended)

- Neon API credentials to use Neon Local ephemeral branching
  - Get API Key: [Neon Console](https://console.neon.tech) → Account Settings → API Keys
  - Get Project ID: [Neon Console](https://console.neon.tech) → Project Settings

---

## Project Structure

```
acquisitions/
├── Dockerfile                    # Multi-stage build (development & production)
├── docker-compose.dev.yml        # Development stack: app + Neon Local
├── docker-compose.prod.yml       # Production stack: app + Neon Cloud
├── .env.development              # Local dev environment variables (git-ignored)
├── .env.development.example      # Template for .env.development (commit to git)
├── .env.production               # Local prod environment variables (git-ignored)
├── .env.production.example       # Template for .env.production (commit to git)
├── DOCKER_SETUP.md               # This file
├── src/
│   ├── app.js                    # Express app setup
│   ├── server.js                 # Server initialization
│   ├── configs/
│   │   └── db.js                 # Database connection (auto-detects Neon Local)
│   └── ...
├── drizzle.config.js             # Drizzle ORM configuration
├── package.json
└── index.js                      # Entry point
```

---

## Development Environment

### 🚀 Quick Start

#### 1. Create Development Environment File

```bash
cp .env.development.example .env.development
```

#### 2. Configure Neon API Credentials (Optional for Ephemeral Branches)

Edit `.env.development`:

```env
NEON_API_KEY=your_neon_api_key_here
NEON_PROJECT_ID=your_project_id_here
PARENT_BRANCH_ID=main              # or your branch ID
DELETE_BRANCH=true                 # auto-delete branch on container stop
```

**How to get these:**

- **NEON_API_KEY**: [Neon Console](https://console.neon.tech) → Account Settings → API keys
- **NEON_PROJECT_ID**: [Neon Console](https://console.neon.tech) → Project → Settings → ID

#### 3. Start Development Stack

```bash
docker compose --env-file .env.development -f docker-compose.dev.yml up --build
```

**Output:**
```
acquisitions-neon-local  | Neon local proxy is listening on 5432
acquisitions-app-dev     | Acquisitions service is running on http://localhost:3000
```

#### 4. Verify It's Working

In another terminal:

```bash
# Health check
curl http://localhost:3000/health

# Sample response
{"status":"ok","timestamp":"2025-05-08T12:34:56.789Z","uptime":5.234}
```

#### 5. Stop Development Stack

```bash
docker compose --env-file .env.development -f docker-compose.dev.yml down
```

To also remove Neon Local data:

```bash
docker compose --env-file .env.development -f docker-compose.dev.yml down -v
```

### 📝 Development Workflow

**Hot Reload**: Changes to files in `src/` automatically trigger nodemon reload. No need to restart the container.

**Logs**:
- View app logs: `docker compose -f docker-compose.dev.yml logs app`
- View Neon Local logs: `docker compose -f docker-compose.dev.yml logs neon-local`
- Follow logs: `docker compose -f docker-compose.dev.yml logs -f`

**Interactive Shell**:
```bash
docker compose -f docker-compose.dev.yml exec app sh
```

**Database Queries**:

From container:
```bash
docker compose -f docker-compose.dev.yml exec app npx drizzle-kit studio
```

From host (if PostgreSQL client installed):
```bash
psql postgres://neon:npg@localhost:5432/neondb
```

---

## Production Environment

### 🏭 Setup

#### 1. Get Neon Cloud Connection String

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project → Databases
3. Click on your database → Connection string
4. Copy the PostgreSQL connection string
5. **Important**: Keep it private; treat it like a password

Example format:
```
postgres://user:password@ep-abcd1234.us-east-1.neon.tech/dbname?sslmode=require
```

#### 2. Create Production Environment File

```bash
cp .env.production.example .env.production
```

#### 3. Add Neon Cloud URL to .env.production

Edit `.env.production` and update:

```env
DATABASE_URL=postgres://user:password@ep-abcd1234.us-east-1.neon.tech/dbname?sslmode=require
```

**⚠️ Security Note**: Never commit `.env.production` to git. Use environment secrets in your CI/CD pipeline:

```yaml
# Example: GitHub Actions
jobs:
  deploy:
    runs-on: ubuntu-latest
    env:
      DATABASE_URL: ${{ secrets.PROD_DATABASE_URL }}
```

#### 4. Build Production Image

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml build
```

#### 5. Run Production Stack

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml up -d
```

**Output:**
```
Creating acquisitions-app-prod ... done
```

#### 6. Verify Production Deployment

```bash
# Health check
curl http://localhost:3000/health

# Check running containers
docker compose -f docker-compose.prod.yml ps
```

#### 7. Stop Production Stack

```bash
docker compose --env-file .env.production -f docker-compose.prod.yml down
```

### 🔍 Production Monitoring

**View Logs**:
```bash
docker compose -f docker-compose.prod.yml logs -f app
```

**Check Container Status**:
```bash
docker compose -f docker-compose.prod.yml ps
```

**Inspect Running Container**:
```bash
docker inspect acquisitions-app-prod
```

**Container Stats**:
```bash
docker stats acquisitions-app-prod
```

---

## Common Commands

### Development

| Task | Command |
|------|---------|
| Start stack | `docker compose -f docker-compose.dev.yml up --build` |
| Stop stack | `docker compose -f docker-compose.dev.yml down` |
| View logs | `docker compose -f docker-compose.dev.yml logs -f` |
| Rebuild images | `docker compose -f docker-compose.dev.yml build --no-cache` |
| Shell into app | `docker compose -f docker-compose.dev.yml exec app sh` |
| Run migrations | `docker compose -f docker-compose.dev.yml exec app npm run db-migrate` |
| Generate schema | `docker compose -f docker-compose.dev.yml exec app npm run db-generate` |

### Production

| Task | Command |
|------|---------|
| Start stack | `docker compose -f docker-compose.prod.yml up -d` |
| Stop stack | `docker compose -f docker-compose.prod.yml down` |
| View logs | `docker compose -f docker-compose.prod.yml logs -f` |
| Rebuild images | `docker compose -f docker-compose.prod.yml build --no-cache` |
| Health check | `curl http://localhost:3000/health` |

### Image & Container Management

```bash
# List images
docker images | grep acquisitions

# List containers
docker ps -a | grep acquisitions

# Remove image
docker rmi acquisitions-api:latest

# Clean up unused resources
docker system prune -a
```

---

## Environment Variable Reference

### `.env.development`

| Variable | Purpose | Example |
|----------|---------|---------|
| `PORT` | App server port | `3000` |
| `NODE_ENV` | Environment mode | `development` |
| `LOG_LEVEL` | Winston logger level | `info` |
| `DATABASE_URL` | Neon Local connection | `postgres://neon:npg@neon-local:5432/neondb` |
| `NEON_LOCAL` | Enable Neon Local mode | `true` |
| `NEON_LOCAL_FETCH_ENDPOINT` | Neon Local HTTP endpoint | `http://neon-local:5432/sql` |
| `NEON_API_KEY` | For ephemeral branches | (get from Neon Console) |
| `NEON_PROJECT_ID` | For ephemeral branches | (get from Neon Console) |
| `PARENT_BRANCH_ID` | Branch to fork from | (empty = default branch) |
| `DELETE_BRANCH` | Auto-delete ephemeral branch | `true` |

### `.env.production`

| Variable | Purpose | Example |
|----------|---------|---------|
| `PORT` | App server port | `3000` |
| `NODE_ENV` | Environment mode | `production` |
| `LOG_LEVEL` | Winston logger level | `warn` |
| `DATABASE_URL` | Neon Cloud connection | `postgres://...neon.tech...` |
| `NEON_LOCAL` | Enable Neon Local mode | `false` |

---

## How Database Connection Works

### Development (Neon Local)

```
App Container
    ↓
DATABASE_URL: postgres://neon:npg@neon-local:5432/neondb
    ↓
Neon Local Container (HTTP → PostgreSQL proxy)
    ↓
In-memory PostgreSQL (ephemeral)
```

The app's `src/configs/db.js` detects `NEON_LOCAL=true` and configures the Neon serverless HTTP endpoint:

```javascript
if (useNeonLocal) {
  neonConfig.fetchEndpoint = 'http://neon-local:5432/sql';
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
}
```

### Production (Neon Cloud)

```
App Container
    ↓
DATABASE_URL: postgres://user:pass@*.neon.tech/dbname
    ↓
Internet
    ↓
Neon Cloud (managed PostgreSQL)
```

No Neon Local proxy; app connects directly to Neon Cloud endpoints.

---

## Dockerfile Explained

### Development Stage

```dockerfile
FROM node:20-alpine AS development
RUN npm install -g nodemon  # Auto-reload on file changes
RUN npm ci                  # Install all deps (including dev)
CMD ["nodemon", "index.js"] # Start with auto-reload
```

**Features:**
- Full dependency tree (dev + prod)
- Nodemon for hot-reload
- Source code volume mounts → live changes

### Production Stage

```dockerfile
FROM node:20-alpine AS production
RUN npm ci --only=production  # Only prod dependencies
RUN npm cache clean --force   # Minimize image size
RUN adduser -S nodejs         # Non-root user for security
USER nodejs                   # Run as non-root
ENTRYPOINT ["/sbin/dumb-init", "--"]  # Proper signal handling
HEALTHCHECK ...               # Container health monitoring
```

**Features:**
- Minimal image (prod deps only)
- Security: runs as non-root user
- Proper signal handling (SIGTERM for graceful shutdown)
- Health checks enabled

---

## Troubleshooting

### "Connection refused" when app starts

**Problem**: App can't reach Neon Local.

**Solution**:
1. Check Neon Local container is running: `docker compose -f docker-compose.dev.yml ps`
2. Check health: `docker compose -f docker-compose.dev.yml logs neon-local`
3. Wait 30-40 seconds for Neon Local to fully initialize
4. Restart: `docker compose -f docker-compose.dev.yml down && docker compose -f docker-compose.dev.yml up --build`

### "NEON_API_KEY is required" error

**Problem**: Missing Neon API credentials in `.env.development`.

**Solution**:
1. Get API Key: [Neon Console](https://console.neon.tech) → Account Settings → API Keys
2. Get Project ID: [Neon Console](https://console.neon.tech) → Project → Settings
3. Update `.env.development`:
   ```env
   NEON_API_KEY=your_key_here
   NEON_PROJECT_ID=your_id_here
   ```
4. Restart: `docker compose -f docker-compose.dev.yml down && docker compose -f docker-compose.dev.yml up --build`

### Port 3000 already in use

**Problem**: Another process is using port 3000.

**Solutions**:

Option 1: Kill existing process
```bash
lsof -ti:3000 | xargs kill -9
```

Option 2: Use different port
```bash
PORT=3001 docker compose --env-file .env.development -f docker-compose.dev.yml up
```

Option 3: Stop other Docker containers
```bash
docker ps
docker stop <container_id>
```

### "database does not exist" error

**Problem**: Neon Local created empty database.

**Solutions**:

1. Run migrations:
   ```bash
   docker compose -f docker-compose.dev.yml exec app npm run db-migrate
   ```

2. Or generate schema:
   ```bash
   docker compose -f docker-compose.dev.yml exec app npm run db-generate
   ```

### Production deployment fails

**Problem**: Invalid DATABASE_URL or connection timeout.

**Solutions**:

1. Verify URL format:
   ```bash
   cat .env.production | grep DATABASE_URL
   ```
   Should be: `postgres://user:password@*.neon.tech/dbname?sslmode=require`

2. Test connection from container:
   ```bash
   docker compose -f docker-compose.prod.yml exec app node -e \
     "console.log(process.env.DATABASE_URL)"
   ```

3. Check if Neon endpoint is reachable:
   ```bash
   docker compose -f docker-compose.prod.yml exec app curl -v \
     https://your-endpoint.neon.tech
   ```

4. Check logs for errors:
   ```bash
   docker compose -f docker-compose.prod.yml logs app
   ```

### High Docker image size

**Problem**: Development or production image is too large.

**Solution**:

```bash
# Create .dockerignore if not present
cat > .dockerignore << EOF
.git
.gitignore
node_modules
npm-debug.log
.env*
.DS_Store
coverage
dist
build
.vscode
.idea
EOF

# Rebuild without cache
docker compose -f docker-compose.dev.yml build --no-cache
```

### Docker Desktop performance issues

**Problem**: Slow builds or runtime on Mac/Windows.

**Solutions**:

1. Increase Docker Desktop resources:
   - Docker Desktop → Settings → Resources
   - Increase CPU and Memory sliders
   - Apply & Restart

2. Use BuildKit for faster builds:
   ```bash
   DOCKER_BUILDKIT=1 docker compose -f docker-compose.dev.yml build
   ```

3. Check volume mount performance:
   - On Mac: Consider using named volumes instead of bind mounts
   - Reference: [Docker Desktop Mac performance](https://docs.docker.com/desktop/mac/troubleshoot/)

---

## Best Practices

### Development

- ✅ Use `.env.development` for local secrets
- ✅ Keep source code volumes mounted for hot-reload
- ✅ Use `docker compose logs -f` to monitor real-time activity
- ✅ Commit only `.env.development.example` to git
- ❌ Don't use production database URLs in development

### Production

- ✅ Use environment secrets in CI/CD (GitHub Actions, GitLab CI, etc.)
- ✅ Never commit `.env.production` to git
- ✅ Use non-root user for container security
- ✅ Enable health checks for orchestration (Kubernetes, Docker Swarm)
- ✅ Set `LOG_LEVEL=warn` to reduce noise
- ❌ Don't expose sensitive data in container logs
- ❌ Don't use `docker run` with `--privileged` flag

### General

- ✅ Use `.dockerignore` to exclude unnecessary files
- ✅ Use multi-stage builds to minimize image size
- ✅ Pin Node.js version (e.g., `node:20-alpine`)
- ✅ Use named volumes for persistent data
- ✅ Run containers with read-only root filesystem when possible
- ❌ Don't run as root in production

---

## Next Steps

1. **Database Migrations**: Set up Drizzle ORM migrations for your schema
   ```bash
   docker compose -f docker-compose.dev.yml exec app npm run db-generate
   ```

2. **CI/CD Integration**: Add Docker builds to your GitHub Actions/GitLab CI
   - Reference: [GitHub Actions Docker guide](https://docs.github.com/en/actions/guides/building-and-testing-nodejs)

3. **Container Orchestration**: Deploy to production with Docker Swarm or Kubernetes
   - Reference: [Docker Swarm docs](https://docs.docker.com/engine/swarm/)
   - Reference: [Kubernetes docs](https://kubernetes.io/docs/)

4. **Monitoring**: Add logging and metrics collection
   - Option 1: ELK Stack (Elasticsearch, Logstash, Kibana)
   - Option 2: Grafana + Prometheus
   - Option 3: Cloud providers (AWS CloudWatch, GCP Cloud Logging, Azure Monitor)

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Neon Documentation](https://neon.tech/docs)
- [Neon Local Guide](https://neon.tech/docs/local/neon-local)
- [Node.js Best Practices](https://nodejs.org/en/docs/guides/nodejs-docker-webapp/)

---

**Last Updated**: May 8, 2025
**Maintainer**: DevOps Team
