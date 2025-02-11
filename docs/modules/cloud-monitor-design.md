# Cloud Monitor 模块设计文档

## 1. 模块概述

`cloud-monitor` 模块是系统的监控中心，负责整个系统的可观测性，包括监控指标收集、链路追踪、日志聚合、告警管理等功能。基于 OpenTelemetry 实现统一的可观测性标准。

## 2. 核心功能设计

### 2.1 监控指标

#### 2.1.1 系统指标
```java
public class SystemMetrics {
    private Double cpuUsage;
    private Double memoryUsage;
    private Double diskUsage;
    private Integer threadCount;
    private Integer connectionCount;
    private Double qps;
}
```

#### 2.1.2 业务指标
```java
public class BusinessMetrics {
    private String serviceName;
    private String metricName;
    private String metricType;
    private Double value;
    private Map<String, String> tags;
    private Long timestamp;
}
```

### 2.2 链路追踪

#### 2.2.1 追踪模型
```java
public class Trace {
    private String traceId;
    private String spanId;
    private String parentSpanId;
    private String serviceName;
    private String operationName;
    private Long startTime;
    private Long duration;
    private Map<String, String> tags;
    private List<Event> events;
}
```

#### 2.2.2 追踪功能
- 分布式追踪
- 性能分析
- 错误追踪
- 依赖分析

### 2.3 日志管理

#### 2.3.1 日志模型
```java
public class LogEntry {
    private String timestamp;
    private String level;
    private String service;
    private String traceId;
    private String spanId;
    private String message;
    private Map<String, String> metadata;
    private String stackTrace;
}
```

#### 2.3.2 日志功能
- 日志收集
- 日志检索
- 日志分析
- 日志存储

### 2.4 告警管理

#### 2.4.1 告警规则
```java
public class AlertRule {
    private Long id;
    private String name;
    private String metric;
    private String condition;
    private String threshold;
    private String duration;
    private String severity;
    private List<String> notifications;
    private Boolean enabled;
}
```

#### 2.4.2 告警通知
- 邮件通知
- 短信通知
- WebHook
- 钉钉/企业微信

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- OpenTelemetry
- Micrometer

### 3.2 监控工具
- Prometheus（指标存储）
- Grafana（可视化）
- Jaeger（链路追踪）
- Loki（日志管理）

### 3.3 告警集成
- Alertmanager
- 邮件服务
- 短信服务
- 企业微信/钉钉

## 4. 指标设计

### 4.1 RED指标
```java
@Configuration
public class RedMetricsConfig {
    @Bean
    MeterBinder redMetrics() {
        return registry -> {
            // Rate (请求速率)
            Counter requests = Counter.builder("http.requests.total")
                .description("Total HTTP requests")
                .register(registry);
                
            // Errors (错误率)
            Counter errors = Counter.builder("http.requests.errors")
                .description("Total HTTP errors")
                .register(registry);
                
            // Duration (响应时间)
            Timer latency = Timer.builder("http.requests.duration")
                .description("Request latency")
                .register(registry);
        };
    }
}
```

### 4.2 USE指标
```java
@Configuration
public class UseMetricsConfig {
    @Bean
    MeterBinder useMetrics() {
        return registry -> {
            // Utilization (使用率)
            Gauge.builder("system.cpu.usage", this::getCpuUsage)
                .register(registry);
                
            // Saturation (饱和度)
            Gauge.builder("system.memory.used", this::getMemoryUsed)
                .register(registry);
                
            // Errors (错误数)
            Counter.builder("system.errors")
                .register(registry);
        };
    }
}
```

## 5. 追踪配置

### 5.1 OpenTelemetry配置
```yaml
opentelemetry:
  sdk:
    resource:
      attributes:
        service.name: ${spring.application.name}
    traces:
      exporter: jaeger
      sampler:
        type: parentbased_always_on
```

