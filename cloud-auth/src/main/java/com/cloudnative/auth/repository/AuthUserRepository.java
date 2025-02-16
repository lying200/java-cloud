package com.cloudnative.auth.repository;

import com.cloudnative.auth.entity.AuthUser;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Mono;

public interface AuthUserRepository extends ReactiveCrudRepository<AuthUser, Long> {
    
    @Query("SELECT * FROM auth_users WHERE username = :username AND deleted = false")
    Mono<AuthUser> findByUsername(String username);
    
    @Query("SELECT * FROM auth_users WHERE username = :username AND status = 1 AND deleted = false")
    Mono<AuthUser> findActiveByUsername(String username);
    
    @Query("SELECT * FROM auth_users WHERE user_id = :userId AND deleted = false")
    Mono<AuthUser> findByUserId(Long userId);
}
