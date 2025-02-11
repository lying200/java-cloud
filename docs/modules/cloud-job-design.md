# Cloud Job 模块设计文档

## 1. 模块概述

`cloud-job` 模块是分布式任务调度中心，负责系统中所有定时任务、批处理任务的统一管理和调度。基于XXL-JOB进行二次开发，支持分布式调度、任务编排、监控告警等功能。

## 2. 核心功能设计

### 2.1 任务管理

#### 2.1.1 任务模型
```java
public class JobInfo {
    private Long id;
    private String name;
    private String description;
    private String handler;
    private String params;
    private String cron;
    private String strategy;
    private Integer retryCount;
    private Integer timeout;
    private String routeStrategy;
    private Integer status;
    private String author;
    private LocalDateTime createTime;
}
```

#### 2.1.2 执行记录
```java
public class JobLog {
    private Long id;
    private Long jobId;
    private String handler;
    private String params;
    private Integer status;
    private LocalDateTime triggerTime;
    private String triggerCode;
    private String triggerMsg;
    private LocalDateTime handleTime;
    private String handleCode;
    private String handleMsg;
}
```

### 2.2 调度管理

#### 2.2.1 调度策略
```java
public enum ExecuteStrategy {
    SERIAL("串行执行"),
    PARALLEL("并行执行"),
    BROADCAST("广播执行"),
    SHARDING("分片执行");
    
    private String desc;
}
```

#### 2.2.2 路由策略
```java
public enum RouteStrategy {
    FIRST("第一个"),
    LAST("最后一个"),
    ROUND("轮询"),
    RANDOM("随机"),
    CONSISTENT_HASH("一致性哈希"),
    LEAST_FREQUENTLY_USED("最不经常使用"),
    LEAST_RECENTLY_USED("最近最久未使用"),
    FAILOVER("故障转移"),
    BUSYOVER("忙碌转移"),
    MANUAL("手动指定");
    
    private String desc;
}
```

### 2.3 任务编排

#### 2.3.1 DAG模型
```java
public class JobDag {
    private Long id;
    private String name;
    private String description;
    private List<JobNode> nodes;
    private List<JobEdge> edges;
    private String schedule;
    private Integer status;
}
```

#### 2.3.2 节点模型
```java
public class JobNode {
    private Long id;
    private String name;
    private String jobHandler;
    private String params;
    private Integer retryCount;
    private Integer timeout;
    private String condition;
    private String failStrategy;
}
```

### 2.4 监控告警

#### 2.4.1 监控指标
```java
public class JobMetrics {
    private Long jobId;
    private Integer totalCount;
    private Integer successCount;
    private Integer failCount;
    private Long avgDuration;
    private LocalDateTime lastExecuteTime;
    private String lastExecuteResult;
}
```

#### 2.4.2 告警规则
```java
public class JobAlertRule {
    private Long id;
    private Long jobId;
    private String metric;
    private String operator;
    private String threshold;
    private String contacts;
    private Boolean enabled;
}
```

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- XXL-JOB
- Quartz

### 3.2 存储方案
- PostgreSQL
- Redis

### 3.3 监控集成
- Prometheus
- Grafana

## 4. 数据模型

