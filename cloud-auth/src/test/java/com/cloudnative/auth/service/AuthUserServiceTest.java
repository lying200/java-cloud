package com.cloudnative.auth.service;

import com.cloudnative.auth.entity.AuthUser;
import com.cloudnative.auth.repository.AuthUserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.test.context.ActiveProfiles;
import reactor.core.publisher.Mono;
import reactor.test.StepVerifier;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest
@ActiveProfiles("test")
class AuthUserServiceTest {

    @Autowired
    private AuthUserService authUserService;

    @Autowired
    private AuthUserRepository authUserRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @BeforeEach
    void setUp() {
        // 清理测试数据
        authUserRepository.deleteAll().block();
    }

    @Test
    void createAndFindUser() {
        // 创建测试用户
        Long userId = 1L;
        String username = "testuser";
        String password = "password123";
        String encodedPassword = passwordEncoder.encode(password);

        Mono<AuthUser> createResult = authUserService.createAuthUser(userId, username, encodedPassword);

        StepVerifier.create(createResult)
                .assertNext(user -> {
                    assertThat(user.getUserId()).isEqualTo(userId);
                    assertThat(user.getUsername()).isEqualTo(username);
                    assertThat(user.getPassword()).isEqualTo(encodedPassword);
                    assertThat(user.getStatus()).isEqualTo((short) 1);
                })
                .verifyComplete();

        // 验证用户查找
        StepVerifier.create(authUserService.findByUsername(username))
                .assertNext(userDetails -> {
                    assertThat(userDetails.getUsername()).isEqualTo(username);
                    assertThat(passwordEncoder.matches(password, userDetails.getPassword())).isTrue();
                })
                .verifyComplete();
    }

    @Test
    void updateUserStatus() {
        // 创建测试用户
        Long userId = 2L;
        String username = "statususer";
        String encodedPassword = passwordEncoder.encode("password123");

        AuthUser user = authUserService.createAuthUser(userId, username, encodedPassword).block();
        assertThat(user).isNotNull();

        // 更新状态为禁用
        StepVerifier.create(authUserService.updateStatus(userId, (short) 2))
                .assertNext(updatedUser -> {
                    assertThat(updatedUser.getStatus()).isEqualTo((short) 2);
                })
                .verifyComplete();

        // 验证禁用用户无法查找
        StepVerifier.create(authUserService.findByUsername(username))
                .verifyComplete();
    }
}
