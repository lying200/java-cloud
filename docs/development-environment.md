# 开发环境搭建指南

## 1. 环境要求

### 1.1 基础环境
- Docker Desktop with Kubernetes
- JDK 21 LTS
- Gradle 9.x (使用Gradle Wrapper)
- Git
- IDE (推荐 IntelliJ IDEA)
- Kubernetes CLI (kubectl)
- Helm 3.x
- K9s (推荐的Kubernetes UI工具)
- Lens (可选的Kubernetes管理工具)

### 1.2 硬件要求
- CPU: 8核心以上
- 内存: 16GB以上 (推荐32GB)
- 磁盘: 256GB以上 SSD
- 网络: 良好的互联网连接

## 2. 基础设施服务

### 2.0 通用配置

```yaml
# common-secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: infrastructure-credentials
type: Opaque
data:
  postgresql-password: <base64-encoded-password>
  redis-password: <base64-encoded-password>
  rabbitmq-password: <base64-encoded-password>
  elasticsearch-password: <base64-encoded-password>
  grafana-password: <base64-encoded-password>
  minio-password: <base64-encoded-password>

---
apiVersion: v1
kind: ConfigMap
metadata:
  name: common-config
data:
  monitoring-enabled: "true"
  tracing-enabled: "true"
  metrics-enabled: "true"
```

### 2.1 PostgreSQL

```yaml
# postgresql-values.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-init-scripts
data:
  init.sql: |
    CREATE DATABASE cloud_user;
    CREATE DATABASE cloud_product;
    CREATE DATABASE cloud_order;
    CREATE DATABASE cloud_promotion;
    CREATE DATABASE cloud_auth;
    CREATE DATABASE cloud_message;
    CREATE DATABASE cloud_job;
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgresql
spec:
  serviceName: postgresql
  replicas: 2  # 高可用配置
  selector:
    matchLabels:
      app: postgresql
  template:
    metadata:
      labels:
        app: postgresql
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9187"
    spec:
      containers:
        - name: postgresql
          image: postgres:16.1
          ports:
            - containerPort: 5432
          env:
            - name: POSTGRES_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: postgresql-password
            - name: POSTGRES_HOST_AUTH_METHOD
              value: "scram-sha-256"
            - name: POSTGRES_SSL_MODE
              value: "on"
          volumeMounts:
            - name: postgresql-data
              mountPath: /var/lib/postgresql/data
            - name: init-scripts
              mountPath: /docker-entrypoint-initdb.d
            - name: postgresql-config
              mountPath: /etc/postgresql/postgresql.conf
              subPath: postgresql.conf
          resources:
            requests:
              memory: "2Gi"
              cpu: "1000m"
            limits:
              memory: "4Gi"
              cpu: "2000m"
          livenessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            exec:
              command:
                - pg_isready
                - -U
                - postgres
            initialDelaySeconds: 5
            periodSeconds: 5
        - name: postgres-exporter
          image: prometheuscommunity/postgres-exporter:v0.15.0
          ports:
            - containerPort: 9187
          env:
            - name: DATA_SOURCE_URI
              value: "localhost:5432/postgres?sslmode=disable"
            - name: DATA_SOURCE_USER
              value: "postgres"
            - name: DATA_SOURCE_PASS
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: postgresql-password
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
      volumes:
        - name: init-scripts
          configMap:
            name: postgresql-init-scripts
        - name: postgresql-config
          configMap:
            name: postgresql-config
  volumeClaimTemplates:
    - metadata:
        name: postgresql-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 20Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-config
data:
  postgresql.conf: |
    max_connections = 200
    shared_buffers = 1GB
    effective_cache_size = 3GB
    maintenance_work_mem = 256MB
    checkpoint_completion_target = 0.9
    wal_buffers = 16MB
    default_statistics_target = 100
    random_page_cost = 1.1
    effective_io_concurrency = 200
    work_mem = 5242kB
    min_wal_size = 1GB
    max_wal_size = 4GB
    max_worker_processes = 8
    max_parallel_workers_per_gather = 4
    max_parallel_workers = 8
    max_parallel_maintenance_workers = 4
    ssl = on
    ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
    ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
---
apiVersion: v1
kind: Service
metadata:
  name: postgresql
  labels:
    app: postgresql
spec:
  ports:
    - port: 5432
      name: postgresql
    - port: 9187
      name: metrics
  selector:
    app: postgresql
```

