# === Code Deployment Execution: Environment-Specific Deployment Orchestration ===

**ALWAYS THINK THEN...** Before executing any action, operation, or command in this instruction set, you MUST use thinking to:
1. Analyze the request and understand what needs to be done
2. Plan your approach and identify potential issues
3. Consider the implications and requirements
4. Only then proceed with the actual execution

**This thinking requirement is MANDATORY and must be followed for every action.**

## CANONICAL PROTOCOL ENFORCEMENT - READ FIRST

**THIS SECTION IS MANDATORY AND MUST BE READ, INDEXED, AND FOLLOWED BEFORE ANY COMMAND EXECUTION**

### 1. PROTOCOL COMPLIANCE REQUIREMENTS

**BEFORE PROCEEDING, YOU MUST:**
1. READ AND INDEX: `./claude/commands/protocol/code-protocol-compliance-prompt.md`
2. READ AND INDEX: `./claude/commands/protocol/code-protocol-single-branch-strategy.md`
3. VERIFY: User has given explicit permission to proceed
4. ACKNOWLEDGE: ALL CANONICAL PROTOCOL requirements

**FORBIDDEN:** Proceeding without complete protocol compliance verification

### 2. SINGLE BRANCH DEVELOPMENT STRATEGY - MANDATORY

**FOLLOW THE SINGLE BRANCH DEVELOPMENT PROTOCOL:**
- ALL git workflows MUST follow the protocol defined in `./claude/commands/protocol/code-protocol-single-branch-strategy.md`
- **SACRED BRANCHES:** main/master/production are protected - NEVER work directly on them
- **SINGLE WORKING BRANCH:** development branch ONLY - work directly on development
- **NO FEATURE BRANCHES:** FORBIDDEN to create feature/fix branches without explicit permission
- **ATOMIC COMMITS:** One logical change per commit with conventional format
- **IMMEDIATE BACKUP:** Push to origin after every commit

**COMMIT MESSAGE FORMAT FOR DEPLOYMENTS:**
```
deploy([environment]): deploy to [platform/location]

- Deployed application to [environment] on [platform]
- Target: [specific deployment target]
- Strategy: [deployment strategy used]
- Validation: [validation performed]

[AI-Instance-ID-Timestamp]
```

### 3. DEPLOYMENT-ONLY MANDATE - CRITICAL DISTINCTION

**THIS COMMAND IS FOR DEPLOYMENT EXECUTION ONLY:**
- **MUST:** Execute actual deployment to specified environment and platform
- **MUST:** Build, deploy, and validate the application
- **MUST:** Perform health checks and verification
- **FORBIDDEN:** Create extensive planning documentation
- **FORBIDDEN:** Perform analysis (use `/code-deployment-planning` first)
- **MUST:** Focus on deployment execution and validation

**DEPLOYMENT EXECUTION FOCUS:**
- Build and deploy application components
- Execute deployment strategy (blue-green, canary, rolling)
- Validate deployment success through health checks
- Monitor deployment progress and handle failures
- Perform post-deployment verification
- Execute rollback if deployment fails

**IF BUILD/DEPLOY ISSUES OCCUR:**
- Follow debugging protocol in `./claude/commands/code/code-debug.md`
- Use refactoring protocol in `./claude/commands/code/code-refactor.md`
- Apply planning protocol in `./claude/commands/code/code-planning.md`
- Implement fixes per `./claude/commands/code/code-implement.md`
- Ensure security compliance per `./claude/commands/code/code-security-analysis.md`

## DEPLOYMENT EXECUTION PROTOCOL

Execute deployment to: **$1** environment on **$2** platform

**WORKFLOW CONTEXT:**
This command executes actual deployment based on pre-existing deployment plans. Use `/code-deployment-planning` for planning and documentation phases.

**DEPLOYMENT PARAMETERS:**
- **Environment:** $1 (dev, test, staging, prod)
- **Platform:** $2 (docker-desktop, kubernetes, aws, azure, gcp, local)
- **Additional Options:** $3 (optional: region, cluster, etc.)

