# Java Cloud Native Project

> ❗本项目绝大部分内容由AI生成

基于Spring Cloud的云原生微服务项目，采用现代化的云原生架构和最佳实践。

## 项目概述

本项目是一个完整的云原生微服务解决方案，具有以下特点：

- 🚀 基于Spring Cloud的微服务架构
- 🔐 内置安全性和认证授权
- 📊 完整的监控和可观测性
- 🔄 支持CI/CD自动化部署
- ⚡ 高性能和可扩展性设计
- 🛡️ 生产级别的最佳实践

## 技术栈

### 核心框架
- Java 21 LTS
- Spring Boot 3.3
- Spring Cloud 2024.0
- Spring Cloud Kubernetes

### 构建工具
- Gradle 9.x

### 数据存储
- PostgreSQL 16.x
- Redis Stack 7.2+
- RabbitMQ 3.13+

### 安全框架
- Spring Security
- OAuth2/OpenID Connect
- JWT Token

### 监控和可观测性
- Prometheus
- Grafana
- OpenTelemetry
- Spring Boot Actuator

### 容器和编排
- Docker
- Kubernetes
- Helm Charts

### 开发工具
- IntelliJ IDEA (推荐)
- Visual Studio Code
- Docker Desktop

## 项目结构

```
java-cloud/
├── docs/                    # 项目文档
│   ├── technical-design.md  # 技术设计文档
│   └── development-environment.md  # 开发环境配置
├── deploy/                  # 部署配置
│   ├── dev/                # 开发环境配置
│   ├── test/               # 测试环境配置
│   └── prod/               # 生产环境配置
├── services/               # 微服务模块
│   ├── auth-service/       # 认证服务
│   ├── user-service/       # 用户服务
│   └── ...                 # 其他微服务
└── common/                 # 公共模块
    ├── common-core/        # 核心工具类
    ├── common-security/    # 安全组件
    └── common-test/        # 测试工具
```

## 快速开始

### 环境要求

- JDK 21
- Docker Desktop with Kubernetes
- Gradle 9.x
- Git

### 开发环境设置

1. 克隆项目：
```bash
git clone <project-url>
cd java-cloud
```

2. 部署开发环境：
```bash
cd deploy/dev
chmod +x setup-dev.sh
./setup-dev.sh
```

3. 验证环境：
```bash
kubectl get pods -n dev
```

详细的开发环境配置请参考：[开发环境配置指南](docs/development-environment.md)

### 服务访问

开发环境的服务通过NodePort方式暴露：

| 服务 | NodePort | 说明 |
|------|----------|------|
| PostgreSQL | 31432 | 数据库服务 |
| Redis | 31379 | 缓存服务 |
| RabbitMQ | 31672 | 消息队列 |
| RabbitMQ UI | 31673 | 管理界面 |
| Prometheus | 31090 | 监控服务 |

## 文档

- [技术设计文档](docs/technical-design.md)
- [开发环境配置](docs/development-environment.md)
- [API文档](http://localhost:8080/swagger-ui.html)

## 开发指南

### 代码规范
- 遵循阿里巴巴Java开发规范
- 使用Checkstyle进行代码风格检查
- 使用SpotBugs进行静态代码分析

### 提交规范
```
<type>(<scope>): <subject>

<body>

<footer>
```

type类型：
- feat: 新功能
- fix: 修复Bug
- docs: 文档更新
- style: 代码格式调整
- refactor: 重构
- test: 测试用例
- chore: 构建过程或辅助工具变动

### 分支管理
- main: 主分支
- develop: 开发分支
- feature/*: 功能分支
- bugfix/*: 缺陷修复
- release/*: 发布分支

## 安全

- 所有的密码和密钥都通过Kubernetes Secrets管理
- 开发环境使用简化的安全配置
- 生产环境强制启用TLS和安全设置

## 监控

- Prometheus用于指标收集
- Grafana用于可视化
- OpenTelemetry用于分布式追踪
- ELK Stack用于日志管理

## 贡献指南

1. Fork本仓库
2. 创建功能分支
3. 提交变更
4. 创建Pull Request

## 许可证

[MIT License](LICENSE)
