package com.cloudnative.auth.service;

import com.cloudnative.auth.entity.OAuth2Client;
import com.cloudnative.auth.repository.OAuth2ClientRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClient;
import org.springframework.security.oauth2.server.authorization.client.RegisteredClientRepository;
import org.springframework.security.oauth2.core.AuthorizationGrantType;
import org.springframework.security.oauth2.core.ClientAuthenticationMethod;
import org.springframework.stereotype.Service;

import java.util.Arrays;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class OAuth2ClientService implements RegisteredClientRepository {

    private final OAuth2ClientRepository clientRepository;

    @Override
    public void save(RegisteredClient registeredClient) {
        throw new UnsupportedOperationException("Client registration is not supported");
    }

    @Override
    public RegisteredClient findById(String id) {
        return clientRepository.findById(Long.valueOf(id))
                .map(this::toRegisteredClient)
                .block();
    }

    @Override
    public RegisteredClient findByClientId(String clientId) {
        return clientRepository.findActiveByClientId(clientId)
                .map(this::toRegisteredClient)
                .block();
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