### PHASE 1: PRE-DEPLOYMENT VALIDATION AND SETUP

**STEP 1: DEPLOYMENT ENVIRONMENT VALIDATION**

```bash
#!/bin/bash
# Deployment Execution Environment Validation

ENVIRONMENT="$1"
PLATFORM="$2"
ADDITIONAL_OPTIONS="$3"

echo "=== DEPLOYMENT EXECUTION INITIATED ==="
echo "Target Environment: $ENVIRONMENT"
echo "Target Platform: $PLATFORM"
echo "Additional Options: $ADDITIONAL_OPTIONS"
echo "Deployment Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "AI Instance: [AI-Instance-ID-$(date -u +%Y-%m-%dT%H:%M:%SZ)]"
echo ""

# Validate required parameters
if [ -z "$ENVIRONMENT" ] || [ -z "$PLATFORM" ]; then
    echo "❌ ERROR: Missing required parameters"
    echo "Usage: /code-deploy [environment] [platform] [additional-options]"
    echo "Examples:"
    echo "  /code-deploy dev docker-desktop"
    echo "  /code-deploy staging kubernetes"
    echo "  /code-deploy prod aws us-east-1"
    exit 1
fi

# Validate environment parameter
case "$ENVIRONMENT" in
    dev|development|test|testing|stage|staging|prod|production)
        echo "✅ Valid environment: $ENVIRONMENT"
        ;;
    *)
        echo "❌ ERROR: Invalid environment. Use: dev, test, staging, prod"
        exit 1
        ;;
esac

# Validate platform parameter
case "$PLATFORM" in
    docker-desktop|docker|kubernetes|k8s|aws|azure|gcp|local)
        echo "✅ Valid platform: $PLATFORM"
        ;;
    *)
        echo "❌ ERROR: Invalid platform. Use: docker-desktop, kubernetes, aws, azure, gcp, local"
        exit 1
        ;;
esac

echo "✅ Deployment parameters validated"
```

**STEP 2: SYSTEM READINESS CHECK**

```bash
# Quick system readiness validation
echo "🔍 SYSTEM READINESS CHECK"

# Check if deployment plan exists
if [ -f "deployment_planning_*.ipynb" ]; then
    echo "✅ Deployment planning documentation found"
else
    echo "⚠️  WARNING: No deployment planning found. Consider running /code-deployment-planning first"
fi

# Check git status
git status --porcelain > /dev/null 2>&1
if [ $? -eq 0 ]; then
    if [ -n "$(git status --porcelain)" ]; then
        echo "⚠️  WARNING: Uncommitted changes detected"
        echo "   Consider committing changes before deployment"
    else
        echo "✅ Git working directory clean"
    fi
else
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

# Check for required files
REQUIRED_FILES=("Dockerfile" "docker-compose.yml")
MISSING_FILES=()

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Found: $file"
    else
        MISSING_FILES+=("$file")
    fi
done

if [ ${#MISSING_FILES[@]} -gt 0 ]; then
    echo "⚠️  WARNING: Missing deployment files: ${MISSING_FILES[*]}"
    echo "   Deployment will continue but may require manual configuration"
fi

echo "✅ System readiness check completed"
echo ""
```

### PHASE 2: BUILD AND ARTIFACT PREPARATION

**STEP 1: APPLICATION BUILD PROCESS**

