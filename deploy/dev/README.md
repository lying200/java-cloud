# 开发环境部署指南

本指南提供了在低配置Kubernetes集群上部署开发环境的说明。

## 环境要求
- Kubernetes集群（3节点，每节点2C6G）
- kubectl命令行工具
- bash shell环境

## 环境准备

1. 在每个K8s节点上创建本地存储目录：
```bash
# 在每个节点上执行
sudo mkdir -p /data/vol1 /data/vol2 /data/vol3
sudo chmod 777 /data/vol1 /data/vol2 /data/vol3
```

2. 修改storage-class.yaml中的节点名称：
```yaml
# 将nodeAffinity中的节点名称改为实际的节点名称
values:
- node1  # 改为实际节点名称
```

## 资源配置说明
所有服务都已针对开发环境进行了资源优化：

| 服务 | CPU请求 | CPU限制 | 内存请求 | 内存限制 | 存储 |
|------|---------|---------|-----------|-----------|-------|
| PostgreSQL | 200m | 500m | 512Mi | 1Gi | 2Gi |
| Redis | 100m | 200m | 256Mi | 512Mi | 1Gi |
| RabbitMQ | 200m | 500m | 256Mi | 512Mi | 1Gi |
| Prometheus | 100m | 200m | 256Mi | 512Mi | - |

总计资源使用：
- CPU请求：600m（0.6核）
- 内存请求：1.25Gi
- 存储：4Gi

## 快速开始

1. 进入部署目录：
```bash
cd deploy/dev
```

2. 添加执行权限：
```bash
chmod +x setup-dev.sh
```

3. 执行部署脚本：
```bash
./setup-dev.sh
```

## 访问服务

所有服务都通过NodePort方式暴露，可以通过任意节点IP加对应端口访问：

| 服务 | 内部端口 | NodePort | 用途 |
|------|----------|----------|------|
| PostgreSQL | 5432 | 31432 | 数据库服务 |
| Redis | 6379 | 31379 | 缓存服务 |
| RabbitMQ | 5672 | 31672 | 消息队列服务 |
| RabbitMQ Management | 15672 | 31673 | RabbitMQ管理界面 |
| Prometheus | 9090 | 31090 | 监控服务 |

### 访问示例

1. RabbitMQ管理界面：
```
http://<节点IP>:31673
```

2. 应用程序连接配置示例：

```yaml
spring:
  # PostgreSQL配置
  datasource:
    url: jdbc:postgresql://<节点IP>:31432/appdb
    username: devuser
    password: devpassword

  # Redis配置
  redis:
    host: <节点IP>
    port: 31379

  # RabbitMQ配置
  rabbitmq:
    host: <节点IP>
    port: 31672
    username: devuser
    password: devpassword

  # Prometheus监控地址
  prometheus:
    url: http://<节点IP>:31090
```

注意：将`<节点IP>`替换为任意K8s节点的实际IP地址。

### 安全说明

这是开发环境配置，服务直接通过NodePort暴露。在生产环境中，建议：
1. 使用Ingress Controller管理外部访问
2. 启用TLS加密
3. 实施网络策略
4. 加强访问控制

## 注意事项

1. 这是精简的开发环境配置，仅包含基本服务
2. 所有服务都使用单副本部署
3. 资源限制已针对开发环境优化
4. 生产环境请使用更严格的安全配置

## 清理环境

删除所有资源：
```bash
kubectl delete namespace dev
```
