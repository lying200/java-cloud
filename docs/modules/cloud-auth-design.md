# Cloud Auth 模块设计文档

## 1. 模块概述

`cloud-auth` 模块是系统的认证中心，基于 OAuth2.0 和 JWT 实现统一的身份认证和授权管理。支持多种认证方式，提供完整的权限管理功能。

## 2. 核心功能设计

### 2.1 认证服务

#### 2.1.1 认证方式
- 用户名密码认证
- 手机验证码认证
- 社交账号认证
- 扫码登录

#### 2.1.2 Token管理
```java
public class TokenInfo {
    private String accessToken;
    private String refreshToken;
    private Long expiresIn;
    private String tokenType;
    private Set<String> scope;
}
```

### 2.2 授权服务

#### 2.2.1 OAuth2配置
```java
@Configuration
public class AuthorizationServerConfig {
    @Bean
    public SecurityFilterChain authorizationServerSecurityFilterChain(
            HttpSecurity http) throws Exception {
        OAuth2AuthorizationServerConfiguration
            .applyDefaultSecurity(http);
        return http.build();
    }
}
```

#### 2.2.2 客户端管理
- 客户端注册
- 客户端认证
- 授权范围控制

### 2.3 权限管理

#### 2.3.1 RBAC模型
```java
public class Role {
    private String code;
    private String name;
    private Set<Permission> permissions;
}

public class Permission {
    private String code;
    private String name;
    private String resource;
    private String action;
}
```

#### 2.3.2 权限检查
- 角色检查
- 权限检查
- 资源访问控制

### 2.4 会话管理

#### 2.4.1 会话存储
- Redis会话存储
- 会话状态管理
- 会话同步

#### 2.4.2 会话控制
- 会话超时
- 并发登录控制
- 会话注销

## 3. 技术选型

### 3.1 核心框架
- Spring Authorization Server
- Spring Security
- Spring Boot 3.3.x
- Spring Data Redis

### 3.2 存储方案
- PostgreSQL（用户数据）
- Redis（会话存储）
- Cache（权限缓存）

### 3.3 安全组件
- JWT
- PBKDF2
- Spring Security Crypto

## 4. 数据模型

### 4.1 用户认证
```sql
CREATE TABLE oauth2_authorized_client (
    client_registration_id varchar(100) NOT NULL,
    principal_name varchar(200) NOT NULL,
    access_token_type varchar(100) NOT NULL,
    access_token_value bytea NOT NULL,
    access_token_issued_at timestamp NOT NULL,
    access_token_expires_at timestamp NOT NULL,
    access_token_scopes varchar(1000) DEFAULT NULL,
    refresh_token_value bytea DEFAULT NULL,
    refresh_token_issued_at timestamp DEFAULT NULL,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (client_registration_id, principal_name)
);
```

### 4.2 权限管理
```sql
CREATE TABLE roles (
    id bigserial PRIMARY KEY,
    code varchar(100) NOT NULL UNIQUE,
    name varchar(100) NOT NULL,
    description text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id bigserial PRIMARY KEY,
    code varchar(100) NOT NULL UNIQUE,
    name varchar(100) NOT NULL,
    resource varchar(200) NOT NULL,
    action varchar(100) NOT NULL,
    description text,
    created_at timestamp DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp DEFAULT CURRENT_TIMESTAMP
);
```

## 5. 接口设计

### 5.1 认证接口
```java
@RestController
@RequestMapping("/oauth2")
public class OAuth2Controller {
    @PostMapping("/token")
    public TokenInfo token(@Valid @RequestBody TokenRequest request);
    
    @PostMapping("/refresh")
    public TokenInfo refresh(@RequestParam String refreshToken);
    
    @PostMapping("/logout")
    public void logout(@RequestHeader("Authorization") String token);
}
```

### 5.2 权限接口
```java
@RestController
@RequestMapping("/admin")
public class PermissionController {
    @PostMapping("/roles")
    public Role createRole(@Valid @RequestBody RoleDTO role);
    
    @PostMapping("/permissions")
    public Permission createPermission(@Valid @RequestBody PermissionDTO permission);
}
```

## 6. 安全配置

### 6.1 密码策略
```java
@Configuration
public class PasswordEncoderConfig {
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder(12);
    }
}
```

### 6.2 Token配置
```yaml
spring:
  security:
    oauth2:
      authorization-server:
        token:
          access-token-time-to-live: 1h
          refresh-token-time-to-live: 30d
```

## 7. 缓存策略

### 7.1 权限缓存
```java
@Cacheable(value = "permissions", key = "#username")
public Set<String> getUserPermissions(String username) {
    // 获取用户权限
}
```

### 7.2 Token缓存
```java
@CacheEvict(value = "tokens", key = "#token")
public void logout(String token) {
    // 注销处理
}
```

## 8. 监控指标

### 8.1 认证指标
- 登录成功率
- 登录失败率
- Token刷新率

### 8.2 性能指标
- 认证响应时间
- 并发认证数
- 缓存命中率

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-auth
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-auth
          image: cloud-auth:latest
          ports:
            - containerPort: 9000
```

### 9.2 资源配置
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 10. 测试策略

### 10.1 单元测试
- 认证流程测试
- 权限检查测试
- Token管理测试

### 10.2 集成测试
- OAuth2流程测试
- 性能测试
- 安全测试

## 11. 注意事项

### 11.1 安全考虑
- 密码加密存储
- Token安全传输
- 防止暴力破解

### 11.2 性能考虑
- 合理的缓存策略
- Token有效期设置
- 并发控制

### 11.3 可用性考虑
- 高可用部署
- 熔断降级
- 监控告警
