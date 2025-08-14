
# Kubernetes Sample Application with Helm

This project demonstrates deploying a sample NGINX application on Kubernetes using Helm charts with proper security practices and best practices.

## 🏗️ Architecture Overview

The project deploys a sample NGINX application using Helm with the following Kubernetes resources:

- **Namespace**: Isolated environment for the application
- **ConfigMap**: Non-sensitive configuration data
- **Secret**: Sensitive data (passwords, API keys, etc.)
- **PersistentVolumeClaim**: Storage for the application
- **Deployment**: Application deployment with replicas
- **Service**: LoadBalancer for external access
- **Ingress**: HTTP routing and SSL termination
- **HorizontalPodAutoscaler**: Automatic scaling based on metrics
- **ServiceAccount**: RBAC for pod permissions

## 📁 Project Structure

```
k8s-project-2/
├── sample-app/                    # Helm chart directory
│   ├── Chart.yaml                 # Chart metadata
│   ├── values.yaml                # Default values (TEMPLATE)
│   ├── values.yaml.example        # Example values file
│   ├── .helmignore                # Helm ignore patterns
│   └── templates/                 # Kubernetes manifests
│       ├── deployment.yaml        # Application deployment
│       ├── service.yaml           # LoadBalancer service
│       ├── ingress.yaml           # Ingress configuration
│       ├── configmap.yaml         # Non-sensitive configuration
│       ├── secret.yaml            # Sensitive data template
│       ├── pvc.yaml               # Persistent Volume Claim
│       ├── hpa.yaml               # Horizontal Pod Autoscaler
│       ├── serviceaccount.yaml    # Service account
│       ├── nginx-deployment.yaml  # NGINX deployment
│       ├── nginx-content-configmap.yaml # NGINX content
│       ├── sample-app-deployment.yaml   # Sample app deployment
│       ├── sample-app-service.yaml      # Sample app service
│       ├── _helpers.tpl           # Helm template helpers
│       ├── NOTES.txt              # Post-installation notes
│       └── tests/                 # Helm test templates
├── README.md                      # This file
├── SECURITY.md                    # Security documentation
├── validate.sh                    # Validation script
└── .gitignore                     # Git ignore rules
```

## 🚀 Features

### Application Features
- **NGINX Web Server**: Latest stable version
- **Persistent Storage**: Data persistence across pod restarts
- **Load Balancing**: External access via LoadBalancer
- **Ingress Routing**: HTTP routing with host-based rules
- **Auto Scaling**: Horizontal Pod Autoscaler for dynamic scaling
- **Resource Management**: CPU and memory limits/requests

### Security Features
- **Secret Management**: Proper handling of sensitive data
- **Namespace Isolation**: Application isolation
- **Resource Limits**: Prevents resource starvation
- **Service Account**: Proper RBAC permissions
- **Network Security**: Controlled network access

### Helm Features
- **Templating**: Dynamic configuration with Helm templates
- **Values Management**: Environment-specific configurations
- **Release Management**: Easy deployment and upgrades
- **Rollback Support**: Quick rollback to previous versions

## 📋 Prerequisites

### Required Tools
- **kubectl** (>= 1.20.0)
- **Helm** (>= 3.0.0)
- **Kubernetes cluster** (EKS, GKE, AKS, or local)

### Cluster Requirements
- Kubernetes cluster with proper permissions
- NGINX Ingress Controller (optional)
- Storage class for persistent volumes

## 🔧 Setup Instructions

### 1. Clone and Configure Repository

```bash
git clone <your-repository-url>
cd k8s-project-2
```

### 2. Configure Secrets

**⚠️ IMPORTANT: Never commit actual secrets to version control!**

1. **Copy the example values file**:
   ```bash
   cp sample-app/values.yaml.example sample-app/values.yaml
   ```

2. **Update the values file** with your actual values:
   ```bash
   # Encode your password
   echo -n "your-actual-password" | base64
   
   # Edit values.yaml and replace the placeholder values
   nano sample-app/values.yaml
   ```

3. **Verify the values file is in .gitignore**:
   ```bash
   # The values.yaml file should be ignored by git
   git status
   ```

### 3. Configure Application Settings

1. **Update ConfigMap values** (if needed):
   ```bash
   # Edit sample-app/values.yaml to change environment settings
   nano sample-app/values.yaml
   ```

2. **Update deployment settings**:
   ```bash
   # Edit sample-app/values.yaml to change resource limits, replicas, etc.
   nano sample-app/values.yaml
   ```

### 4. Deploy the Application

#### Option 1: Install the Helm Chart
```bash
# Navigate to the chart directory
cd sample-app

# Install the chart
helm install sample-app .

# Or install with a custom release name
helm install my-release .
```

#### Option 2: Install with Custom Values
```bash
# Install with custom values file
helm install sample-app . -f values-prod.yaml

# Install with inline values
helm install sample-app . --set replicaCount=3 --set image.tag=1.19
```

#### Option 3: Install in Specific Namespace
```bash
# Create namespace first
kubectl create namespace sample-app

# Install in specific namespace
helm install sample-app . --namespace sample-app --create-namespace
```

## 🚀 Usage

### Verify Deployment

1. **Check Helm releases**:
   ```bash
   helm list
   helm status sample-app
   ```

2. **Check Kubernetes resources**:
   ```bash
   kubectl get all -l app.kubernetes.io/name=sample-app
   ```

3. **Check persistent volume claims**:
   ```bash
   kubectl get pvc
   ```

4. **Check services**:
   ```bash
   kubectl get services
   ```

