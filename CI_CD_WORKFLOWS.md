# GitHub Actions CI/CD Workflows

This document describes the three GitHub Actions workflows configured for the Acquisitions API project.

## 1. Lint and Format Workflow (`lint-and-format.yml`)

**Triggered on:** Pushes and pull requests to `main` and `staging` branches

### What it does:
- Validates code quality using ESLint
- Checks code formatting compliance with Prettier
- Provides clear annotations and suggestions for fixes
- Comments on PRs with actionable fix commands

### Key features:
- **Node.js**: Version 20.x with npm cache enabled
- **Dependency Installation**: Uses `npm ci` for reproducible installs
- **Linting**: Runs `npm run lint` with ESLint validation
- **Formatting Check**: Runs `npm run format:check` with Prettier validation
- **PR Comments**: Automatically suggests `npm run lint:fix` and `npm run format` when issues are found
- **Failure Handling**: Fails the workflow if any linting or formatting issues are detected

### Suggested Fix Commands (shown in PR comments):
```bash
# Fix ESLint issues
npm run lint:fix

# Fix formatting issues
npm run format
```

---

## 2. Tests Workflow (`tests.yml`)

**Triggered on:** Pushes and pull requests to `main` and `staging` branches

### What it does:
- Runs the comprehensive Jest test suite
- Sets up PostgreSQL service for database testing
- Generates and uploads coverage reports
- Creates GitHub Step Summary with test results
- Captures and reports test failures with annotations

### Key features:
- **Node.js**: Version 20.x with npm cache enabled
- **Test Environment Setup**:
  - `NODE_ENV=test`
  - `NODE_OPTIONS=--experimental-vm-modules` (for ESM support)
  - PostgreSQL service (version 16-alpine) on port 5432
  - Automatic health checks for database readiness
- **Coverage Reports**:
  - Automatically uploaded as artifacts
  - 30-day retention policy
  - Stored in `coverage/` directory
- **GitHub Step Summary**: Displays coverage percentages for:
  - Statements
  - Branches
  - Functions
  - Lines
- **Test Summary Table**: Creates a markdown table with coverage metrics

### Environment Variables:
```bash
NODE_ENV=test
NODE_OPTIONS=--experimental-vm-modules
DATABASE_URL=postgresql://test:test@localhost:5432/test_db
```

### Output:
- Coverage reports as GitHub artifacts
- GitHub Step Summary with test results
- Test failure annotations (if any)

---

## 3. Docker Build and Push Workflow (`docker-build-and-push.yml`)

**Triggered on:**
- Pushes to `main` and `staging` branches
- Pull requests to `main` and `staging` branches
- Tag pushes matching `v*` pattern (releases)

### What it does:
- Builds Docker images for development and production stages
- Pushes images to GitHub Container Registry (GHCR)
- Scans images for security vulnerabilities
- Generates detailed build summaries
- Runs Trivy security scanner on filesystem

### Key features:

#### Docker Build:
- **Buildx Setup**: Uses Docker Buildx for multi-architecture builds
- **Registry**: GitHub Container Registry (`ghcr.io`)
- **Image Target Selection**:
  - `production` stage for `main` branch
  - `development` stage for other branches
- **Tagging Strategy**:
  - Branch-based tags (e.g., `main`, `staging`)
  - Semantic versioning tags (e.g., `v1.0.0`)
  - SHA-based tags for traceability
  - `latest` tag for default branch (main)
- **Build Caching**: Uses GitHub Actions cache for faster builds
- **Push Behavior**:
  - Pushes to registry on `main` and `staging` branches
  - Validates build on PRs without pushing

#### Security Scanning:
- **Trivy Scanner**: Filesystem vulnerability scanning
- **Findings**: Categorized by severity (CRITICAL, HIGH, MEDIUM, LOW)
- **SARIF Upload**: Results uploaded for GitHub Security tab
- **PR Comments**: Detailed vulnerability reports on pull requests

#### Build Summary:
- Reference information (commit SHA, branch)
- Target stage (production/development)
- Registry and image name
- Push status confirmation

### Permissions Required:
- `contents: read` - For checking out code
- `packages: write` - For pushing to container registry

### Authentication:
Uses `GITHUB_TOKEN` for container registry login (automatically provided by GitHub Actions)

### Image Naming Convention:
```
ghcr.io/harshith-murali/acquisitions:latest
ghcr.io/harshith-murali/acquisitions:main
ghcr.io/harshith-murali/acquisitions:v1.0.0
ghcr.io/harshith-murali/acquisitions:main-<sha>
```

---

## Workflow Execution Summary

### On Each Push to Main/Staging:
1. ✅ Code is linted and formatted
2. ✅ Tests run against PostgreSQL database
3. ✅ Coverage reports are generated
4. ✅ Docker image is built and pushed to registry
5. ✅ Security vulnerabilities are scanned

### On Pull Requests:
1. ✅ Code quality checks (ESLint, Prettier)
2. ✅ Tests execute with coverage analysis
3. ✅ Docker image build is validated (not pushed)
4. ✅ Security scan results are reported

### On Release Tags (v*):
1. ✅ Production Docker image is built
2. ✅ Image is tagged with semantic version
3. ✅ Image is pushed to registry as a release

---

## Troubleshooting

### Lint/Format Failures:
- Check PR comments for specific issues
- Run `npm run lint:fix` locally to auto-fix ESLint issues
- Run `npm run format` locally to auto-fix formatting issues

### Test Failures:
- Check GitHub Step Summary for failed test details
- Download coverage report artifact from Actions
- Ensure PostgreSQL service is healthy
- Verify `DATABASE_URL` environment variable is set correctly

### Docker Build Failures:
- Check build logs in GitHub Actions
- Verify Dockerfile syntax is valid
- Ensure all required files are present
- Check for dependency installation issues

### Security Scan Issues:
- Review Trivy scan results in the PR comment
- Check GitHub Security tab for detailed vulnerability information
- Address CRITICAL and HIGH severity vulnerabilities before merging

---

## Configuration Files Reference

- **ESLint**: `.eslintrc.js` or `.eslintrc.json`
- **Prettier**: `.prettierrc` (includes formatting rules)
- **Jest**: `jest.config.mjs` (test configuration)
- **Docker**: `Dockerfile` (multi-stage build configuration)
- **Package.json**: Scripts for lint, format, test, and build commands
