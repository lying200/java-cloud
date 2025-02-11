# Cloud Message 模块设计文档

## 1. 模块概述

`cloud-message` 模块是消息中心服务，负责系统内所有的消息通知、站内信、短信、邮件等消息发送和管理功能。采用模板化设计，支持多渠道消息发送和消息管理。

## 2. 核心功能设计

### 2.1 消息管理

#### 2.1.1 消息模型
```java
public class Message {
    private Long id;
    private String title;
    private String content;
    private Integer type;
    private String sender;
    private String receiver;
    private Integer status;
    private LocalDateTime sendTime;
    private LocalDateTime readTime;
    private Map<String, String> extras;
}
```

#### 2.1.2 消息模板
```java
public class MessageTemplate {
    private Long id;
    private String code;
    private String name;
    private String content;
    private Integer type;
    private Map<String, String> params;
    private Boolean enabled;
    private LocalDateTime createTime;
}
```

### 2.2 通知管理

#### 2.2.1 通知模型
```java
public class Notification {
    private Long id;
    private String title;
    private String content;
    private Integer type;
    private Long userId;
    private Integer status;
    private String businessType;
    private String businessId;
    private LocalDateTime createTime;
}
```

#### 2.2.2 通知功能
- 站内信
- 系统通知
- 业务通知
- 通知设置

### 2.3 短信服务

#### 2.3.1 短信模型
```java
public class Sms {
    private Long id;
    private String mobile;
    private String content;
    private String templateCode;
    private Map<String, String> params;
    private String provider;
    private Integer status;
    private String sendResult;
    private LocalDateTime sendTime;
}
```

#### 2.3.2 短信功能
- 验证码
- 营销短信
- 通知短信
- 多供应商

### 2.4 邮件服务

#### 2.4.1 邮件模型
```java
public class Email {
    private Long id;
    private String subject;
    private String content;
    private String from;
    private String to;
    private String cc;
    private String bcc;
    private List<Attachment> attachments;
    private Integer status;
    private LocalDateTime sendTime;
}
```

#### 2.4.2 邮件功能
- HTML邮件
- 附件支持
- 模板邮件
- 批量发送

## 3. 技术选型

### 3.1 核心框架
- Spring Boot 3.3.x
- Spring Cloud 2024.x
- Spring Data JPA
- Spring Mail

### 3.2 消息中间件
- RabbitMQ
- Redis

### 3.3 存储方案
- PostgreSQL
- MinIO（附件存储）

## 4. 数据模型