### 2.2 Redis Stack

```yaml
# redis-values.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: redis
spec:
  serviceName: redis
  replicas: 2  # 高可用配置
  selector:
    matchLabels:
      app: redis
  template:
    metadata:
      labels:
        app: redis
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9121"
    spec:
      containers:
        - name: redis
          image: redis/redis-stack:7.2.0
          ports:
            - containerPort: 6379
              name: redis
            - containerPort: 8001
              name: insight
          env:
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: redis-password
            - name: REDIS_TLS_MODE
              value: "yes"
            - name: REDIS_ACL_ENABLED
              value: "yes"
          args: ["--requirepass", "$(REDIS_PASSWORD)"]
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          volumeMounts:
            - name: redis-data
              mountPath: /data
            - name: redis-config
              mountPath: /redis-stack.conf
              subPath: redis-stack.conf
          livenessProbe:
            tcpSocket:
              port: redis
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            tcpSocket:
              port: redis
            initialDelaySeconds: 5
            periodSeconds: 5
        - name: redis-exporter
          image: oliver006/redis_exporter:v1.55.0
          ports:
            - containerPort: 9121
          env:
            - name: REDIS_ADDR
              value: "localhost:6379"
            - name: REDIS_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: redis-password
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "200m"
      volumes:
        - name: redis-config
          configMap:
            name: redis-config
  volumeClaimTemplates:
    - metadata:
        name: redis-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: redis-config
data:
  redis-stack.conf: |
    # Redis Stack配置
    port 6379
    bind 0.0.0.0
    protected-mode yes
    
    # 内存管理
    maxmemory 1gb
    maxmemory-policy allkeys-lru
    
    # 持久化
    save 900 1
    save 300 10
    save 60 10000
    
    # 复制
    repl-diskless-sync yes
    repl-diskless-sync-delay 5
    
    # 安全
    tls-port 6380
    tls-cert-file /tls/redis.crt
    tls-key-file /tls/redis.key
    tls-auth-clients yes
    
    # RedisJSON
    loadmodule /opt/redis-stack/lib/rejson.so
    
    # RediSearch
    loadmodule /opt/redis-stack/lib/redisearch.so
    
    # RedisTimeSeries
    loadmodule /opt/redis-stack/lib/redistimeseries.so
---
apiVersion: v1
kind: Service
metadata:
  name: redis
  labels:
    app: redis
spec:
  ports:
    - port: 6379
      name: redis
    - port: 8001
      name: insight
    - port: 9121
      name: metrics
  selector:
    app: redis
```

### 2.3 RabbitMQ