### Access the Application

1. **Get the LoadBalancer external IP**:
   ```bash
   kubectl get service sample-app
   ```

2. **Access the application**:
   ```bash
   # Using curl
   curl http://<EXTERNAL-IP>
   
   # Or open in browser
   open http://<EXTERNAL-IP>
   ```

3. **Check ingress (if configured)**:
   ```bash
   kubectl get ingress
   ```

### Monitor the Application

1. **Check pod logs**:
   ```bash
   kubectl logs -f deployment/sample-app
   ```

2. **Check Helm release status**:
   ```bash
   helm status sample-app
   ```

3. **Check resource usage**:
   ```bash
   kubectl top pods
   kubectl top nodes
   ```

### Upgrade the Application

```bash
# Upgrade with new values
helm upgrade sample-app . -f values-prod.yaml

# Upgrade with inline values
helm upgrade sample-app . --set replicaCount=5

# Check upgrade status
helm status sample-app
```

### Rollback the Application

```bash
# List release history
helm history sample-app

# Rollback to previous version
helm rollback sample-app 1

# Check rollback status
helm status sample-app
```

## 🔒 Security Considerations

### ⚠️ **IMPORTANT: Security Best Practices**

1. **Never commit sensitive information**:
   - Passwords and API keys
   - Database credentials
   - JWT secrets and tokens
   - Private keys and certificates
   - Base64 encoded secrets

2. **Use proper secret management**:
   - Store secrets in Kubernetes Secrets (not ConfigMaps)
   - Use external secret management tools (AWS Secrets Manager, HashiCorp Vault)
   - Rotate secrets regularly
   - Use RBAC to control access to secrets

3. **Follow the principle of least privilege**:
   - Use service accounts with minimal permissions
   - Implement network policies
   - Use security contexts
   - Regular permission audits

4. **Monitor and audit**:
   - Enable audit logging
   - Monitor pod and cluster events
   - Regular security assessments
   - Use security scanning tools

### Security Features Implemented

- ✅ **Secret Management**: Sensitive data stored in Kubernetes Secrets
- ✅ **Namespace Isolation**: Application runs in isolated namespace
- ✅ **Resource Limits**: Prevents resource starvation attacks
- ✅ **Service Account**: Proper RBAC permissions
- ✅ **No Hardcoded Secrets**: All sensitive data externalized

## 🛠️ Troubleshooting

### Common Issues

#### Helm Installation Fails
```bash
# Check Helm version
helm version

# Check cluster connectivity
kubectl cluster-info

# Check for existing releases
helm list
```

#### Pods Not Starting
```bash
# Check pod events
kubectl describe pod <pod-name>

# Check pod logs
kubectl logs <pod-name>

# Check resource limits
kubectl describe nodes
```

#### Service Not Accessible
```bash
# Check service configuration
kubectl describe service sample-app

# Check endpoints
kubectl get endpoints

# Check pod labels
kubectl get pods --show-labels
```

#### Persistent Volume Issues
```bash
# Check PVC status
kubectl get pvc

# Check storage class
kubectl get storageclass

# Check PV details
kubectl describe pvc <pvc-name>
```

### Debug Commands

```bash
# Check Helm release
helm get values sample-app
helm get manifest sample-app

# Check Kubernetes resources
kubectl get all -l app.kubernetes.io/name=sample-app

# Check events
kubectl get events --sort-by='.lastTimestamp'

# Check Helm hooks
helm get hooks sample-app
```

## 📊 Resource Management

### Current Resource Limits

The deployment includes resource requests and limits:

```yaml
resources:
  requests:
    cpu: 250m
    memory: 64Mi
  limits:
    cpu: 500m
    memory: 128Mi
```

### Auto Scaling

The application includes Horizontal Pod Autoscaler:

```yaml
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 100
  targetCPUUtilizationPercentage: 80
```

### Storage

The application uses persistent storage:

- **Storage Class**: Default cluster storage class
- **Access Mode**: ReadWriteOnce
- **Size**: 100Mi (configurable)

## 🧹 Clean Up

### Remove the Application

```bash
# Uninstall the Helm release
helm uninstall sample-app

# Verify cleanup
kubectl get all -l app.kubernetes.io/name=sample-app

# Remove namespace (if created)
kubectl delete namespace sample-app
```

### Clean Up Persistent Data

```bash
# Remove PVC (this will delete persistent data)
kubectl delete pvc <pvc-name>

# Remove PV (if not automatically cleaned up)
kubectl delete pv <pv-name>
```

## 📈 Best Practices

### Helm Best Practices
1. **Use semantic versioning** for chart versions
2. **Validate charts** before deployment
3. **Use values files** for environment-specific configs
4. **Implement proper rollback procedures**

### Security
1. **Follow least privilege principle**
2. **Use RBAC** for access control
3. **Implement network policies**
4. **Regular security audits**

### Monitoring
1. **Set up monitoring** (Prometheus, Grafana)
2. **Implement logging** (ELK stack, Fluentd)
3. **Use alerting** for critical issues
4. **Regular backup** of persistent data

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test in a development environment
5. Submit a pull request
6. Ensure all security checks pass

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For issues and questions:
1. Check the troubleshooting section
2. Review Helm and Kubernetes documentation
3. Contact the DevOps team
4. Check cluster support if needed

## 📚 Resources

- [Helm Documentation](https://helm.sh/docs/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Helm Best Practices](https://helm.sh/docs/chart_best_practices/)
- [Kubernetes Security Best Practices](https://kubernetes.io/docs/concepts/security/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)