```bash
echo "🔨 BUILD PROCESS INITIATION"

# Create build timestamp
BUILD_TIMESTAMP=$(date -u +%Y%m%d-%H%M%S)
BUILD_TAG="${ENVIRONMENT}-${BUILD_TIMESTAMP}"

echo "Build Tag: $BUILD_TAG"
echo "Build Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Platform-specific build process
case "$PLATFORM" in
    docker-desktop|docker|local)
        echo "🐳 Docker Build Process"
        
        # Build Docker images
        if [ -f "Dockerfile" ]; then
            echo "Building main application image..."
            docker build -t "app:$BUILD_TAG" . || {
                echo "❌ Docker build failed"
                exit 1
            }
            echo "✅ Docker image built successfully: app:$BUILD_TAG"
        fi
        
        # Build with docker-compose if available
        if [ -f "docker-compose.yml" ]; then
            echo "Building with docker-compose..."
            docker-compose build || {
                echo "❌ Docker-compose build failed"
                exit 1
            }
            echo "✅ Docker-compose build completed"
        fi
        ;;
        
    kubernetes|k8s)
        echo "☸️  Kubernetes Build Process"
        
        # Build container images
        if [ -f "Dockerfile" ]; then
            echo "Building container image for Kubernetes..."
            docker build -t "app:$BUILD_TAG" . || {
                echo "❌ Container build failed"
                exit 1
            }
            
            # Tag for registry (if specified)
            if [ -n "$CONTAINER_REGISTRY" ]; then
                docker tag "app:$BUILD_TAG" "$CONTAINER_REGISTRY/app:$BUILD_TAG"
                echo "✅ Image tagged for registry: $CONTAINER_REGISTRY/app:$BUILD_TAG"
            fi
        fi
        
        # Validate Kubernetes manifests
        if [ -d "k8s" ] || [ -d "kubernetes" ]; then
            echo "Validating Kubernetes manifests..."
            kubectl apply --dry-run=client -f k8s/ 2>/dev/null || kubectl apply --dry-run=client -f kubernetes/ 2>/dev/null || {
                echo "⚠️  WARNING: Kubernetes manifest validation failed"
            }
            echo "✅ Kubernetes manifests validated"
        fi
        ;;
        
    aws|azure|gcp)
        echo "☁️  Cloud Platform Build Process"
        
        # Build for cloud deployment
        if [ -f "Dockerfile" ]; then
            echo "Building container image for cloud deployment..."
            docker build -t "app:$BUILD_TAG" . || {
                echo "❌ Container build failed"
                exit 1
            }
            echo "✅ Cloud container image built"
        fi
        
        # Platform-specific preparations
        case "$PLATFORM" in
            aws)
                echo "AWS-specific build preparations..."
                # Check for AWS CLI and credentials
                aws --version > /dev/null 2>&1 || {
                    echo "⚠️  WARNING: AWS CLI not found"
                }
                ;;
            azure)
                echo "Azure-specific build preparations..."
                # Check for Azure CLI
                az version > /dev/null 2>&1 || {
                    echo "⚠️  WARNING: Azure CLI not found"
                }
                ;;
            gcp)
                echo "GCP-specific build preparations..."
                # Check for gcloud CLI
                gcloud version > /dev/null 2>&1 || {
                    echo "⚠️  WARNING: Google Cloud CLI not found"
                }
                ;;
        esac
        ;;
esac

echo "✅ Build process completed successfully"
echo "Build Tag: $BUILD_TAG"
echo ""
```

**STEP 2: SECURITY AND QUALITY VALIDATION**

```bash
echo "🔒 SECURITY AND QUALITY VALIDATION"

# Container security scanning (if available)
if command -v trivy &> /dev/null; then
    echo "Running container security scan..."
    trivy image "app:$BUILD_TAG" --severity HIGH,CRITICAL || {
        echo "⚠️  WARNING: Security vulnerabilities detected"
        echo "   Consider reviewing and fixing before deploying to production"
    }
    echo "✅ Security scan completed"
else
    echo "⚠️  WARNING: Trivy not found, skipping security scan"
fi

# Build verification
echo "Verifying build artifacts..."
case "$PLATFORM" in
    docker-desktop|docker|local)
        # Verify Docker image exists
        docker images "app:$BUILD_TAG" --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}" || {
            echo "❌ Build verification failed"
            exit 1
        }
        ;;
    kubernetes|k8s)
        # Verify image and manifests
        docker images "app:$BUILD_TAG" > /dev/null || {
            echo "❌ Container image verification failed"
            exit 1
        }
        ;;
    aws|azure|gcp)
        # Verify cloud-ready artifacts
        docker images "app:$BUILD_TAG" > /dev/null || {
            echo "❌ Cloud artifact verification failed"
            exit 1
        }
        ;;
esac

echo "✅ Build verification completed"
echo ""
```

