package com.cloudnative.auth.controller;

import com.cloudnative.auth.entity.OAuth2Client;
import com.cloudnative.auth.service.OAuth2ClientService;
import com.cloudnative.auth.vo.OAuth2ClientVO;
import com.cloudnative.common.model.PageResult;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.BeanUtils;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;
import reactor.core.publisher.Mono;

import java.util.Arrays;
import java.util.Collections;

@RestController
@RequestMapping("/api/oauth2/clients")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")  // 只有管理员可以访问
public class OAuth2ClientController {

    private final OAuth2ClientService oAuth2ClientService;

    @GetMapping
    public Mono<PageResult<OAuth2ClientVO>> list(@RequestParam(defaultValue = "1") long page,
                                               @RequestParam(defaultValue = "10") long size) {
        return oAuth2ClientService.findAll(page, size)
                .map(pageResult -> {
                    PageResult<OAuth2ClientVO> voPageResult = new PageResult<>();
                    voPageResult.setPage(pageResult.getPage());
                    voPageResult.setSize(pageResult.getSize());
                    voPageResult.setTotal(pageResult.getTotal());
                    voPageResult.setRecords(pageResult.getRecords().stream()
                            .map(this::convertToVO)
                            .toList());
                    return voPageResult;
                });
    }

    @GetMapping("/count")
    public Mono<Long> count() {
        return oAuth2ClientService.count();
    }

    @PostMapping
    public Mono<OAuth2ClientVO> create(@RequestBody OAuth2ClientVO clientVO) {
        return oAuth2ClientService.create(convertToEntity(clientVO))
                .map(this::convertToVO);
    }

    @PutMapping("/{id}")
    public Mono<OAuth2ClientVO> update(@PathVariable Long id, @RequestBody OAuth2ClientVO clientVO) {
        clientVO.setId(id);
        return oAuth2ClientService.update(convertToEntity(clientVO))
                .map(this::convertToVO);
    }

    @DeleteMapping("/{id}")
    public Mono<Void> delete(@PathVariable Long id) {
        return oAuth2ClientService.delete(id);
    }

    private OAuth2ClientVO convertToVO(OAuth2Client entity) {
        OAuth2ClientVO vo = new OAuth2ClientVO();
        BeanUtils.copyProperties(entity, vo);
        vo.setScopes(entity.getScopes() != null ?
                Arrays.asList(entity.getScopes().split(",")) :
                Collections.emptyList());
        vo.setAuthorizedGrantTypes(entity.getAuthorizedGrantTypes() != null ?
                Arrays.asList(entity.getAuthorizedGrantTypes().split(",")) :
                Collections.emptyList());
        return vo;
    }

    private OAuth2Client convertToEntity(OAuth2ClientVO vo) {
        OAuth2Client entity = new OAuth2Client();
        BeanUtils.copyProperties(vo, entity);
        entity.setScopes(vo.getScopes() != null ?
                String.join(",", vo.getScopes()) :
                null);
        entity.setAuthorizedGrantTypes(vo.getAuthorizedGrantTypes() != null ?
                String.join(",", vo.getAuthorizedGrantTypes()) :
                null);
        return entity;
    }
}
