# 🚀 Quick Start Guide: Docker Setup

Get your Acquisitions API running locally with Neon Database in **5 minutes**.

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed
- Neon account (optional for development, required for production)

## Development: Start in 3 Steps

### Step 1: Create Environment File

```bash
cp .env.development.example .env.development
```

### Step 2: Update Neon Credentials (Optional)

Edit `.env.development` and add (optional, but enables ephemeral branches):

```env
NEON_API_KEY=your_api_key_from_neon_console
NEON_PROJECT_ID=your_project_id_from_neon_console
```

Get these from: [Neon Console](https://console.neon.tech) → Account Settings → API Keys

### Step 3: Start Development Stack

**Option A: Using Make (Recommended)**

```bash
make dev-start
```

**Option B: Using Docker Compose Directly**

```bash
docker compose --env-file .env.development -f docker-compose.dev.yml up --build
```

**Option C: Using Shell Script**

```bash
./docker-dev.sh start
```

### ✅ Success!

Your API is running at: **http://localhost:3000**

Test it:

```bash
curl http://localhost:3000/health

# Expected response:
# {"status":"ok","timestamp":"2025-05-08T12:34:56.789Z","uptime":5.234}
```

## Common Development Commands

```bash
# View logs
make dev-logs

# Open shell in app container
make dev-shell

# Run database migrations
make db-migrate

# Generate database schema
make db-generate

# Stop development environment
make dev-stop
```

## Production: Deploy in 3 Steps

### Step 1: Get Neon Cloud URL

1. Go to [Neon Console](https://console.neon.tech)
2. Select your project → Connection string
3. Copy PostgreSQL connection string

### Step 2: Create Production Environment File

```bash
cp .env.production.example .env.production
```

### Step 3: Add Your Database URL

Edit `.env.production`:

```env
DATABASE_URL=postgres://user:password@ep-abcd1234.neon.tech/dbname?sslmode=require
```

### Step 4: Start Production Stack

```bash
make prod-start
```

Your production API is running at: **http://localhost:3000**

## Key Commands

### 🐳 Docker

```bash
make docker-images       # List Docker images
make docker-ps          # List containers
make docker-clean       # Clean up resources
```

### 📊 Database

```bash
make db-migrate         # Run migrations
make db-generate        # Generate schema
make db-studio          # Open Drizzle Studio
```

### 📝 Code Quality

```bash
make lint               # Run ESLint
make lint-fix           # Fix linting issues
make format             # Format code
```

### 🔍 Health & Status

```bash
make health-check       # Check API health
make status            # Show container status
make env-check         # Check environment files
```

### 📚 Documentation

```bash
make help              # Show all commands
make docs              # Read full Docker setup guide
make info              # Show project info
```

## Troubleshooting

### Connection refused?

```bash
# Wait 30-40 seconds for Neon Local to start, then check:
make status
make dev-logs
```

### Port 3000 already in use?

```bash
# Use a different port:
PORT=3001 make dev-start

# Or kill the process:
lsof -ti:3000 | xargs kill -9
```

### Can't find .env.development?

```bash
# Create it from the template:
cp .env.development.example .env.development
```

### Database doesn't exist?

```bash
# Run migrations:
make db-migrate
```

## File Structure

```
acquisitions/
├── Dockerfile                    # Multi-stage build
├── docker-compose.dev.yml        # Development (app + Neon Local)
├── docker-compose.prod.yml       # Production (app only)
├── .env.development              # Dev config (git-ignored)
├── .env.production               # Prod config (git-ignored)
├── .env.development.example      # Dev template
├── .env.production.example       # Prod template
├── DOCKER_SETUP.md               # Full documentation
├── QUICK_START.md                # This file
├── Makefile                      # Command shortcuts
├── docker-dev.sh                 # Development helper script
└── src/                          # Application code
```

## Environment Variables

### Development (`.env.development`)

| Variable | Value | Note |
|----------|-------|------|
| `PORT` | `3000` | App port |
| `NODE_ENV` | `development` | Dev mode |
| `DATABASE_URL` | `postgres://neon:npg@neon-local:5432/neondb` | Neon Local |
| `NEON_LOCAL` | `true` | Enable Neon Local |

### Production (`.env.production`)

| Variable | Value | Note |
|----------|-------|------|
| `PORT` | `3000` | App port |
| `NODE_ENV` | `production` | Prod mode |
| `DATABASE_URL` | `postgres://...neon.tech...` | Neon Cloud |
| `NEON_LOCAL` | `false` | Disable Neon Local |

## What's Happening Behind the Scenes?

### Development

```
You run: make dev-start
    ↓
Docker starts 2 containers:
  1. Neon Local (PostgreSQL proxy with ephemeral branch support)
  2. App (Node.js + Express + nodemon for hot-reload)
    ↓
App connects to postgres://neon:npg@neon-local:5432/neondb
    ↓
Neon Local converts HTTP requests to PostgreSQL queries
    ↓
You can make changes to src/ and see them instantly (hot-reload)
```

### Production

```
You run: make prod-start
    ↓
Docker starts 1 container:
  1. App (Node.js + Express, optimized for production)
    ↓
App connects directly to your Neon Cloud database
    ↓
No Neon Local proxy needed
    ↓
Health checks monitor container status
```

## Next Steps

1. **Read Full Docs**: `make docs` (or see `DOCKER_SETUP.md`)
2. **Set Up Database**: `make db-migrate`
3. **View Logs**: `make dev-logs`
4. **Deploy to Production**: Follow Production section above

## Need Help?

- 📖 **Full Documentation**: `DOCKER_SETUP.md`
- 🐛 **Debugging**: `make help` (see all available commands)
- 🔗 **Neon Docs**: https://neon.tech/docs
- 🐳 **Docker Docs**: https://docs.docker.com

---

**Last Updated**: May 8, 2025
