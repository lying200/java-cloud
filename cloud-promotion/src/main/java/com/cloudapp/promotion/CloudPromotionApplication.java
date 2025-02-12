package com.cloudapp.promotion;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

@SpringBootApplication
@EnableDiscoveryClient
public class CloudPromotionApplication {
    public static void main(String[] args) {
        SpringApplication.run(CloudPromotionApplication.class, args);
    }
}
