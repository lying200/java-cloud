-- 插入测试用户数据
INSERT INTO auth_users (user_id, username, password, status, role)
VALUES
(1, 'admin', '{bcrypt}$2a$10$3yAhAxJljfREMSysaCHzAu8uvdu1vH/qDVRru/GglU.oaUjcnBSKW', 1, 'ADMIN'),  -- 密码: password123
(2, 'test', '{bcrypt}$2a$10$3yAhAxJljfREMSysaCHzAu8uvdu1vH/qDVRru/GglU.oaUjcnBSKW', 1, 'USER');   -- 密码: password123

-- 插入测试客户端数据
INSERT INTO oauth2_clients (client_id, client_secret, client_name, redirect_uri, scopes, authorized_grant_types,
                            access_token_validity, refresh_token_validity, auto_approve, status)
VALUES
    ('cloud-user-client', '{bcrypt}$2a$10$b1NKscxBRWcTSArNJy01A.UBr6M4G8FCGcwRGUqVIjt9dNBKfRyFW', 'Cloud User SSO Client',
     'http://localhost:8082/login/oauth2/code/cloud-user-client', 'openid,profile,read,write',
     'authorization_code,refresh_token', 3600, 7200, false, 1);