```yaml
# rabbitmq-values.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: rabbitmq
spec:
  serviceName: rabbitmq
  replicas: 2  # 高可用配置
  selector:
    matchLabels:
      app: rabbitmq
  template:
    metadata:
      labels:
        app: rabbitmq
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "15692"
    spec:
      containers:
        - name: rabbitmq
          image: rabbitmq:3.13-management
          ports:
            - containerPort: 5672
              name: amqp
            - containerPort: 15672
              name: management
            - containerPort: 15692
              name: metrics
          env:
            - name: RABBITMQ_DEFAULT_USER
              value: "admin"
            - name: RABBITMQ_DEFAULT_PASS
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: rabbitmq-password
            - name: RABBITMQ_ERLANG_COOKIE
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: rabbitmq-erlang-cookie
            - name: RABBITMQ_ENABLED_PLUGINS_FILE
              value: "/etc/rabbitmq/enabled_plugins"
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          volumeMounts:
            - name: rabbitmq-data
              mountPath: /var/lib/rabbitmq
            - name: rabbitmq-config
              mountPath: /etc/rabbitmq/rabbitmq.conf
              subPath: rabbitmq.conf
            - name: rabbitmq-plugins
              mountPath: /etc/rabbitmq/enabled_plugins
              subPath: enabled_plugins
          livenessProbe:
            exec:
              command: ["rabbitmq-diagnostics", "status"]
            initialDelaySeconds: 60
            periodSeconds: 60
            timeoutSeconds: 15
          readinessProbe:
            exec:
              command: ["rabbitmq-diagnostics", "check_port_connectivity"]
            initialDelaySeconds: 20
            periodSeconds: 60
            timeoutSeconds: 10
      volumes:
        - name: rabbitmq-config
          configMap:
            name: rabbitmq-config
        - name: rabbitmq-plugins
          configMap:
            name: rabbitmq-plugins
  volumeClaimTemplates:
    - metadata:
        name: rabbitmq-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rabbitmq-config
data:
  rabbitmq.conf: |
    # 网络和安全
    listeners.tcp.default = 5672
    management.tcp.port = 15672
    
    # 默认虚拟主机
    default_vhost = /
    
    # 资源限制
    vm_memory_high_watermark.relative = 0.7
    disk_free_limit.relative = 2.0
    
    # 集群配置
    cluster_formation.peer_discovery_backend = rabbit_peer_discovery_k8s
    cluster_formation.k8s.host = kubernetes.default.svc.cluster.local
    cluster_formation.k8s.address_type = hostname
    cluster_formation.k8s.service_name = rabbitmq
    cluster_formation.k8s.hostname_suffix = .rabbitmq.default.svc.cluster.local
    
    # 消息持久化
    queue_master_locator = min-masters
    
    # 安全设置
    ssl_options.verify = verify_peer
    ssl_options.fail_if_no_peer_cert = false
    
    # 监控和指标
    prometheus.return_per_object_metrics = true
    
    # 连接和通道限制
    channel_max = 2047
    
    # 心跳设置
    heartbeat = 60
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: rabbitmq-plugins
data:
  enabled_plugins: |
    [
      rabbitmq_management,
      rabbitmq_peer_discovery_k8s,
      rabbitmq_prometheus,
      rabbitmq_federation,
      rabbitmq_federation_management,
      rabbitmq_shovel,
      rabbitmq_shovel_management
    ].
---
apiVersion: v1
kind: Service
metadata:
  name: rabbitmq
  labels:
    app: rabbitmq
spec:
  ports:
    - port: 5672
      name: amqp
    - port: 15672
      name: management
    - port: 15692
      name: metrics
  selector:
    app: rabbitmq
```

### 2.4 Elasticsearch

```yaml
# elasticsearch-values.yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: elasticsearch
spec:
  serviceName: elasticsearch
  replicas: 1
  selector:
    matchLabels:
      app: elasticsearch
  template:
    metadata:
      labels:
        app: elasticsearch
    spec:
      containers:
        - name: elasticsearch
          image: elasticsearch:8.12.0
          ports:
            - containerPort: 9200
            - containerPort: 9300
          env:
            - name: discovery.type
              value: single-node
            - name: ES_JAVA_OPTS
              value: "-Xms512m -Xmx512m"
            - name: xpack.security.enabled
              value: "true"
            - name: xpack.security.authc.realms.native.native1.order
              value: "1"
            - name: ELASTIC_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: elasticsearch-password
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          volumeMounts:
            - name: elasticsearch-data
              mountPath: /usr/share/elasticsearch/data
  volumeClaimTemplates:
    - metadata:
        name: elasticsearch-data
      spec:
        accessModes: [ "ReadWriteOnce" ]
        resources:
          requests:
            storage: 10Gi
---
apiVersion: v1
kind: Service
metadata:
  name: elasticsearch
spec:
  ports:
    - name: rest
      port: 9200
    - name: inter-node
      port: 9300
  selector:
    app: elasticsearch
```

