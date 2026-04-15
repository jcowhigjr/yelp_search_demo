# Workflow Monitoring and Deployment Guide

This guide provides an overview of the deployment process and how to monitor the application to ensure it's running smoothly.

## Deployment Process

Deployments are automated through the CI/CD pipeline configured in `.github/workflows/main.yml`. A new deployment is triggered automatically on every push to the `develop` branch.

The deployment process includes the following steps:

1.  **Run Tests:** The CI pipeline runs a comprehensive suite of tests, including unit, integration, and system tests, to ensure code quality.
2.  **Build Application:** The application is built and prepared for deployment.
3.  **Deploy to Heroku:** The application is deployed to Heroku.
4.  **Verify Deployment:** After deployment, the CI pipeline verifies the deployment by checking the health endpoint (`/healthz`).

## Monitoring

### Health Check Endpoint

The application has a health check endpoint at `/healthz`. This endpoint checks the database connectivity and returns a `200 OK` status if the application is healthy.

You can use an uptime monitoring service like Uptime Robot to periodically ping this endpoint and receive alerts if the application becomes unhealthy.

#### Manual Health Check Commands

```bash
# Check if the application is responding
curl -s -o /dev/null -w "%{http_code}" https://dorkbob.herokuapp.com/healthz

# Get full health check response
curl https://dorkbob.herokuapp.com/healthz
```

#### Setting Up Automated Monitoring

1. **Uptime Robot Setup:**
   - Create a new monitor with URL: `https://dorkbob.herokuapp.com/healthz`
   - Set interval to 5 minutes
   - Configure alerts for email/SMS notifications
   - Expected response: 200 OK with "OK" in the body

### Application Performance Monitoring (APM)

For more detailed monitoring, we recommend using an APM tool like Datadog or New Relic. These tools provide in-depth insights into:

*   **Application Performance:** Track response times, throughput, and other performance metrics.
*   **Error Tracking:** Get notified of errors and exceptions in real-time.
*   **Resource Utilization:** Monitor CPU, memory, and other resource usage.

## Workflow Process Documentation

### Development Workflow

This project follows the workflow documented in `docs/agent-coder-workflow.md` and enforced by lefthook hooks:

1. **Feature Development:** Sync with `./scripts/git-sync.sh`, then create feature branches with `git switch -c <branch-name>`
2. **Code Quality:** Pre-commit hooks run automated checks (tests, linting, security scans)
3. **Pre-push Validation:** Comprehensive test suite runs before code is pushed
4. **Pull Request:** Automated review and CI/CD pipeline validation
5. **Deployment:** Automatic deployment to Heroku on merge to `develop` branch

### CI/CD Pipeline Details

The pipeline includes the following key features:

- **Intelligent Test Execution:** Uses risk assessment for Dependabot PRs (see `docs/intelligent-ci-cd.md`)
- **Parallel Testing:** Runs current and next-generation tests in parallel
- **Security Scanning:** Automated security checks with Brakeman
- **Deployment Verification:** Health check validation post-deployment

### Monitoring Commands

#### Using the Monitoring Script

A comprehensive monitoring script is available at `bin/monitor-deployment.sh`:

```bash
# Check application health once
./bin/monitor-deployment.sh health

# Check deployment status (git status, branch info)
./bin/monitor-deployment.sh status

# Check recent CI/CD workflow runs
./bin/monitor-deployment.sh workflows

# Start continuous monitoring (every 30 seconds)
./bin/monitor-deployment.sh monitor

# Show help and configuration options
./bin/monitor-deployment.sh help
```

#### Manual Monitoring Commands

```bash
# View recent git commits (deployments)
mise exec -- git log --oneline -10

# Check current deployment status
mise exec -- git status

# View workflow runs (requires GitHub CLI)
gh run list --repo jcowhigjr/yelp_search_demo --limit 10
```

#### Monitor Application Health

```bash
# Continuous health monitoring (run in terminal)
watch -n 30 'curl -s -w "Status: %{http_code}, Time: %{time_total}s\n" https://dorkbob.herokuapp.com/healthz'

# Check Heroku application status
heroku ps --app dorkbob

# View recent Heroku logs
heroku logs --tail --app dorkbob
```

#### Verify Workflow Compliance

```bash
# Check lefthook configuration
./scripts/git-sync.sh

# Verify environment setup
bin/container-healthcheck.sh

# Run local test suite to ensure consistency
mise exec -- bin/rails test
```

## Troubleshooting

### Deployment Failures

If a deployment fails, check the following:

1.  **CI/CD Logs:** Review the logs in the GitHub Actions workflow for any error messages
2.  **Heroku Logs:** Check the Heroku logs for any application errors during startup
3.  **Local Environment:** Try to reproduce the issue in your local development environment
4.  **Health Endpoint:** Verify the `/healthz` endpoint is responding locally

```bash
# Debug deployment locally
mise exec -- bin/rails server
curl http://localhost:3000/healthz
```

### Monitoring Alerts

If you receive a monitoring alert, take the following steps:

1.  **Check the Health Endpoint:** Manually access the `/healthz` endpoint to see if it's returning an error
2.  **Review Application Logs:** Check the application logs for any errors or unusual activity
3.  **Inspect APM Data:** If you're using an APM tool, review the data to identify the source of the issue
4.  **Verify Database Connectivity:** The health check includes database validation

### Common Issues and Solutions

#### Health Check Returning 503

```bash
# Check database connectivity
mise exec -- bin/rails console
# In console: ActiveRecord::Base.connection.execute('SELECT 1')
```

#### Slow Response Times

```bash
# Check for database locks or slow queries
heroku logs --app dorkbob | grep -i slow

# Monitor resource usage
heroku ps:scale --app dorkbob
```

#### CI/CD Pipeline Failures

```bash
# Check workflow status
gh run list --repo jcowhigjr/yelp_search_demo --status failure

# View specific workflow run details
gh run view <run-id>
```