### 4.1 消息表
```sql
CREATE TABLE messages (
    id bigserial PRIMARY KEY,
    title varchar(200) NOT NULL,
    content text NOT NULL,
    type smallint NOT NULL,
    sender varchar(100) NOT NULL,
    receiver varchar(100) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    send_time timestamp NOT NULL,
    read_time timestamp,
    extras jsonb,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

### 4.2 消息模板表
```sql
CREATE TABLE message_templates (
    id bigserial PRIMARY KEY,
    code varchar(100) NOT NULL UNIQUE,
    name varchar(100) NOT NULL,
    content text NOT NULL,
    type smallint NOT NULL,
    params jsonb,
    enabled boolean NOT NULL DEFAULT true,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

### 4.3 短信记录表
```sql
CREATE TABLE sms_records (
    id bigserial PRIMARY KEY,
    mobile varchar(20) NOT NULL,
    content text NOT NULL,
    template_code varchar(100),
    params jsonb,
    provider varchar(50) NOT NULL,
    status smallint NOT NULL DEFAULT 0,
    send_result text,
    send_time timestamp,
    create_time timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version integer NOT NULL DEFAULT 0
);
```

## 5. 接口设计

### 5.1 消息接口
```java
@RestController
@RequestMapping("/api/v1/messages")
public class MessageController {
    @PostMapping
    public MessageVO sendMessage(@Valid @RequestBody MessageSendDTO request);
    
    @GetMapping("/user")
    public Page<MessageVO> getUserMessages(MessageQueryDTO query, Pageable pageable);
    
    @PutMapping("/{id}/read")
    public void markAsRead(@PathVariable Long id);
}
```

### 5.2 短信接口
```java
@RestController
@RequestMapping("/api/v1/sms")
public class SmsController {
    @PostMapping("/code")
    public void sendVerificationCode(@Valid @RequestBody SmsCodeDTO request);
    
    @PostMapping("/batch")
    public BatchSendResultVO batchSendSms(@Valid @RequestBody SmsBatchSendDTO request);
}
```

## 6. 消息模板

### 6.1 模板定义
```java
@Service
public class TemplateService {
    public String processTemplate(String templateCode, Map<String, String> params) {
        Template template = getTemplate(templateCode);
        return template.process(params);
    }
}
```

### 6.2 变量替换
```java
public class TemplateEngine {
    public String replace(String content, Map<String, String> params) {
        StringSubstitutor substitutor = new StringSubstitutor(params);
        return substitutor.replace(content);
    }
}
```

## 7. 消息队列

### 7.1 消息生产者
```java
@Service
public class MessageProducer {
    @Autowired
    private RabbitTemplate rabbitTemplate;
    
    public void sendMessage(MessageEvent event) {
        rabbitTemplate.convertAndSend("message.exchange", "message.route", event);
    }
}
```

### 7.2 消息消费者
```java
@Service
public class MessageConsumer {
    @RabbitListener(queues = "message.queue")
    public void handleMessage(MessageEvent event) {
        // 处理消息
    }
}
```

## 8. 短信集成

### 8.1 短信接口
```java
public interface SmsProvider {
    SendResult send(String mobile, String content);
    SendResult sendTemplate(String mobile, String templateCode, Map<String, String> params);
    List<SendResult> batchSend(List<SmsBatchItem> items);
}
```

### 8.2 阿里云实现
```java
@Service
public class AliyunSmsProvider implements SmsProvider {
    @Override
    public SendResult send(String mobile, String content) {
        // 发送短信
    }
}
```

## 9. 邮件服务

### 9.1 邮件发送
```java
@Service
public class EmailService {
    @Autowired
    private JavaMailSender mailSender;
    
    public void sendHtmlMail(EmailDTO email) {
        MimeMessage message = mailSender.createMimeMessage();
        MimeMessageHelper helper = new MimeMessageHelper(message, true);
        helper.setTo(email.getTo());
        helper.setSubject(email.getSubject());
        helper.setText(email.getContent(), true);
        mailSender.send(message);
    }
}
```

### 9.2 附件处理
```java
@Service
public class AttachmentService {
    @Autowired
    private MinioClient minioClient;
    
    public String uploadAttachment(MultipartFile file) {
        // 上传附件
    }
}
```

## 10. 部署配置

### 10.1 Kubernetes配置
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cloud-message
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: cloud-message
          image: cloud-message:latest
          ports:
            - containerPort: 8080
```

### 10.2 资源配置
```yaml
resources:
  requests:
    memory: "512Mi"
    cpu: "500m"
  limits:
    memory: "1Gi"
    cpu: "1000m"
```

## 11. 监控指标

### 11.1 业务指标
- 消息发送量
- 发送成功率
- 消息阅读率
- 短信使用量

### 11.2 性能指标
- 发送延迟
- 队列积压量
- 处理速率
- 错误率

## 12. 测试策略

### 12.1 功能测试
- 消息发送测试
- 模板处理测试
- 短信集成测试
- 邮件发送测试

### 12.2 性能测试
- 批量发送测试
- 并发处理测试
- 队列处理测试

## 13. 注意事项

### 13.1 消息设计
- 幂等处理
- 重试机制
- 延时发送
- 消息追踪

### 13.2 安全考虑
- 短信防刷
- 敏感信息
- 发送频率
- 黑名单机制

### 13.3 性能优化
- 批量处理
- 异步发送
- 队列削峰
- 模板缓存
