package com.cloudnative.auth.service;

import com.cloudnative.auth.entity.OAuth2Client;
import com.cloudnative.auth.repository.OAuth2ClientRepository;
import com.cloudnative.common.model.PageResult;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Mono;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OAuth2ClientService implements RegisteredClientRepository {

    private final OAuth2ClientRepository oAuth2ClientRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void save(RegisteredClient registeredClient) {
        throw new UnsupportedOperationException("Client registration is not supported");
    }

    @Override
    public RegisteredClient findById(String id) {
        return oAuth2ClientRepository.findById(Long.valueOf(id))
                .map(this::toRegisteredClient)
                .block();
    }

    @Override
    public RegisteredClient findByClientId(String clientId) {
        return oAuth2ClientRepository.findActiveByClientId(clientId)
                .map(this::toRegisteredClient)
                .block();
    }

    public Mono<PageResult<OAuth2Client>> findAll(long page, long size) {
        return oAuth2ClientRepository.findAllByDeletedFalse(PageRequest.of((int)(page - 1), (int)size))
                .collectList()
                .zipWith(oAuth2ClientRepository.countByDeletedFalse())
                .map(tuple -> PageResult.of(tuple.getT1(), tuple.getT2(), page, size));
    }

    public Mono<Long> count() {
        return oAuth2ClientRepository.countByDeletedFalse();
    }

    @Transactional
    public Mono<OAuth2Client> create(OAuth2Client client) {
        // 对客户端密钥进行加密
        client.setClientSecret(passwordEncoder.encode(client.getClientSecret()));
        client.setDeleted(false);
        client.setStatus((short) 1);
        return oAuth2ClientRepository.save(client);
    }

    @Transactional
    public Mono<OAuth2Client> update(OAuth2Client client) {
        return oAuth2ClientRepository.findById(client.getId())
                .flatMap(existingClient -> {
                    // 如果密码被修改，需要重新加密
                    if (!client.getClientSecret().equals(existingClient.getClientSecret())) {
                        client.setClientSecret(passwordEncoder.encode(client.getClientSecret()));
                    }
                    // 保持原有的一些字段不变
                    client.setDeleted(existingClient.getDeleted());
                    client.setStatus(existingClient.getStatus());
                    client.setCreateTime(existingClient.getCreateTime());
                    client.setVersion(existingClient.getVersion());
                    return oAuth2ClientRepository.save(client);
                });
    }

    @Transactional
    public Mono<Void> delete(Long id) {
        return oAuth2ClientRepository.findById(id)
                .flatMap(client -> {
                    client.setDeleted(true);
                    return oAuth2ClientRepository.save(client);
                })
                .then();
    }

    private RegisteredClient toRegisteredClient(OAuth2Client client) {
        Set<String> grantTypes = Arrays.stream(client.getAuthorizedGrantTypes().split(","))
                .collect(Collectors.toSet());

        Set<String> scopes = Arrays.stream(client.getScopes().split(","))
                .collect(Collectors.toSet());

        RegisteredClient.Builder builder = RegisteredClient.withId(String.valueOf(client.getId()))
                .clientId(client.getClientId())
                .clientSecret(client.getClientSecret())
                .clientName(client.getClientName());

        // Add grant types
        if (grantTypes.contains("authorization_code")) {
            builder.authorizationGrantType(AuthorizationGrantType.AUTHORIZATION_CODE);
        }
        if (grantTypes.contains("refresh_token")) {
            builder.authorizationGrantType(AuthorizationGrantType.REFRESH_TOKEN);
        }
        if (grantTypes.contains("client_credentials")) {
            builder.authorizationGrantType(AuthorizationGrantType.CLIENT_CREDENTIALS);
        }

        // Add scopes
        scopes.forEach(builder::scope);

        // Add redirect URIs
        Arrays.stream(client.getRedirectUri().split(","))
                .forEach(builder::redirectUri);

        // Add client authentication method
        builder.clientAuthenticationMethod(ClientAuthenticationMethod.CLIENT_SECRET_BASIC);

        return builder.build();
    }
}