### 2.5 MinIO

```yaml
# minio-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: minio
spec:
  selector:
    matchLabels:
      app: minio
  template:
    metadata:
      labels:
        app: minio
    spec:
      containers:
        - name: minio
          image: minio/minio:latest
          args:
            - server
            - /data
            - --console-address
            - ":9001"
          env:
            - name: MINIO_ROOT_USER
              value: "admin"
            - name: MINIO_ROOT_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: minio-password
          ports:
            - containerPort: 9000
            - containerPort: 9001
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          volumeMounts:
            - name: minio-data
              mountPath: /data
      volumes:
        - name: minio-data
          persistentVolumeClaim:
            claimName: minio-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: minio
spec:
  ports:
    - name: api
      port: 9000
    - name: console
      port: 9001
  selector:
    app: minio
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: minio-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

### 2.6 监控组件

#### 2.6.1 Prometheus

```yaml
# prometheus-values.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
data:
  prometheus.yml: |
    global:
      scrape_interval: 15s
      evaluation_interval: 15s
      
    scrape_configs:
      - job_name: 'kubernetes-service-endpoints'
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
            action: keep
            regex: true
          - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
            action: replace
            target_label: __metrics_path__
            regex: (.+)
          - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
            action: replace
            target_label: __address__
            regex: ([^:]+)(?::\d+)?;(\d+)
            replacement: $1:$2
            
      - job_name: 'postgresql'
        static_configs:
          - targets: ['postgresql:9187']
            
      - job_name: 'redis'
        static_configs:
          - targets: ['redis:9121']
            
      - job_name: 'rabbitmq'
        static_configs:
          - targets: ['rabbitmq:15692']
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  replicas: 1
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:v2.45.0
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus"
            - "--storage.tsdb.retention.time=15d"
            - "--web.enable-lifecycle"
          ports:
            - containerPort: 9090
          volumeMounts:
            - name: prometheus-config
              mountPath: /etc/prometheus/
            - name: prometheus-data
              mountPath: /prometheus
          resources:
            requests:
              memory: "1Gi"
              cpu: "500m"
            limits:
              memory: "2Gi"
              cpu: "1000m"
          livenessProbe:
            httpGet:
              path: /-/healthy
              port: 9090
            initialDelaySeconds: 30
            periodSeconds: 15
          readinessProbe:
            httpGet:
              path: /-/ready
              port: 9090
            initialDelaySeconds: 30
            periodSeconds: 15
      volumes:
        - name: prometheus-config
          configMap:
            name: prometheus-config
        - name: prometheus-data
          persistentVolumeClaim:
            claimName: prometheus-data
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  ports:
    - port: 9090
      targetPort: 9090
  selector:
    app: prometheus
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi

#### 2.6.2 Grafana

```yaml
# grafana-values.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-datasources
data:
  prometheus.yaml: |
    apiVersion: 1
    datasources:
      - name: Prometheus
        type: prometheus
        url: http://prometheus:9090
        access: proxy
        isDefault: true
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  replicas: 1
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:10.2.0
          ports:
            - containerPort: 3000
          env:
            - name: GF_SECURITY_ADMIN_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: infrastructure-credentials
                  key: grafana-password
            - name: GF_INSTALL_PLUGINS
              value: "grafana-piechart-panel,grafana-worldmap-panel"
          volumeMounts:
            - name: grafana-data
              mountPath: /var/lib/grafana
            - name: grafana-datasources
              mountPath: /etc/grafana/provisioning/datasources
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 60
            timeoutSeconds: 30
            failureThreshold: 10
          readinessProbe:
            httpGet:
              path: /api/health
              port: 3000
            initialDelaySeconds: 60
            timeoutSeconds: 30
            failureThreshold: 10
      volumes:
        - name: grafana-data
          persistentVolumeClaim:
            claimName: grafana-data
        - name: grafana-datasources
          configMap:
            name: grafana-datasources
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  ports:
    - port: 3000
  selector:
    app: grafana
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: grafana-data
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```

