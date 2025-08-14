#!/bin/bash

# Kubernetes Helm Chart Validation Script
# This script validates the Helm chart configuration and checks for security issues

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Log function
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if kubectl is installed
check_kubectl() {
    log "Checking kubectl installation..."
    if command -v kubectl &> /dev/null; then
        local version=$(kubectl version --client --short 2>/dev/null || echo "unknown version")
        success "kubectl is installed ($version)"
    else
        error "kubectl is not installed"
        echo "Please install kubectl from https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
}

# Check if kubectl is configured
check_kubectl_config() {
    log "Checking kubectl configuration..."
    if kubectl cluster-info &> /dev/null; then
        local cluster=$(kubectl config current-context 2>/dev/null || echo "unknown")
        success "kubectl is configured for cluster: $cluster"
    else
        error "kubectl is not configured or cluster is not accessible"
        echo "Please configure kubectl for your cluster"
        exit 1
    fi
}

# Check if Helm is installed
check_helm() {
    log "Checking Helm installation..."
    if command -v helm &> /dev/null; then
        local version=$(helm version --short 2>/dev/null || echo "unknown version")
        success "Helm is installed ($version)"
    else
        error "Helm is not installed"
        echo "Please install Helm from https://helm.sh/docs/intro/install/"
        exit 1
    fi
}

