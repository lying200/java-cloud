package com.cloudnative.auth.vo;

import lombok.Data;

import java.time.LocalDateTime;
import java.util.List;

@Data
public class OAuth2ClientVO {
    private Long id;
    private String clientId;
    private String clientSecret;
    private String clientName;
    private String redirectUri;
    private List<String> scopes;
    private List<String> authorizedGrantTypes;
    private Integer accessTokenValidity;
    private Integer refreshTokenValidity;
    private String additionalInformation;
    private Boolean autoApprove;
    private Short status;
    private Boolean deleted;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;
    private Integer version;
}