#### 2.6.3 OpenTelemetry Collector

```yaml
# otel-collector-values.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: otel-collector-config
data:
  config.yaml: |
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
            
    processors:
      batch:
        timeout: 1s
        send_batch_size: 1024
      
      memory_limiter:
        check_interval: 1s
        limit_mib: 400
        
    exporters:
      prometheus:
        endpoint: 0.0.0.0:8889
        namespace: otel
        
      logging:
        loglevel: debug
        
    extensions:
      health_check:
        endpoint: 0.0.0.0:13133
      
      pprof:
        endpoint: 0.0.0.0:1777
      
      zpages:
        endpoint: 0.0.0.0:55679
        
    service:
      extensions: [health_check, pprof, zpages]
      pipelines:
        traces:
          receivers: [otlp]
          processors: [memory_limiter, batch]
          exporters: [logging]
        metrics:
          receivers: [otlp]
          processors: [memory_limiter, batch]
          exporters: [prometheus, logging]
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: otel-collector
spec:
  replicas: 1
  selector:
    matchLabels:
      app: otel-collector
  template:
    metadata:
      labels:
        app: otel-collector
    spec:
      containers:
        - name: otel-collector
          image: otel/opentelemetry-collector:0.90.0
          args:
            - "--config=/etc/otel/config.yaml"
          ports:
            - containerPort: 4317  # OTLP gRPC
            - containerPort: 4318  # OTLP HTTP
            - containerPort: 8889  # Prometheus exporter
            - containerPort: 13133 # health_check
            - containerPort: 1777  # pprof extension
            - containerPort: 55679 # zpages extension
          volumeMounts:
            - name: otel-collector-config
              mountPath: /etc/otel/config.yaml
              subPath: config.yaml
          resources:
            requests:
              memory: "256Mi"
              cpu: "200m"
            limits:
              memory: "512Mi"
              cpu: "500m"
          livenessProbe:
            httpGet:
              path: /
              port: 13133
            initialDelaySeconds: 5
          readinessProbe:
            httpGet:
              path: /
              port: 13133
            initialDelaySeconds: 5
      volumes:
        - name: otel-collector-config
          configMap:
            name: otel-collector-config
---
apiVersion: v1
kind: Service
metadata:
  name: otel-collector
spec:
  ports:
    - name: otlp-grpc
      port: 4317
      targetPort: 4317
    - name: otlp-http
      port: 4318
      targetPort: 4318
    - name: prometheus
      port: 8889
      targetPort: 8889
  selector:
    app: otel-collector
```

## 3. 监控服务

### 3.1 Prometheus

```yaml
# prometheus-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: prometheus
spec:
  selector:
    matchLabels:
      app: prometheus
  template:
    metadata:
      labels:
        app: prometheus
    spec:
      containers:
        - name: prometheus
          image: prom/prometheus:v2.45.0
          args:
            - "--config.file=/etc/prometheus/prometheus.yml"
            - "--storage.tsdb.path=/prometheus"
          ports:
            - containerPort: 9090
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
          volumeMounts:
            - name: prometheus-config
              mountPath: /etc/prometheus
            - name: prometheus-data
              mountPath: /prometheus
      volumes:
        - name: prometheus-config
          configMap:
            name: prometheus-config
        - name: prometheus-data
          persistentVolumeClaim:
            claimName: prometheus-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: prometheus
spec:
  ports:
    - port: 9090
  selector:
    app: prometheus
```

### 3.2 Grafana

```yaml
# grafana-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  selector:
    matchLabels:
      app: grafana
  template:
    metadata:
      labels:
        app: grafana
    spec:
      containers:
        - name: grafana
          image: grafana/grafana:10.2.0
          ports:
            - containerPort: 3000
          env:
            - name: GF_SECURITY_ADMIN_PASSWORD
              value: "admin"
          resources:
            requests:
              memory: "256Mi"
              cpu: "100m"
            limits:
              memory: "512Mi"
              cpu: "200m"
          volumeMounts:
            - name: grafana-data
              mountPath: /var/lib/grafana
      volumes:
        - name: grafana-data
          persistentVolumeClaim:
            claimName: grafana-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: grafana
spec:
  ports:
    - port: 3000
  selector:
    app: grafana
```