# Check required files
check_files() {
    log "Checking required Helm chart files..."
    
    local required_files=(
        "sample-app/Chart.yaml"
        "sample-app/values.yaml"
        "sample-app/templates/deployment.yaml"
        "sample-app/templates/service.yaml"
        "sample-app/templates/secret.yaml"
        "sample-app/templates/configmap.yaml"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            success "Found $file"
        else
            error "Missing required file: $file"
            exit 1
        fi
    done
}

# Check for sensitive data in configuration
check_sensitive_data() {
    log "Checking for sensitive data in configuration..."
    
    # Check for hardcoded base64 encoded passwords
    if grep -r "cGFzc3dvcmQ=" . 2>/dev/null | grep -v ".git" | grep -v "validate.sh"; then
        error "Hardcoded base64 encoded password found"
        echo "Please replace with placeholder values"
        exit 1
    else
        success "No hardcoded base64 encoded passwords found"
    fi
    
    # Check for other sensitive patterns
    if grep -r "password\|secret\|key\|token\|credential\|access_key\|secret_key\|api_key" . 2>/dev/null | grep -v ".git" | grep -v "validate.sh" | grep -v "description" | grep -v "values.yaml.example" | grep -v "SECURITY.md"; then
        warning "Potential sensitive data found"
        echo "Please review and ensure no actual secrets are committed"
    else
        success "No obvious sensitive data found"
    fi
}

# Validate Helm chart
validate_helm_chart() {
    log "Validating Helm chart..."
    
    cd sample-app
    
    # Check chart linting
    if helm lint . &> /dev/null; then
        success "Helm chart linting passed"
    else
        error "Helm chart linting failed"
        helm lint .
        exit 1
    fi
    
    # Check chart template rendering
    if helm template . --dry-run &> /dev/null; then
        success "Helm chart template rendering passed"
    else
        error "Helm chart template rendering failed"
        helm template . --dry-run
        exit 1
    fi
    
    cd ..
}

# Check values file security
check_values_security() {
    log "Checking values file security..."
    
    # Check if values.yaml is in .gitignore
    if grep -q "values.yaml" .gitignore 2>/dev/null; then
        success "values.yaml is in .gitignore"
    else
        warning "values.yaml is not in .gitignore"
        echo "Please add values.yaml to .gitignore to prevent committing secrets"
    fi
    
    # Check if values.yaml.example exists
    if [[ -f "sample-app/values.yaml.example" ]]; then
        success "values.yaml.example exists"
    else
        warning "values.yaml.example not found"
        echo "Consider creating an example values file for users"
    fi
}

# Check chart metadata
check_chart_metadata() {
    log "Checking chart metadata..."
    
    cd sample-app
    
    # Check Chart.yaml
    if [[ -f "Chart.yaml" ]]; then
        success "Chart.yaml exists"
        
        # Check for required fields
        if grep -q "name:" Chart.yaml; then
            success "Chart name is defined"
        else
            warning "Chart name not found in Chart.yaml"
        fi
        
        if grep -q "version:" Chart.yaml; then
            success "Chart version is defined"
        else
            warning "Chart version not found in Chart.yaml"
        fi
        
        if grep -q "description:" Chart.yaml; then
            success "Chart description is defined"
        else
            warning "Chart description not found in Chart.yaml"
        fi
    else
        error "Chart.yaml not found"
        exit 1
    fi
    
    cd ..
}

# Check resource limits
check_resource_limits() {
    log "Checking resource limits..."
    
    if grep -q "resources:" sample-app/values.yaml; then
        success "Resource limits are defined in values.yaml"
    else
        warning "No resource limits found in values.yaml"
        echo "Consider adding resource requests and limits"
    fi
}

# Check security contexts
check_security_contexts() {
    log "Checking security contexts..."
    
    if grep -q "securityContext:" sample-app/templates/deployment.yaml; then
        success "Security context is defined"
    else
        warning "No security context found"
        echo "Consider adding security contexts for better security"
    fi
}

# Check service account
check_service_account() {
    log "Checking service account configuration..."
    
    if [[ -f "sample-app/templates/serviceaccount.yaml" ]]; then
        success "Service account template exists"
    else
        warning "No service account template found"
        echo "Consider adding a service account for better security"
    fi
}

# Check for best practices
check_best_practices() {
    log "Checking Helm best practices..."
    
    # Check for image tags
    if grep -q "tag: \"latest\"" sample-app/values.yaml; then
        warning "Using 'latest' tag for image"
        echo "Consider using specific version tags for better reproducibility"
    else
        success "Using specific image tag"
    fi
    
    # Check for health checks
    if grep -q "livenessProbe\|readinessProbe" sample-app/templates/deployment.yaml; then
        success "Health checks are configured"
    else
        warning "No health checks found"
        echo "Consider adding liveness and readiness probes"
    fi
    
    # Check for proper labels
    if grep -q "app.kubernetes.io/name\|app.kubernetes.io/version" sample-app/templates/; then
        success "Proper Kubernetes labels are used"
    else
        warning "Consider using standard Kubernetes labels"
        echo "Use app.kubernetes.io/name and app.kubernetes.io/version labels"
    fi
}

# Check cluster resources
check_cluster_resources() {
    log "Checking cluster resources..."
    
    # Check nodes
    if kubectl get nodes &> /dev/null; then
        local node_count=$(kubectl get nodes --no-headers | wc -l)
        success "Cluster has $node_count nodes"
    else
        warning "Cannot access cluster nodes"
    fi
    
    # Check storage classes
    if kubectl get storageclass &> /dev/null; then
        local sc_count=$(kubectl get storageclass --no-headers | wc -l)
        success "Cluster has $sc_count storage classes"
    else
        warning "Cannot access storage classes"
    fi
}

# Check Helm repositories
check_helm_repos() {
    log "Checking Helm repositories..."
    
    if helm repo list &> /dev/null; then
        success "Helm repositories are configured"
    else
        warning "No Helm repositories found"
        echo "Consider adding necessary Helm repositories"
    fi
}

# Main validation function
main() {
    echo "=========================================="
    echo "Kubernetes Helm Chart Validation"
    echo "=========================================="
    echo
    
    check_kubectl
    check_kubectl_config
    check_helm
    check_files
    check_sensitive_data
    validate_helm_chart
    check_values_security
    check_chart_metadata
    check_resource_limits
    check_security_contexts
    check_service_account
    check_best_practices
    check_cluster_resources
    check_helm_repos
    
    echo
    echo "=========================================="
    success "Validation completed!"
    echo "=========================================="
    echo
    echo "Next steps:"
    echo "1. Update sample-app/values.yaml with your actual values"
    echo "2. Ensure values.yaml is in .gitignore"
    echo "3. Review and apply security best practices"
    echo "4. Deploy to your cluster: helm install sample-app ./sample-app"
    echo "5. Monitor the deployment and verify functionality"
    echo
    echo "Helm commands:"
    echo "  helm install sample-app ./sample-app"
    echo "  helm upgrade sample-app ./sample-app"
    echo "  helm uninstall sample-app"
    echo "  helm list"
    echo "  helm status sample-app"
}

# Run main function
main "$@"
