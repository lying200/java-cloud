-- 插入测试用户数据
INSERT INTO auth_users (user_id, username, password, status)
VALUES
(1, 'admin', '{bcrypt}$2a$10$3yAhAxJljfREMSysaCHzAu8uvdu1vH/qDVRru/GglU.oaUjcnBSKW', 1),  -- 密码: password123
(2, 'test', '{bcrypt}$2a$10$3yAhAxJljfREMSysaCHzAu8uvdu1vH/qDVRru/GglU.oaUjcnBSKW', 1);   -- 密码: password123

-- 插入测试客户端数据
INSERT INTO oauth2_clients (client_id, client_secret, client_name, redirect_uri, scopes, authorized_grant_types,
                          access_token_validity, refresh_token_validity, auto_approve, status)
VALUES
('web-client', '{bcrypt}$2a$10$8KvHGPDO.xBu/dWxHqIYpehEFa5OKqOXOWY2ZIEfnhQfZWIUPYjfO', 'Web Client',
 'http://localhost:8080/login/oauth2/code/web-client', 'openid,profile,read,write',
 'authorization_code,refresh_token', 3600, 7200, false, 1),
('mobile-client', '{bcrypt}$2a$10$8KvHGPDO.xBu/dWxHqIYpehEFa5OKqOXOWY2ZIEfnhQfZWIUPYjfO', 'Mobile Client',
 'com.cloudnative.mobile://oauth2/callback', 'openid,profile,read,write',
 'authorization_code,refresh_token', 3600, 7200, false, 1);
