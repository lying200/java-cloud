package com.cloudnative.auth.entity;

import lombok.Data;
import org.springframework.data.annotation.Id;
import org.springframework.data.annotation.Version;
import org.springframework.data.relational.core.mapping.Table;
import java.time.LocalDateTime;

@Data
@Table("oauth2_clients")
public class OAuth2Client {
    @Id
    private Long id;
    private String clientId;
    private String clientSecret;
    private String clientName;
    private String redirectUri;
    private String scopes;
    private String authorizedGrantTypes;
    private Integer accessTokenValidity;
    private Integer refreshTokenValidity;
    private String additionalInformation;
    private Boolean autoApprove;
    private Short status;
    private Boolean deleted;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    @Version
    private Integer version;
}