### 3.3 Jaeger

```yaml
# jaeger-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: jaeger
spec:
  selector:
    matchLabels:
      app: jaeger
  template:
    metadata:
      labels:
        app: jaeger
    spec:
      containers:
        - name: jaeger
          image: jaegertracing/all-in-one:1.50
          ports:
            - containerPort: 16686
            - containerPort: 14250
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: jaeger
spec:
  ports:
    - name: query-http
      port: 16686
    - name: collector-grpc
      port: 14250
  selector:
    app: jaeger
```

## 4. 应用服务

### 4.1 配置中心

```yaml
# config-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-config
spec:
  selector:
    matchLabels:
      app: cloud-config
  template:
    metadata:
      labels:
        app: cloud-config
    spec:
      containers:
        - name: cloud-config
          image: cloud-config:latest
          ports:
            - containerPort: 8888
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "dev"
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-config
spec:
  ports:
    - port: 8888
  selector:
    app: cloud-config
```

### 4.2 网关服务

```yaml
# gateway-values.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-gateway
spec:
  selector:
    matchLabels:
      app: cloud-gateway
  template:
    metadata:
      labels:
        app: cloud-gateway
    spec:
      containers:
        - name: cloud-gateway
          image: cloud-gateway:latest
          ports:
            - containerPort: 8080
          env:
            - name: SPRING_PROFILES_ACTIVE
              value: "dev"
          resources:
            requests:
              memory: "512Mi"
              cpu: "200m"
            limits:
              memory: "1Gi"
              cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: cloud-gateway
spec:
  type: NodePort
  ports:
    - port: 8080
      nodePort: 30080
  selector:
    app: cloud-gateway
```

## 5. 环境搭建步骤

### 5.1 安装基础工具
```bash
# 安装 kubectl
choco install kubernetes-cli

# 安装 helm
choco install kubernetes-helm
```

### 5.2 创建命名空间
```bash
kubectl create namespace java-cloud-dev
```

### 5.3 部署基础设施
```bash
# 部署 PostgreSQL
kubectl apply -f postgresql-values.yaml -n java-cloud-dev

# 部署 Redis
kubectl apply -f redis-values.yaml -n java-cloud-dev

# 部署 RabbitMQ
kubectl apply -f rabbitmq-values.yaml -n java-cloud-dev

# 部署 Elasticsearch
kubectl apply -f elasticsearch-values.yaml -n java-cloud-dev

# 部署 MinIO
kubectl apply -f minio-values.yaml -n java-cloud-dev
```

### 5.4 部署监控服务
```bash
# 部署 Prometheus
kubectl apply -f prometheus-values.yaml -n java-cloud-dev

# 部署 Grafana
kubectl apply -f grafana-values.yaml -n java-cloud-dev

# 部署 Jaeger
kubectl apply -f jaeger-values.yaml -n java-cloud-dev
```

### 5.5 部署应用服务
```bash
# 部署配置中心
kubectl apply -f config-values.yaml -n java-cloud-dev

# 部署网关服务
kubectl apply -f gateway-values.yaml -n java-cloud-dev
```

### 5.6 验证部署
```bash
# 查看所有Pod状态
kubectl get pods -n java-cloud-dev

# 查看所有Service
kubectl get svc -n java-cloud-dev

# 查看日志
kubectl logs -f <pod-name> -n java-cloud-dev
```

## 6. 开发工具配置

### 6.1 IDEA 配置
- 安装 Kubernetes 插件
- 安装 Spring Boot 插件
- 配置 JDK 21
- 配置 Gradle 设置

