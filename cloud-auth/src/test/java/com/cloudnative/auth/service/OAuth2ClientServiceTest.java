package com.cloudnative.auth.service;

import com.cloudnative.auth.entity.OAuth2Client;
import com.cloudnative.auth.repository.OAuth2ClientRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.test.context.ActiveProfiles;
import reactor.test.StepVerifier;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
class OAuth2ClientServiceTest {

    @Autowired
    private OAuth2ClientRepository clientRepository;

    @Autowired
    private OAuth2ClientService clientService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        clientRepository.deleteAll().block();
    }

    @Test
    void createAndFindClient() {
        // 创建测试客户端
        OAuth2Client client = new OAuth2Client();
        client.setClientId("test-client");
        client.setClientSecret(passwordEncoder.encode("client-secret"));
        client.setClientName("Test Client");
        client.setRedirectUri("http://localhost:8080/callback");
        client.setScopes("read,write");
        client.setAuthorizedGrantTypes("authorization_code,refresh_token");
        client.setAccessTokenValidity(3600);
        client.setRefreshTokenValidity(7200);
        client.setAutoApprove(false);
        client.setStatus((short) 1);

        StepVerifier.create(clientRepository.save(client))
                .assertNext(savedClient -> {
                    assertThat(savedClient.getId()).isNotNull();
                    assertThat(savedClient.getClientId()).isEqualTo("test-client");
                })
                .verifyComplete();

        // 验证客户端查找
        RegisteredClient foundClient = clientService.findByClientId("test-client");
        assertThat(foundClient).isNotNull();
        assertThat(foundClient.getClientId()).isEqualTo("test-client");
        assertThat(foundClient.getClientName()).isEqualTo("Test Client");
    }

    @Test
    void findNonExistentClient() {
        RegisteredClient client = clientService.findByClientId("non-existent");
        assertThat(client).isNull();
    }
}