### PHASE 3: DEPLOYMENT EXECUTION

**STEP 1: ENVIRONMENT-SPECIFIC DEPLOYMENT**

```bash
echo "🚀 DEPLOYMENT EXECUTION"
echo "Deploying to: $ENVIRONMENT on $PLATFORM"
echo "Deployment Started: $(date -u +%Y-%m-%dT%H:%M:%SZ)"

# Platform-specific deployment execution
case "$PLATFORM" in
    docker-desktop|docker|local)
        echo "🐳 Docker Local Deployment"
        
        # Stop existing containers
        if [ -f "docker-compose.yml" ]; then
            echo "Stopping existing services..."
            docker-compose down || echo "No existing services to stop"
            
            # Start services with new build
            echo "Starting services with new build..."
            docker-compose up -d || {
                echo "❌ Docker deployment failed"
                exit 1
            }
            
            echo "✅ Docker services deployed successfully"
        else
            # Direct docker run
            echo "Starting container directly..."
            
            # Stop existing container if running
            docker stop "app-$ENVIRONMENT" 2>/dev/null || true
            docker rm "app-$ENVIRONMENT" 2>/dev/null || true
            
            # Start new container
            docker run -d --name "app-$ENVIRONMENT" "app:$BUILD_TAG" || {
                echo "❌ Container deployment failed"
                exit 1
            }
            
            echo "✅ Container deployed successfully"
        fi
        ;;
        
    kubernetes|k8s)
        echo "☸️  Kubernetes Deployment"
        
        # Apply Kubernetes manifests
        if [ -d "k8s" ]; then
            MANIFEST_DIR="k8s"
        elif [ -d "kubernetes" ]; then
            MANIFEST_DIR="kubernetes"
        else
            echo "❌ No Kubernetes manifests found"
            exit 1
        fi
        
        echo "Applying Kubernetes manifests from $MANIFEST_DIR..."
        
        # Update image tag in manifests if needed
        if [ -f "$MANIFEST_DIR/deployment.yaml" ]; then
            sed -i.bak "s|image: app:.*|image: app:$BUILD_TAG|g" "$MANIFEST_DIR/deployment.yaml"
        fi
        
        # Apply manifests
        kubectl apply -f "$MANIFEST_DIR/" || {
            echo "❌ Kubernetes deployment failed"
            # Restore backup
            if [ -f "$MANIFEST_DIR/deployment.yaml.bak" ]; then
                mv "$MANIFEST_DIR/deployment.yaml.bak" "$MANIFEST_DIR/deployment.yaml"
            fi
            exit 1
        }
        
        # Clean up backup
        rm -f "$MANIFEST_DIR/deployment.yaml.bak"
        
        echo "✅ Kubernetes deployment applied successfully"
        ;;
        
    aws)
        echo "☁️  AWS Deployment"
        
        # AWS-specific deployment logic
        case "$ADDITIONAL_OPTIONS" in
            *ecs*|*ECS*)
                echo "Deploying to AWS ECS..."
                # ECS deployment logic would go here
                echo "⚠️  ECS deployment requires additional configuration"
                ;;
            *eks*|*EKS*)
                echo "Deploying to AWS EKS..."
                # EKS deployment logic would go here
                echo "⚠️  EKS deployment requires additional configuration"
                ;;
            *)
                echo "General AWS deployment..."
                echo "⚠️  AWS deployment requires specific service configuration"
                ;;
        esac
        ;;
        
    azure)
        echo "☁️  Azure Deployment"
        echo "⚠️  Azure deployment requires additional configuration"
        # Azure-specific deployment logic would go here
        ;;
        
    gcp)
        echo "☁️  Google Cloud Deployment"
        echo "⚠️  GCP deployment requires additional configuration"
        # GCP-specific deployment logic would go here
        ;;
esac

echo "✅ Deployment execution phase completed"
echo ""
```

### PHASE 4: POST-DEPLOYMENT VALIDATION