### 6.2 Docker 配置
```yaml
# ~/.docker/config.json
{
  "insecure-registries": ["localhost:5000"]
}
```

### 6.3 Gradle 配置
```groovy
// build.gradle
buildscript {
    repositories {
        mavenCentral()
    }
    dependencies {
        classpath 'com.google.cloud.tools:jib-maven-plugin:3.3.1'
    }
}
```

## 7. 注意事项

### 7.1 资源配置
- 根据实际机器配置调整资源限制
- 开发环境可以适当降低资源需求
- 注意持久化存储的容量配置

### 7.2 网络配置
- 确保 Kubernetes 集群网络正常
- 配置正确的 Service 端口映射
- 注意服务间的网络策略

### 7.3 安全配置
- 修改默认密码
- 配置适当的访问控制
- 注意敏感信息的保护

### 7.4 监控配置
- 配置合适的监控指标
- 设置告警规则
- 保留足够的日志空间

## 8. 开发流程

### 8.1 分支管理
- main: 主分支，保护分支
- develop: 开发分支
- feature/*: 功能分支
- bugfix/*: 缺陷修复分支
- release/*: 发布分支
- hotfix/*: 紧急修复分支

### 8.2 代码审查流程
1. 创建功能分支
2. 开发并提交代码
3. 运行本地测试
4. 创建Pull Request
5. 代码审查
6. CI/CD检查
7. 合并代码

### 8.3 发布流程
1. 从develop创建release分支
2. 版本号更新
3. 运行测试套件
4. 生成变更日志
5. 代码审查
6. 合并到main分支
7. 打标签发布
8. 合并回develop分支

## 9. 测试策略

### 9.1 测试金字塔
1. 单元测试 (70%)
2. 集成测试 (20%)
3. 端到端测试 (10%)

### 9.2 测试类型
- 单元测试：JUnit 5
- 集成测试：TestContainers
- 契约测试：Spring Cloud Contract
- 性能测试：JMeter/Gatling
- 安全测试：OWASP ZAP

### 9.3 测试覆盖率要求
- 分支覆盖率：>80%
- 行覆盖率：>85%
- 方法覆盖率：>90%

## 10. 安全实践

### 10.1 安全配置清单
- 使用HTTPS/TLS
- 启用CSRF保护
- 实施速率限制
- 配置安全头部
- 使用安全的依赖版本
- 实施访问控制
- 加密敏感数据
- 安全审计日志

### 10.2 密钥管理
- 使用Kubernetes Secrets
- 实施密钥轮换
- 加密配置文件
- 使用环境变量

### 10.3 漏洞扫描
- 依赖检查
- 容器扫描
- 代码扫描
- 渗透测试

## 11. 性能优化

### 11.1 应用层
- 使用缓存
- 异步处理
- 连接池优化
- JVM调优

### 11.2 数据库层
- 索引优化
- 查询优化
- 分库分表
- 读写分离

### 11.3 系统层
- 资源限制
- 负载均衡
- 自动扩缩容
- CDN加速

## 12. 故障排除

### 12.1 日志收集
- 应用日志
- 系统日志
- 审计日志
- 性能指标

### 12.2 监控告警
- 服务健康检查
- 资源使用率
- 业务指标
- 安全事件

### 12.3 问题定位
- 日志分析
- 链路追踪
- 性能分析
- 堆转储分析

## 13. 部署策略

### 13.1 环境定义
- 开发环境
- 测试环境
- 预生产环境
- 生产环境

### 13.2 部署方式
- 蓝绿部署
- 金丝雀发布
- 滚动更新
- A/B测试

### 13.3 回滚策略
- 版本回滚
- 数据回滚
- 配置回滚
- 应急预案

## 14. 维护计划

### 14.1 定期维护
- 依赖更新
- 安全补丁
- 性能优化
- 容量规划

### 14.2 监控维护
- 指标监控
- 告警规则
- 日志轮转
- 备份恢复

### 14.3 文档维护
- 架构文档
- API文档
- 运维文档
- 变更记录
