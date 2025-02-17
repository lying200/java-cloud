package com.cloudnative.auth.repository;

import com.cloudnative.auth.entity.OAuth2Client;
import org.springframework.data.domain.Pageable;
import org.springframework.data.r2dbc.repository.Query;
import org.springframework.data.repository.reactive.ReactiveCrudRepository;
import reactor.core.publisher.Flux;
import reactor.core.publisher.Mono;

public interface OAuth2ClientRepository extends ReactiveCrudRepository<OAuth2Client, Long> {
    
    @Query("SELECT * FROM oauth2_clients WHERE client_id = :clientId AND deleted = false")
    Mono<OAuth2Client> findByClientId(String clientId);
    
    @Query("SELECT * FROM oauth2_clients WHERE client_id = :clientId AND status = 1 AND deleted = false")
    Mono<OAuth2Client> findActiveByClientId(String clientId);
    
    Flux<OAuth2Client> findAllByDeletedFalse(Pageable pageable);
    Mono<Long> countByDeletedFalse();
}
