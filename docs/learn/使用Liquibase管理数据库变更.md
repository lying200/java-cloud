# 使用Liquibase管理数据库变更

## 1. 参考

- [简要文档](https://pdai.tech/md/spring/springboot/springboot-x-mysql-liquibase.html)
- [SQL文件配置](https://docs.liquibase.com/change-types/sql-file.html#yaml_example)

## 2. 使用

### 2.1 添加依赖

添加 springboot liquibase 依赖(gradle)

```gradle
implementation 'org.liquibase:liquibase-core'
```

版本 spring.dependency-management 已限定

使用spring-boot-starter-data-r2dbc时，liquibase 需要配置url、username、password, 同时需添加 postgresql 依赖(如果使用
spring-data-jpa 则无需配置)

```gradle
implementation 'org.postgresql:postgresql'
```

### 2.2 配置

```yaml
spring:
  liquibase:
    enabled: true
    change-log: classpath:/db/changelog/db.changelog-master.yaml
    url: jdbc:postgresql://192.168.3.201:31432/cloud_auth
    user: devuser
    password: devpassword
```

当 spring 识别到依赖时，会自动处理，如果使用jpa, 则无需配置连接信息，spring 会根据 jpa 配置进行处理，参考
`LiquibaseAutoConfiguration` 和 `LiquibaseProperties`


