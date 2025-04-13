package com.cloudapp.user.controller;

import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SsoTestController {

    @GetMapping("/")
    public String home() {
        return "home";
    }

    @GetMapping("/login")
    public String login() {
        return "login";
    }

    @GetMapping("/secured")
    public String secured(@AuthenticationPrincipal OAuth2User principal, Model model) {
        model.addAttribute("username", principal.getAttribute("name"));
        model.addAttribute("attributes", principal.getAttributes());
        return "secured";
    }
}