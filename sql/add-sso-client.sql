-- 添加SSO测试客户端
INSERT INTO oauth2_clients (client_id, client_secret, client_name, redirect_uri, scopes, authorized_grant_types,
                          access_token_validity, refresh_token_validity, auto_approve, status)
VALUES
('cloud-user-client', '{bcrypt}$2a$10$8KvHGPDO.xBu/dWxHqIYpehEFa5OKqOXOWY2ZIEfnhQfZWIUPYjfO', 'Cloud User SSO Client',
 'http://localhost:8081/login/oauth2/code/cloud-user-client', 'openid,profile,read,write',
 'authorization_code,refresh_token', 3600, 7200, false, 1);

-- 注意：client_secret的值与现有客户端相同，实际值为 'secret'
-- 根据bootstrap.yml，cloud-auth在8082端口，我们假设cloud-user在8081端口
