package com.cloudnative.auth.integration;

import com.cloudnative.auth.entity.AuthUser;
import com.cloudnative.auth.entity.OAuth2Client;
import com.cloudnative.auth.repository.AuthUserRepository;
import com.cloudnative.auth.repository.OAuth2ClientRepository;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.MediaType;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.test.context.support.WithMockUser;
import org.springframework.security.test.web.servlet.setup.SecurityMockMvcConfigurers;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.reactive.server.WebTestClient;
import org.springframework.test.web.servlet.client.MockMvcWebTestClient;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.util.UriComponentsBuilder;

import java.util.Base64;
import java.util.Map;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient
@ActiveProfiles("test")
class OAuth2AuthorizationTest {

    private WebTestClient webTestClient;

    @Autowired
    private AuthUserRepository authUserRepository;

    @Autowired
    private OAuth2ClientRepository oAuth2ClientRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private static final String CLIENT_ID = "test-client";
    private static final String CLIENT_SECRET = "secret";
    private static final String REDIRECT_URI = "http://127.0.0.1:8080/callback";
    private static final String USERNAME = "testuser";
    private static final String PASSWORD = "password";

    @Autowired
    public void setWebApplicationContext(final WebApplicationContext context) {
        webTestClient = MockMvcWebTestClient
                .bindToApplicationContext(context)
                .apply(SecurityMockMvcConfigurers.springSecurity())
                .build();
    }

    @BeforeEach
    void setUp() {
        // 清理测试数据
        oAuth2ClientRepository.deleteAll().block();
        authUserRepository.deleteAll().block();

        // 创建测试用户
        AuthUser user = new AuthUser();
        user.setUserId(1L);
        user.setUsername(USERNAME);
        user.setPassword(passwordEncoder.encode(PASSWORD));
        user.setStatus((short) 1);
        authUserRepository.save(user).block();

        // 创建OAuth2客户端
        OAuth2Client client = new OAuth2Client();
        client.setClientId(CLIENT_ID);
        client.setClientSecret(passwordEncoder.encode(CLIENT_SECRET));
        client.setClientName("Test Client");
        client.setRedirectUri(REDIRECT_URI);
        client.setScopes("read,write");
        client.setAuthorizedGrantTypes("authorization_code,refresh_token");
        client.setAccessTokenValidity(3600);
        client.setRefreshTokenValidity(7200);
        client.setAutoApprove(false);
        oAuth2ClientRepository.save(client).block();
    }

    @Test
    @WithMockUser(username = USERNAME)
    void testRefreshTokenFlow() {
        String basicAuth = Base64.getEncoder().encodeToString((CLIENT_ID + ":" + CLIENT_SECRET).getBytes());

        // 获取授权码
        String authorizationUri = UriComponentsBuilder.fromPath("/oauth2/authorize")
                .queryParam("response_type", "code")
                .queryParam("client_id", CLIENT_ID)
                .queryParam("redirect_uri", REDIRECT_URI)
                .queryParam("scope", "read write")
                .queryParam("state", "test-state")
                .build()
                .toUriString();

        String location = webTestClient
                .get()
                .uri(authorizationUri)
                .exchange()
                .expectStatus().is3xxRedirection()
                .returnResult(Void.class)
                .getResponseHeaders()
                .getFirst("Location");

        // 从重定向URL中提取授权码
        Assertions.assertNotNull(location, "Location header should not be null");
        String code = UriComponentsBuilder.fromUriString(location).build()
                .getQueryParams().getFirst("code");
        Assertions.assertNotNull(code, "Authorization code should not be null");

        // 使用授权码获取访问令牌和刷新令牌
        Map<String, String> tokenResponse = webTestClient
                .post()
                .uri("/oauth2/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .header("Authorization", "Basic " + basicAuth)
                .bodyValue("grant_type=authorization_code&code=" + code + "&redirect_uri=" + REDIRECT_URI)
                .exchange()
                .expectStatus().isOk()
                .expectBody(new ParameterizedTypeReference<Map<String, String>>() {
                })
                .returnResult()
                .getResponseBody();

        Assertions.assertNotNull(tokenResponse, "Token response should not be null");
        String refreshToken = tokenResponse.get("refresh_token");
        Assertions.assertNotNull(refreshToken, "Refresh token should not be null");

        // 使用刷新令牌获取新的访问令牌
        webTestClient
                .post()
                .uri("/oauth2/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .header("Authorization", "Basic " + basicAuth)
                .bodyValue("grant_type=refresh_token&refresh_token=" + refreshToken)
                .exchange()
                .expectStatus().isOk()
                .expectBody()
                .jsonPath("$.access_token").exists()
                .jsonPath("$.token_type").isEqualTo("Bearer")
                .jsonPath("$.expires_in").isNumber()
                .jsonPath("$.refresh_token").exists();
    }

    @Test
    void testInvalidClient() {
        String invalidBasicAuth = Base64.getEncoder().encodeToString(("invalid-client:invalid-secret").getBytes());

        webTestClient
                .post()
                .uri("/oauth2/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .header("Authorization", "Basic " + invalidBasicAuth)
                .bodyValue("grant_type=refresh_token&refresh_token=invalid-token")
                .exchange()
                .expectStatus().isUnauthorized();
    }

    @Test
    void testInvalidGrant() {
        String basicAuth = Base64.getEncoder().encodeToString((CLIENT_ID + ":" + CLIENT_SECRET).getBytes());

        webTestClient
                .post()
                .uri("/oauth2/token")
                .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                .header("Authorization", "Basic " + basicAuth)
                .bodyValue("grant_type=refresh_token&refresh_token=invalid-token")
                .exchange()
                .expectStatus().isBadRequest();
    }
}
