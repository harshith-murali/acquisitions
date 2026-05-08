# 🚀 Acquisitions API: Docker + Neon Database

A fully containerized Node.js + Express API with PostgreSQL via Neon Database, supporting both local development (Neon Local) and cloud production (Neon Cloud).

## ⚡ Quick Start (2 Minutes)

### Option 1: Automated Setup (Easiest)

```bash
./setup-docker.sh dev     # Interactive setup + start development
```

### Option 2: Manual Commands

```bash
# Development
cp .env.development.example .env.development
make dev-start

# OR
docker compose -f docker-compose.dev.yml --env-file .env.development up --build
```

Then test it:
```bash
curl http://localhost:3000/health
```

## 📦 What's Included

### Docker Setup
- ✅ **Multi-stage Dockerfile** - Optimized for both development and production
- ✅ **docker-compose.dev.yml** - Development with Neon Local + hot-reload
- ✅ **docker-compose.prod.yml** - Production with Neon Cloud + health checks
- ✅ **Automated setup script** - One-command setup (setup-docker.sh)

### Configuration
- ✅ **Environment templates** - .env.development.example and .env.production.example
- ✅ **Git-ignored secrets** - .env.development and .env.production never committed
- ✅ **Easy switching** - Same codebase, different configs for dev/prod

### Documentation
- ✅ **DOCKER_SETUP.md** - Complete 5,500+ word guide
- ✅ **QUICK_START.md** - 5-minute quick reference
- ✅ **Makefile** - 30+ helpful commands
- ✅ **shell scripts** - automation helpers

## 🎯 Two Environments in One

| Aspect | Development | Production |
|--------|-------------|-----------|
| **Database** | Neon Local (Docker) | Neon Cloud |
| **Connection** | `postgres://neon:npg@neon-local:5432/neondb` | `postgres://...neon.tech...` |
| **Auto Reload** | Yes (nodemon) | No |
| **Container Count** | 2 (app + Neon Local) | 1 (app only) |
| **Health Checks** | Basic | Full HTTP |
| **Security** | root user (dev) | non-root nodejs user |
| **Logs** | Live output | Rotated JSON files |

## 🚀 Getting Started

### Development (with Neon Local)

```bash
# 1. Setup (one-time)
./setup-docker.sh dev

# 2. Start
make dev-start
# or: docker compose -f docker-compose.dev.yml up --build

# 3. Test
curl http://localhost:3000/health

# 4. Stop
make dev-stop
```

**Available commands:**
```bash
make dev-logs        # View real-time logs
make dev-shell       # Open container shell
make db-migrate      # Run migrations
make db-generate     # Generate schema
make db-studio       # Open Drizzle Studio
make lint            # Run ESLint
make format          # Format code
```

### Production (with Neon Cloud)

```bash
# 1. Get Neon Cloud URL from https://console.neon.tech

# 2. Setup (one-time)
./setup-docker.sh prod

# 3. Start
make prod-start

# 4. Test
curl http://localhost:3000/health

# 5. Stop
make prod-stop
```

## 📁 Files Overview

```
acquisitions/
├── 🐳 Docker
│   ├── Dockerfile                      # Multi-stage: dev + prod
│   ├── docker-compose.dev.yml          # Dev: app + Neon Local
│   ├── docker-compose.prod.yml         # Prod: app only
│   └── .dockerignore                   # Build context filter
│
├── ⚙️  Configuration
│   ├── .env.development                # Dev secrets (git-ignored)
│   ├── .env.development.example        # Dev template
│   ├── .env.production                 # Prod secrets (git-ignored)
│   └── .env.production.example         # Prod template
│
├── 🔧 Automation
│   ├── setup-docker.sh                 # One-command setup
│   ├── docker-dev.sh                   # Dev helper
│   └── Makefile                        # 30+ commands
│
├── 📚 Documentation
│   ├── DOCKER_SETUP.md                 # Complete guide
│   ├── QUICK_START.md                  # Quick reference
│   ├── DOCKER_IMPLEMENTATION_SUMMARY.md # Summary
│   └── README.md                       # This file
│
└── 🚀 Application
    ├── package.json
    ├── index.js
    ├── src/
    │   ├── app.js
    │   ├── server.js
    │   ├── configs/db.js               # Auto-detects Neon Local
    │   └── ...
    └── ...
```