### 4.1 任务信息表
```sql
CREATE TABLE job_info (
    id bigserial PRIMARY KEY,
    name varchar(100) NOT NULL,
    description text,
    handler varchar(255) NOT NULL,
    params text,
    cron varchar(100) NOT NULL,
    strategy varchar(50) NOT NULL,
    retry_count integer NOT NULL DEFAULT 0,
    timeout integer NOT NULL DEFAULT 0,
    route_strategy varchar(50) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    author varchar(100),
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

### 4.2 任务日志表
```sql
CREATE TABLE job_log (
    id bigserial PRIMARY KEY,
    job_id bigint NOT NULL,
    handler varchar(255) NOT NULL,
    params text,
    status smallint NOT NULL,
    trigger_time timestamp NOT NULL,
    trigger_code varchar(50),
    trigger_msg text,
    handle_time timestamp,
    handle_code varchar(50),
    handle_msg text,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (job_id) REFERENCES job_info(id)
);
```

### 4.3 任务DAG表
```sql
CREATE TABLE job_dag (
    id bigserial PRIMARY KEY,
    name varchar(100) NOT NULL,
    description text,
    nodes jsonb NOT NULL,
    edges jsonb NOT NULL,
    schedule varchar(100),
    status smallint NOT NULL DEFAULT 0,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

## 5. 接口设计

### 5.1 任务接口
```java
@RestController
@RequestMapping("/api/v1/jobs")
public class JobController {
    @PostMapping
    public JobVO createJob(@Valid @RequestBody JobCreateDTO request);
    
    @PostMapping("/{id}/trigger")
    public void triggerJob(@PathVariable Long id, @Valid @RequestBody JobTriggerDTO request);
    
    @GetMapping("/{id}/logs")
    public Page<JobLogVO> getJobLogs(@PathVariable Long id, JobLogQueryDTO query, Pageable pageable);
}
```

### 5.2 DAG接口
```java
@RestController
@RequestMapping("/api/v1/dags")
public class DagController {
    @PostMapping
    public DagVO createDag(@Valid @RequestBody DagCreateDTO request);
    
    @PostMapping("/{id}/execute")
    public void executeDag(@PathVariable Long id);
    
    @GetMapping("/{id}/status")
    public DagStatusVO getDagStatus(@PathVariable Long id);
}
```

## 6. 任务执行

### 6.1 执行器
```java
@Component
public class JobExecutor {
    @XxlJob("demoJobHandler")
    public void execute(String param) throws Exception {
        // 执行任务
    }
}
```

### 6.2 分片处理
```java
@Component
public class ShardingJobExecutor {
    @XxlJob("shardingJobHandler")
    public void execute() throws Exception {
        ShardingContext context = XxlJobHelper.getShardingContext();
        int shardIndex = context.getShardIndex();
        int shardTotal = context.getShardTotal();
        
        // 分片处理
    }
}
```

## 7. 任务编排

### 7.1 DAG执行器
```java
@Service
public class DagExecutor {
    public void execute(JobDag dag) {
        // 1. 拓扑排序
        List<JobNode> sortedNodes = topologicalSort(dag);
        
        // 2. 按序执行
        for (JobNode node : sortedNodes) {
            executeNode(node);
        }
    }
}
```

### 7.2 条件判断
```java
@Service
public class ConditionEvaluator {
    public boolean evaluate(String condition, Map<String, Object> context) {
        // 评估条件
        return true;
    }
}
```

## 8. 监控设计

### 8.1 性能指标
```java
@Configuration
public class JobMetricsConfig {
    @Bean
    MeterBinder jobMetrics() {
        return registry -> {
            // 执行次数
            Counter.builder("job.executions")
                .tag("status", "success")
                .register(registry);
                
            // 执行时间
            Timer.builder("job.duration")
                .register(registry);
        };
    }
}
```

### 8.2 健康检查
```java
@Component
public class JobHealthIndicator extends AbstractHealthIndicator {
    @Override
    protected void doHealthCheck(Health.Builder builder) {
        // 检查任务执行器状态
    }
}
```

## 9. 部署配置

### 9.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-job
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-job
          image: cloud-job:latest
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

### 10.1 任务指标
- 任务执行次数
- 任务成功率
- 任务执行时长
- 任务积压数

### 10.2 系统指标
- 执行器负载
- 线程池状态
- 调度延迟
- 资源使用率

## 11. 测试策略

### 11.1 单元测试
- 任务执行测试
- 调度策略测试
- DAG执行测试
- 条件判断测试

### 11.2 集成测试
- 分布式调度测试
- 故障转移测试
- 并发执行测试
- 监控告警测试

## 12. 注意事项

### 12.1 任务设计
- 幂等性设计
- 超时控制
- 重试机制
- 任务分片

### 12.2 高可用设计
- 执行器集群
- 调度器高可用
- 故障转移
- 任务恢复

### 12.3 性能优化
- 批量处理
- 资源控制
- 并行调度
- 任务队列