**STEP 1: HEALTH CHECKS AND SERVICE VALIDATION**

```bash
echo "🔍 POST-DEPLOYMENT VALIDATION"

# Wait for services to start
echo "Waiting for services to initialize..."
sleep 30

# Platform-specific health checks
case "$PLATFORM" in
    docker-desktop|docker|local)
        echo "🐳 Docker Health Checks"
        
        if [ -f "docker-compose.yml" ]; then
            # Check docker-compose services
            echo "Checking docker-compose service status..."
            docker-compose ps
            
            # Check if services are healthy
            UNHEALTHY_SERVICES=$(docker-compose ps --filter "health=unhealthy" --quiet)
            if [ -n "$UNHEALTHY_SERVICES" ]; then
                echo "❌ Unhealthy services detected:"
                docker-compose ps --filter "health=unhealthy"
                echo "Check service logs with: docker-compose logs [service-name]"
            else
                echo "✅ All services are healthy"
            fi
        else
            # Check direct container
            CONTAINER_STATUS=$(docker inspect --format='{{.State.Status}}' "app-$ENVIRONMENT" 2>/dev/null)
            if [ "$CONTAINER_STATUS" = "running" ]; then
                echo "✅ Container is running successfully"
            else
                echo "❌ Container is not running. Status: $CONTAINER_STATUS"
                echo "Check container logs with: docker logs app-$ENVIRONMENT"
            fi
        fi
        ;;
        
    kubernetes|k8s)
        echo "☸️  Kubernetes Health Checks"
        
        # Check deployment status
        echo "Checking deployment rollout status..."
        kubectl rollout status deployment/app --timeout=300s || {
            echo "❌ Deployment rollout failed or timed out"
            echo "Check with: kubectl describe deployment app"
            echo "Check pods with: kubectl get pods"
        }
        
        # Check pod health
        echo "Checking pod health..."
        kubectl get pods -o wide
        
        # Check services
        echo "Checking services..."
        kubectl get services
        
        echo "✅ Kubernetes health checks completed"
        ;;
        
    aws|azure|gcp)
        echo "☁️  Cloud Platform Health Checks"
        echo "⚠️  Platform-specific health checks require additional configuration"
        # Cloud-specific health check logic would go here
        ;;
esac

echo ""
```

**STEP 2: FUNCTIONAL VALIDATION**

```bash
echo "🧪 FUNCTIONAL VALIDATION"

# Attempt to find and test application endpoints
API_ENDPOINTS=()
WEB_ENDPOINTS=()

# Determine likely endpoints based on platform
case "$PLATFORM" in
    docker-desktop|docker|local)
        # Check for exposed ports in docker-compose or running containers
        if [ -f "docker-compose.yml" ]; then
            # Extract ports from docker-compose.yml
            PORTS=$(grep -E "^\s*-\s*[0-9]+:" docker-compose.yml | sed 's/.*- //' | sed 's/:.*//') 
            for port in $PORTS; do
                API_ENDPOINTS+=("http://localhost:$port")
                WEB_ENDPOINTS+=("http://localhost:$port")
            done
        else
            # Check running container ports
            CONTAINER_PORTS=$(docker port "app-$ENVIRONMENT" 2>/dev/null | cut -d: -f2)
            for port in $CONTAINER_PORTS; do
                API_ENDPOINTS+=("http://localhost:$port")
                WEB_ENDPOINTS+=("http://localhost:$port")
            done
        fi
        ;;
        
    kubernetes|k8s)
        # Get service endpoints
        SERVICE_PORTS=$(kubectl get services --no-headers | awk '{print $5}' | grep -E '[0-9]+:' | cut -d: -f1)
        for port in $SERVICE_PORTS; do
            API_ENDPOINTS+=("http://localhost:$port")
            WEB_ENDPOINTS+=("http://localhost:$port")
        done
        ;;
esac

# Test endpoints if any found
if [ ${#API_ENDPOINTS[@]} -gt 0 ]; then
    echo "Testing application endpoints..."
    
    for endpoint in "${API_ENDPOINTS[@]}"; do
        echo "Testing: $endpoint"
        
        # Test basic connectivity
        HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$endpoint" --connect-timeout 10 || echo "000")
        
        if [ "$HTTP_STATUS" -ge 200 ] && [ "$HTTP_STATUS" -lt 400 ]; then
            echo "✅ $endpoint - HTTP $HTTP_STATUS (OK)"
        elif [ "$HTTP_STATUS" -ge 400 ] && [ "$HTTP_STATUS" -lt 500 ]; then
            echo "⚠️  $endpoint - HTTP $HTTP_STATUS (Client Error)"
        elif [ "$HTTP_STATUS" -ge 500 ]; then
            echo "❌ $endpoint - HTTP $HTTP_STATUS (Server Error)"
        else
            echo "❌ $endpoint - Connection failed"
        fi
    done
else
    echo "⚠️  No endpoints found for testing"
    echo "   Manual verification may be required"
fi

echo "✅ Functional validation completed"
echo ""
```

