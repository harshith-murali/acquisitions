# CI/CD Workflows Quick Start Guide

## What Just Happened?

Three powerful GitHub Actions workflows have been added to your repository:

## 📋 Workflow Checklist

### ✅ Lint and Format (`lint-and-format.yml`)
When code is pushed or a PR is created:
- ESLint checks code quality
- Prettier checks formatting
- PR gets comments with fix commands if issues found
- Workflow fails if issues aren't fixed

**What to do if it fails:**
```bash
npm run lint:fix      # Fix ESLint issues
npm run format        # Fix formatting issues
```

### ✅ Tests (`tests.yml`)
When code is pushed or a PR is created:
- Runs 14 comprehensive test cases
- Sets up PostgreSQL for database tests
- Generates coverage reports
- Shows coverage metrics in GitHub Step Summary
- Uploads coverage as artifact (30 days retention)

**What to expect:**
- ✅ All 14 tests pass
- 📊 Coverage report shows percentages for statements, branches, functions, lines

### ✅ Docker Build and Push (`docker-build-and-push.yml`)
When code is pushed, PR created, or version tag is pushed:
- Builds production image for `main` branch
- Builds development image for `staging` branch
- Automatically tags images (branch, version, SHA, latest)
- Pushes to GitHub Container Registry (GHCR)
- Scans code for security vulnerabilities with Trivy
- Reports vulnerabilities on PRs
- Creates build summary in GitHub Step Summary

**Image locations:**
```
ghcr.io/harshith-murali/acquisitions:latest
ghcr.io/harshith-murali/acquisitions:main
ghcr.io/harshith-murali/acquisitions:staging
ghcr.io/harshith-murali/acquisitions:v1.0.0  (on tag push)
```

---

## 🚀 Triggering the Workflows

### Automatically (No action needed)
- Every push to `main` → All 3 workflows run
- Every push to `staging` → All 3 workflows run
- Every PR to `main/staging` → All 3 workflows run
- Every tag push `v*` → Docker build and push runs

### Manually (Optional)
To re-run a workflow:
1. Go to **Actions** tab in GitHub
2. Select the workflow name
3. Click **Run workflow**

---

## 📊 Monitoring Workflows

### View Workflow Results
1. Go to your repository
2. Click **Actions** tab
3. See all workflow runs listed by branch/PR

### View Artifacts
1. Click on a completed workflow run
2. Scroll to **Artifacts** section
3. Download coverage reports

### GitHub Step Summary
Each workflow provides a summary showing:
- Lint and Format: Issues found (if any)
- Tests: Coverage percentages and test status
- Docker: Build information and image tags

---

## 🔧 Local Development

### Before pushing, run locally:

```bash
# Check linting
npm run lint

# Check formatting
npm run format:check

# Run tests
npm test

# Build Docker image locally
docker build -t acquisitions:dev --target development .
docker build -t acquisitions:prod --target production .
```

---

## ⚠️ Workflow Status Indicators

### Green ✅
- All checks passed
- Code is quality-checked
- Tests passed with coverage
- Docker image built successfully
- No security vulnerabilities

### Yellow ⚠️
- Workflow in progress
- Check back shortly

### Red ❌
- Linting/formatting issues → Run suggested npm commands
- Test failures → Check test output in Actions
- Docker build failed → Check build logs
- Security vulnerabilities → Review and fix

---

## 📝 Common Issues and Fixes

| Issue | Solution |
|-------|----------|
| ESLint fails | Run `npm run lint:fix` |
| Prettier fails | Run `npm run format` |
| Tests fail | Check GitHub Actions logs for error details |
| Docker build fails | Verify Dockerfile syntax and dependencies |
| Security scan failures | Review vulnerability details in PR comment |

---

## 🔐 Security Features

- **Trivy Scanning**: Filesystem vulnerabilities automatically detected
- **SARIF Upload**: Vulnerability data sent to GitHub Security tab
- **PR Comments**: Detailed breakdown of vulnerabilities by severity
- **Non-root Container**: Production images run as non-root user
- **Health Checks**: Containers have health monitoring

---

## 📚 Documentation

For detailed information, see:
- `CI_CD_WORKFLOWS.md` - Complete workflow documentation
- `.github/workflows/` - Workflow YAML files with inline comments

---

## 🎯 Next Steps

1. **Make a test commit** to see workflows in action
2. **Check Actions tab** to monitor workflow execution
3. **Review GitHub Step Summary** for detailed results
4. **Download coverage report** from artifacts if needed

**Example:**
```bash
git add .
git commit -m "test: verify CI/CD workflows"
git push origin main
# Then check Actions tab!
```

---

## Questions?

All workflows include:
- Clear step names
- Automatic error annotations
- GitHub Step Summary reporting
- PR comments with guidance

Check the **Actions** tab for detailed logs of any workflow run.
