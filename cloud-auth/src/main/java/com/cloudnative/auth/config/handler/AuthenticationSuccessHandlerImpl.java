package com.cloudnative.auth.config.handler;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Component
public class AuthenticationSuccessHandlerImpl implements AuthenticationSuccessHandler {

    private static final String ROLE_ADMIN = "ROLE_ADMIN";
    private static final String ADMIN_PAGE = "/client-management.html";
    private static final String DEFAULT_PAGE = "/";

    @Override
    public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                      Authentication authentication) throws IOException {
        // 检查用户是否具有管理员角色
        boolean isAdmin = authentication.getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch(ROLE_ADMIN::equals);

        // 根据角色重定向到不同页面
        String targetUrl = isAdmin ? ADMIN_PAGE : DEFAULT_PAGE;
        response.sendRedirect(targetUrl);
    }
}
