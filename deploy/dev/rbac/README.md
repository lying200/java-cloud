# 本地开发环境 Kubernetes RBAC 配置指南

本文档说明如何在本地开发环境中配置 Spring Cloud Kubernetes 的 RBAC 权限。
参考：https://www.cnblogs.com/daniel-hutao/p/17899757.html

## 1. RBAC 资源说明

RBAC（基于角色的访问控制）是 Kubernetes 中用于管理对集群资源访问权限的机制。它由以下几个关键概念组成：

- **Role**：定义了对特定命名空间中资源的操作权限
- **RoleBinding**：将角色绑定到用户、组或 ServiceAccount
- **ClusterRole**：类似于 Role，但作用于整个集群
- **ClusterRoleBinding**：将 ClusterRole 绑定到用户、组或 ServiceAccount

## 2. 配置步骤

### 2.1 创建 ServiceAccount

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: spring-cloud-kubernetes
  namespace: dev
```

### 2.2 创建 Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: spring-cloud-kubernetes
  namespace: dev
rules:
  - apiGroups: [""]
    resources: ["configmaps", "pods", "services", "endpoints", "secrets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["create", "delete", "patch", "update"]
```

### 2.3 创建 RoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: spring-cloud-kubernetes
  namespace: dev
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: spring-cloud-kubernetes
subjects:
  - kind: ServiceAccount
    name: spring-cloud-kubernetes
    namespace: dev
```

### 2.4 创建 ServiceAccount Token

> 注意：在 Kubernetes 1.24+ 版本中，需要手动创建 Secret 来获取 ServiceAccount Token

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: spring-cloud-kubernetes-token
  namespace: dev
  annotations:
    kubernetes.io/service-account.name: spring-cloud-kubernetes
type: kubernetes.io/service-account-token
```

## 3. 本地 kubeconfig 配置

### 3.1 获取必要信息

1. 获取 Token：
```bash
# 获取 token
kubectl get secret  spring-cloud-kubernetes-token -n dev -o jsonpath='{.data.token}' | base64 -d
```

2. 获取集群 CA 证书：
```bash
kubectl get secret  spring-cloud-kubernetes-token -n dev -o jsonpath='{.data.ca\.crt}'
```

### 3.2 创建 kubeconfig 文件

创建 ~/.kube/config 文件（如果已存在请先备份）：

```yaml
apiVersion: v1
clusters:
  - cluster:
      certificate-authority-data: ${CA_CRT}
      server: https://192.168.3.201:6443
    name: kubernetes
contexts:
  - context:
      cluster: kubernetes
      user: spring-cloud-kubernetes
    name: spring-cloud-kubernetes@kubernetes
current-context: spring-cloud-kubernetes@kubernetes
kind: Config
preferences: {}
users:
  - name: spring-cloud-kubernetes
    user:
      token: ${TOKEN}
```

### 3.3 验证配置

```bash
# 测试集群连接
kubectl get pods -n dev

# 测试配置访问权限
kubectl get configmaps -n dev
kubectl get services -n dev
```

## 5. Spring Boot 应用配置

完成以上配置后，Spring Boot 应用将自动使用本地 kubeconfig 中的认证信息。
bootstrap.yml 中只需保留基本配置：

```yaml
spring:
  cloud:
    kubernetes:
      enabled: true
      config:
        enabled: true
        namespace: dev
      discovery:
        enabled: true
        namespace: dev
```

## 6. 故障排查

如果遇到认证问题：

1. 检查 token 是否过期
2. 验证 ServiceAccount 权限
3. 确认集群地址是否正确
4. 检查 TLS 证书配置

可以通过开启调试日志来排查：

```yaml
logging:
  level:
    org.springframework.cloud.kubernetes: DEBUG
    io.kubernetes.client: DEBUG
