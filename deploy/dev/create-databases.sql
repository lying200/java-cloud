-- 创建所有微服务数据库

-- 认证服务数据库
DROP DATABASE IF EXISTS cloud_auth;
CREATE DATABASE cloud_auth WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 用户服务数据库
DROP DATABASE IF EXISTS cloud_user;
CREATE DATABASE cloud_user WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 订单服务数据库
DROP DATABASE IF EXISTS cloud_order;
CREATE DATABASE cloud_order WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 商品服务数据库
DROP DATABASE IF EXISTS cloud_product;
CREATE DATABASE cloud_product WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 促销服务数据库
DROP DATABASE IF EXISTS cloud_promotion;
CREATE DATABASE cloud_promotion WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 任务调度服务数据库
DROP DATABASE IF EXISTS cloud_job;
CREATE DATABASE cloud_job WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;

-- 消息服务数据库
DROP DATABASE IF EXISTS cloud_message;
CREATE DATABASE cloud_message WITH OWNER = devuser ENCODING = 'UTF8' TABLESPACE = pg_default CONNECTION LIMIT = -1;
