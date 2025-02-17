package com.cloudnative.auth.service;

import com.cloudnative.auth.entity.AuthUser;
import com.cloudnative.auth.repository.AuthUserRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Mono;

@Service
@RequiredArgsConstructor
public class AuthUserService {

    private final AuthUserRepository authUserRepository;

    public Mono<UserDetails> findByUsername(String username) {
        return authUserRepository.findActiveByUsername(username)
                .map(user -> User.withUsername(user.getUsername())
                        .password(user.getPassword())
                        .roles(user.getRole())
                        .build());
    }

    public Mono<AuthUser> findByUserId(Long userId) {
        return authUserRepository.findByUserId(userId);
    }

    public Mono<AuthUser> createAuthUser(Long userId, String username, String encodedPassword) {
        AuthUser authUser = new AuthUser();
        authUser.setUserId(userId);
        authUser.setUsername(username);
        authUser.setPassword(encodedPassword);
        authUser.setStatus((short) 1);
        return authUserRepository.save(authUser);
    }

    public Mono<AuthUser> updateStatus(Long userId, Short status) {
        return authUserRepository.findByUserId(userId)
                .flatMap(user -> {
                    user.setStatus(status);
                    return authUserRepository.save(user);
                });
    }
}