## 🎓 Documentation Guide

- **Getting started right now?** → Read [QUICK_START.md](QUICK_START.md)
- **Want complete details?** → Read [DOCKER_SETUP.md](DOCKER_SETUP.md)
- **Looking for all commands?** → Run `make help`
- **Quick reference?** → Check this README

## 💡 Key Commands

### Setup & Start
```bash
./setup-docker.sh              # Interactive setup wizard
./setup-docker.sh dev          # Setup development
./setup-docker.sh prod         # Setup production
./setup-docker.sh all          # Setup both
make dev-start                 # Start development
make prod-start                # Start production
```

### Development Workflow
```bash
make dev-logs                  # View logs
make dev-shell                 # Shell into container
make db-migrate                # Run migrations
make db-generate               # Generate schema
make db-studio                 # Drizzle Studio
make lint                      # Run ESLint
make format                    # Format code
```

### Management
```bash
make status                    # Show container status
make health-check              # Check API health
make docker-ps                 # List containers
make docker-images             # List images
make clean                     # Clean up everything
```

## 🔧 How It Works

### Development Flow
```
Your Code (src/)
    ↓ (volume mount)
App Container (nodemon)
    ↓ (hot-reload on change)
  Restarts automatically
    ↓
DATABASE_URL: postgres://neon:npg@neon-local:5432/neondb
    ↓
Neon Local Container (HTTP ↔ PostgreSQL)
    ↓
In-Memory PostgreSQL DB
```

### Production Flow
```
Docker Image
    ↓
App Container (node index.js)
    ↓
DATABASE_URL: postgres://...neon.tech...
    ↓
Internet
    ↓
Neon Cloud (managed PostgreSQL)
```

## ✨ Features

### Developer Experience
- 🔥 Hot-reload with nodemon
- 📝 Real-time logs
- 🐚 Easy container shell access
- 📊 Database studio access
- 🏗️ Automated migrations

### Production Ready
- 🔒 Non-root user
- 🏥 Health checks
- 📊 Structured logging
- 🚀 Optimized images
- 🔄 Auto-restart on failure

### Team Friendly
- 📚 Complete documentation
- 🛠️ One-command setup
- 📋 Template files
- 🤖 Makefile helpers
- 🐳 Same setup for everyone

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| Connection refused | Wait 30-40s, check `make status` |
| Port already in use | `lsof -ti:3000 \| xargs kill -9` or `PORT=3001 make dev-start` |
| Missing .env file | `cp .env.development.example .env.development` |
| Database doesn't exist | `make db-migrate` |
| Docker not found | [Install Docker Desktop](https://www.docker.com/products/docker-desktop) |

See [DOCKER_SETUP.md#troubleshooting](DOCKER_SETUP.md#troubleshooting) for more solutions.

## 📖 Learn More

- [Full Docker Setup Guide](DOCKER_SETUP.md) - 5,500+ words, every detail
- [Quick Start Guide](QUICK_START.md) - 5-minute setup
- [Implementation Summary](DOCKER_IMPLEMENTATION_SUMMARY.md) - What was built
- [Neon Documentation](https://neon.tech/docs)
- [Neon Local Guide](https://neon.tech/docs/local/neon-local)
- [Docker Docs](https://docs.docker.com/)

## 🚀 Next Steps

1. **Run automated setup**: `./setup-docker.sh`
2. **Start development**: `make dev-start`
3. **Run migrations**: `make db-migrate`
4. **Deploy to production**: Follow [DOCKER_SETUP.md#production](DOCKER_SETUP.md#production)

## 💬 Support

- **Questions?** Check [DOCKER_SETUP.md](DOCKER_SETUP.md)
- **Commands?** Run `make help`
- **Neon help?** Visit [Neon Community](https://community.neon.tech)
- **Docker help?** Visit [Docker Community](https://www.docker.com/community)

---

**Built for DevOps** | **Tested with Docker v29.4+** | **Neon-Ready**