### 5.2 追踪拦截器
```java
@Aspect
@Component
public class TracingAspect {
    @Around("@annotation(Traced)")
    public Object trace(ProceedingJoinPoint point) {
        Span span = tracer.spanBuilder(point.getSignature().getName()).startSpan();
        try (Scope scope = span.makeCurrent()) {
            return point.proceed();
        } catch (Throwable t) {
            span.recordException(t);
            throw t;
        } finally {
            span.end();
        }
    }
}
```

## 6. 日志配置

### 6.1 Logback配置
```xml
<configuration>
    <appender name="LOKI" class="com.github.loki4j.logback.Loki4jAppender">
        <http>
            <url>http://loki:3100/loki/api/v1/push</url>
        </http>
        <format>
            <label>
                <pattern>app=${spring.application.name},host=${HOSTNAME},level=%level</pattern>
            </label>
            <message>
                <pattern>%d{ISO8601} [%thread] %-5level %logger{36} - %msg%n</pattern>
            </message>
        </format>
    </appender>
</configuration>
```

### 6.2 日志聚合
```java
@Configuration
public class LogConfig {
    @Bean
    public LoggingEventCompositeJsonEncoder encoder() {
        LoggingEventCompositeJsonEncoder encoder = new LoggingEventCompositeJsonEncoder();
        encoder.setProviders(Arrays.asList(
            new LoggingEventJsonProviders.TimestampJsonProvider(),
            new LoggingEventJsonProviders.MessageJsonProvider(),
            new LoggingEventJsonProviders.LoggerNameJsonProvider(),
            new LoggingEventJsonProviders.ThreadNameJsonProvider(),
            new LoggingEventJsonProviders.StackTraceJsonProvider()
        ));
        return encoder;
    }
}
```

## 7. 告警配置

### 7.1 Prometheus告警规则
```yaml
groups:
  - name: app_alerts
    rules:
      - alert: HighErrorRate
        expr: rate(http_requests_errors_total[5m]) > 0.1
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: High Error Rate
          description: Error rate is above 10% for 5 minutes
```

### 7.2 告警处理
```java
@Service
public class AlertHandler {
    @Autowired
    private NotificationService notificationService;
    
    public void handleAlert(Alert alert) {
        // 1. 处理告警
        // 2. 发送通知
        // 3. 记录告警历史
    }
}
```

## 8. 监控面板

### 8.1 系统概览
```json
{
  "dashboard": {
    "panels": [
      {
        "title": "System Overview",
        "type": "row",
        "panels": [
          {
            "title": "CPU Usage",
            "type": "graph",
            "datasource": "Prometheus"
          },
          {
            "title": "Memory Usage",
            "type": "graph",
            "datasource": "Prometheus"
          }
        ]
      }
    ]
  }
}
```

### 8.2 业务监控
```json
{
  "dashboard": {
    "panels": [
      {
        "title": "Business Metrics",
        "type": "row",
        "panels": [
          {
            "title": "Order Count",
            "type": "stat",
            "datasource": "Prometheus"
          },
          {
            "title": "User Activity",
            "type": "graph",
            "datasource": "Prometheus"
          }
        ]
      }
    ]
  }
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-monitor
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-monitor
          image: cloud-monitor:latest
          ports:
            - containerPort: 8080
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

## 10. 监控指标

### 10.1 系统指标
- CPU使用率
- 内存使用率
- 磁盘使用率
- 网络流量
- JVM指标

### 10.2 业务指标
- 接口调用量
- 错误率
- 响应时间
- 并发用户数
- 业务成功率

## 11. 测试策略

### 11.1 功能测试
- 指标收集测试
- 链路追踪测试
- 日志聚合测试
- 告警规则测试

### 11.2 性能测试
- 高并发指标收集
- 日志写入性能
- 查询响应时间

## 12. 注意事项

### 12.1 性能考虑
- 采样率控制
- 数据压缩
- 存储周期
- 查询优化

### 12.2 可用性考虑
- 监控高可用
- 数据备份
- 故障转移
- 容量规划

### 12.3 安全考虑
- 访问控制
- 数据加密
- 审计日志
- 敏感信息保护