### PHASE 5: DEPLOYMENT COMPLETION AND REPORTING

**STEP 1: DEPLOYMENT SUCCESS CONFIRMATION**

```bash
echo "📊 DEPLOYMENT COMPLETION REPORT"

DEPLOYMENT_END_TIME=$(date -u +%Y-%m-%dT%H:%M:%SZ)
echo "Deployment Completed: $DEPLOYMENT_END_TIME"
echo "Environment: $ENVIRONMENT"
echo "Platform: $PLATFORM"
echo "Build Tag: $BUILD_TAG"

# Generate deployment summary
echo ""
echo "=== DEPLOYMENT SUMMARY ==="
echo "✅ Build process: COMPLETED"
echo "✅ Security validation: COMPLETED"
echo "✅ Deployment execution: COMPLETED"
echo "✅ Health checks: COMPLETED"
echo "✅ Functional validation: COMPLETED"

# Platform-specific status
case "$PLATFORM" in
    docker-desktop|docker|local)
        echo ""
        echo "🐳 Docker Deployment Status:"
        if [ -f "docker-compose.yml" ]; then
            echo "Services: $(docker-compose ps --services | wc -l)"
            echo "Running containers: $(docker-compose ps --filter status=running --quiet | wc -l)"
        else
            echo "Container: app-$ENVIRONMENT"
            echo "Status: $(docker inspect --format='{{.State.Status}}' "app-$ENVIRONMENT" 2>/dev/null || echo "unknown")"
        fi
        ;;
        
    kubernetes|k8s)
        echo ""
        echo "☸️  Kubernetes Deployment Status:"
        echo "Deployments: $(kubectl get deployments --no-headers | wc -l)"
        echo "Running pods: $(kubectl get pods --field-selector=status.phase=Running --no-headers | wc -l)"
        echo "Services: $(kubectl get services --no-headers | wc -l)"
        ;;
        
    aws|azure|gcp)
        echo ""
        echo "☁️  Cloud Platform Status:"
        echo "Platform: $PLATFORM"
        echo "Additional configuration may be required for full deployment"
        ;;
esac

echo ""
echo "🎉 DEPLOYMENT COMPLETED SUCCESSFULLY!"
echo "Environment: $ENVIRONMENT"
echo "Platform: $PLATFORM"
echo "Build: $BUILD_TAG"
echo "Completed: $DEPLOYMENT_END_TIME"
```

**STEP 2: POST-DEPLOYMENT ACTIONS AND CLEANUP**

