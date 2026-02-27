# S3 CSI Driver Setup

The S3 CSI driver allows you to mount S3 buckets as volumes in your Kubernetes pods.

## Configuration

### 1. For AWS S3

Update `infrastructure/production/s3-csi-driver/release.yaml`:

```yaml
values:
  storageClass:
    parameters:
      bucketName: your-bucket-name
      region: us-east-1
```

Create AWS credentials secret:

```bash
kubectl create secret generic s3-credentials \
  --namespace=s3-csi-driver \
  --from-literal=accessKeyId=YOUR_ACCESS_KEY \
  --from-literal=secretAccessKey=YOUR_SECRET_KEY
```

### 2. For S3-Compatible Storage (MinIO, etc.)

Update `infrastructure/production/s3-csi-driver/release.yaml`:

```yaml
values:
  storageClass:
    parameters:
      endpoint: https://minio.example.com
      bucketName: your-bucket-name
      region: us-east-1  # can be any value for MinIO
```

## Usage Example

### Create a PersistentVolumeClaim

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: s3-pvc
  namespace: your-namespace
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: s3-csi
  resources:
    requests:
      storage: 1200Gi  # Virtual size, actual usage is unlimited
```

### Use in a Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: s3-app
spec:
  containers:
  - name: app
    image: busybox
    command: ["/bin/sh"]
    args: ["-c", "ls -la /data && sleep 3600"]
    volumeMounts:
    - name: s3-storage
      mountPath: /data
  volumes:
  - name: s3-storage
    persistentVolumeClaim:
      claimName: s3-pvc
```

## Deployment

```bash
# Apply the infrastructure
kubectl apply -k infrastructure/production/s3-csi-driver/

# Verify deployment
kubectl get pods -n s3-csi-driver
kubectl get storageclass s3-csi
```

## StorageClass Options

Available mount options:

- `allow-delete` - Allow file deletion
- `allow-other` - Allow access from other users
- `region` - AWS region or S3-compatible region
- `read-only` - Mount as read-only
- `cache=/tmp/cache` - Local cache directory
- `max-cache-size=10737418240` - Cache size in bytes (10GB)

## Limitations

- Not suitable for databases (use block storage instead)
- Best for read-heavy workloads
- Write performance is slower than block storage
- Eventually consistent

## Troubleshooting

```bash
# Check driver pods
kubectl get pods -n s3-csi-driver

# Check driver logs
kubectl logs -n s3-csi-driver -l app=aws-mountpoint-s3-csi-driver

# Describe PVC
kubectl describe pvc s3-pvc -n your-namespace

# Check mount in pod
kubectl exec -it your-pod -- df -h /data
```

## Use Cases

✅ **Good for:**
- Media files (videos, images, audio)
- Backups
- Logs and archives
- Static website content
- ML datasets

❌ **Not good for:**
- Databases
- Frequent small writes
- Applications requiring POSIX semantics
- Low-latency requirements
