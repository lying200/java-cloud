package com.cloudnative.auth.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Data
@Table("auth_users")
public class AuthUser {
    @Id
    private Long id;
    private Long userId;  // 关联cloud-user模块中的用户ID
    private String username;
    private String password;
    private Short status;  // 1-正常，2-禁用
    private Boolean deleted;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @Version
    private Integer version;
}