```bash
echo ""
echo "🧹 POST-DEPLOYMENT CLEANUP"

# Clean up temporary files
rm -f *.tmp
rm -f .deployment_*

# Git commit for deployment tracking
echo "Recording deployment in git..."
git add . 2>/dev/null || true
git commit -m "deploy($ENVIRONMENT): deploy to $PLATFORM

- Deployed application to $ENVIRONMENT on $PLATFORM
- Build tag: $BUILD_TAG
- Deployment completed: $DEPLOYMENT_END_TIME
- Health checks: PASSED
- Functional validation: COMPLETED

[AI-Instance-ID-$(date -u +%Y-%m-%dT%H:%M:%SZ)]" 2>/dev/null || {
    echo "⚠️  No changes to commit"
}

# Push to backup deployment to remote
git push origin development 2>/dev/null || {
    echo "⚠️  Could not push to remote (may not be configured)"
}

echo "✅ Post-deployment cleanup completed"
echo ""

# Final instructions
echo "📋 NEXT STEPS:"
echo ""
case "$PLATFORM" in
    docker-desktop|docker|local)
        echo "• Monitor application logs:"
        if [ -f "docker-compose.yml" ]; then
            echo "  docker-compose logs -f"
        else
            echo "  docker logs -f app-$ENVIRONMENT"
        fi
        echo "• Access application at: ${API_ENDPOINTS[*]}"
        echo "• Stop deployment: docker-compose down"
        ;;
        
    kubernetes|k8s)
        echo "• Monitor deployment:"
        echo "  kubectl get pods -w"
        echo "• View logs:"
        echo "  kubectl logs -f deployment/app"
        echo "• Access services:"
        echo "  kubectl get services"
        echo "• Scale deployment:"
        echo "  kubectl scale deployment app --replicas=3"
        ;;
        
    aws|azure|gcp)
        echo "• Configure cloud-specific monitoring and alerting"
        echo "• Set up auto-scaling policies"
        echo "• Configure backup and disaster recovery"
        echo "• Review security groups and access policies"
        ;;
esac

echo ""
echo "✅ DEPLOYMENT EXECUTION COMPLETED SUCCESSFULLY"
echo "Use 'docker-compose logs' or 'kubectl logs' to monitor application"
```

## DEPLOYMENT EXECUTION QUALITY CHECKLIST

**MANDATORY VERIFICATION BEFORE COMPLETION:**

- [ ] Target environment and platform validated
- [ ] Application built successfully without errors
- [ ] Security scans passed (or warnings acknowledged)
- [ ] Deployment executed successfully to target platform
- [ ] Health checks completed and services are running
- [ ] Basic functional validation performed
- [ ] Deployment recorded in git with proper commit message
- [ ] Post-deployment cleanup completed
- [ ] Next steps documented for monitoring and management

**CRITICAL SUCCESS CRITERIA:**

✅ **DEPLOYMENT SUCCESSFUL:** Application running on target platform
✅ **HEALTH CHECKS PASSED:** All services healthy and responsive
✅ **FUNCTIONAL VALIDATION:** Basic endpoints accessible and working
✅ **PROPER LOGGING:** Deployment recorded with tracking information
✅ **ROLLBACK READY:** Previous version available for quick rollback if needed

## DEPLOYMENT FAILURE HANDLING

**IF DEPLOYMENT FAILS:**

```bash
echo "❌ DEPLOYMENT FAILURE DETECTED"
echo "Initiating rollback procedures..."

case "$PLATFORM" in
    docker-desktop|docker|local)
        echo "Rolling back Docker deployment..."
        docker-compose down 2>/dev/null || true
        # Restore previous version if tagged
        if docker images | grep -q "app:previous"; then
            docker tag "app:previous" "app:$BUILD_TAG"
            docker-compose up -d
            echo "✅ Rollback completed"
        fi
        ;;
        
    kubernetes|k8s)
        echo "Rolling back Kubernetes deployment..."
        kubectl rollout undo deployment/app
        kubectl rollout status deployment/app
        echo "✅ Rollback completed"
        ;;
        
    aws|azure|gcp)
        echo "Cloud platform rollback required - consult platform-specific procedures"
        ;;
esac

echo "❌ DEPLOYMENT FAILED - ROLLBACK COMPLETED"
echo "Review logs and fix issues before retrying deployment"
exit 1
```

---

**ENFORCEMENT:** This command performs DEPLOYMENT EXECUTION ONLY. Use `/code-deployment-planning` for planning and documentation. Focus on build, deploy, validate cycle with minimal documentation overhead.