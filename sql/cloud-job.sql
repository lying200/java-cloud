-- 任务调度服务数据库初始化脚本
-- 注意：请先在postgres数据库中执行create-databases.sql创建数据库

-- 任务信息表
CREATE TABLE jobs (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    job_group VARCHAR(50) NOT NULL,
    invoke_target VARCHAR(500) NOT NULL,
    cron_expression VARCHAR(255) NOT NULL,
    misfire_policy SMALLINT NOT NULL DEFAULT 1,
    concurrent BOOLEAN NOT NULL DEFAULT FALSE,
    status SMALLINT NOT NULL DEFAULT 1,
    remark VARCHAR(500),
    notify_channel SMALLINT,
    notify_emails VARCHAR(255),
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_jobs_name_group ON jobs (name, job_group) WHERE NOT deleted;

COMMENT ON TABLE jobs IS '任务信息表';
COMMENT ON COLUMN jobs.name IS '任务名称';
COMMENT ON COLUMN jobs.job_group IS '任务分组';
COMMENT ON COLUMN jobs.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN jobs.cron_expression IS 'cron执行表达式';
COMMENT ON COLUMN jobs.misfire_policy IS '计划执行错误策略：1-立即执行，2-执行一次，3-放弃执行';
COMMENT ON COLUMN jobs.concurrent IS '是否并发执行';
COMMENT ON COLUMN jobs.status IS '状态：1-正常，2-暂停';
COMMENT ON COLUMN jobs.remark IS '备注信息';
COMMENT ON COLUMN jobs.notify_channel IS '通知渠道：1-邮件，2-短信，3-钉钉，4-飞书';
COMMENT ON COLUMN jobs.notify_emails IS '通知邮件地址，多个用逗号分隔';
COMMENT ON COLUMN jobs.deleted IS '是否删除';
COMMENT ON COLUMN jobs.create_time IS '创建时间';
COMMENT ON COLUMN jobs.update_time IS '更新时间';
COMMENT ON COLUMN jobs.version IS '版本号';

-- 任务日志表
CREATE TABLE job_logs (
    id BIGSERIAL PRIMARY KEY,
    job_id BIGINT NOT NULL,
    name VARCHAR(100) NOT NULL,
    job_group VARCHAR(50) NOT NULL,
    invoke_target VARCHAR(500) NOT NULL,
    job_message VARCHAR(500),
    status SMALLINT NOT NULL DEFAULT 1,
    exception_info TEXT,
    start_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_time TIMESTAMP WITH TIME ZONE,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

COMMENT ON TABLE job_logs IS '任务日志表';
COMMENT ON COLUMN job_logs.job_id IS '任务ID';
COMMENT ON COLUMN job_logs.name IS '任务名称';
COMMENT ON COLUMN job_logs.job_group IS '任务分组';
COMMENT ON COLUMN job_logs.invoke_target IS '调用目标字符串';
COMMENT ON COLUMN job_logs.job_message IS '日志信息';
COMMENT ON COLUMN job_logs.status IS '执行状态：1-正常，2-失败';
COMMENT ON COLUMN job_logs.exception_info IS '异常信息';
COMMENT ON COLUMN job_logs.start_time IS '开始时间';
COMMENT ON COLUMN job_logs.end_time IS '结束时间';
COMMENT ON COLUMN job_logs.deleted IS '是否删除';
COMMENT ON COLUMN job_logs.create_time IS '创建时间';
COMMENT ON COLUMN job_logs.update_time IS '更新时间';
COMMENT ON COLUMN job_logs.version IS '版本号';

-- 任务锁表
CREATE TABLE job_locks (
    id BIGSERIAL PRIMARY KEY,
    lock_name VARCHAR(100) NOT NULL,
    lock_key VARCHAR(100) NOT NULL,
    node_id VARCHAR(100) NOT NULL,
    lock_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expire_time TIMESTAMP WITH TIME ZONE NOT NULL,
    deleted BOOLEAN NOT NULL DEFAULT FALSE,
    create_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    update_time TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    version INTEGER NOT NULL DEFAULT 0
);

CREATE UNIQUE INDEX idx_job_locks_name ON job_locks (lock_name) WHERE NOT deleted;

COMMENT ON TABLE job_locks IS '任务锁表';
COMMENT ON COLUMN job_locks.lock_name IS '锁名称';
COMMENT ON COLUMN job_locks.lock_key IS '锁定key';
COMMENT ON COLUMN job_locks.node_id IS '节点标识';
COMMENT ON COLUMN job_locks.lock_time IS '锁定时间';
COMMENT ON COLUMN job_locks.expire_time IS '过期时间';
COMMENT ON COLUMN job_locks.deleted IS '是否删除';
COMMENT ON COLUMN job_locks.create_time IS '创建时间';
COMMENT ON COLUMN job_locks.update_time IS '更新时间';
COMMENT ON COLUMN job_locks.version IS '版本号';

-- 创建索引
CREATE INDEX idx_jobs_status ON jobs(status);
CREATE INDEX idx_jobs_job_group ON jobs(job_group);

CREATE INDEX idx_job_logs_job_id ON job_logs(job_id);
CREATE INDEX idx_job_logs_status ON job_logs(status);
CREATE INDEX idx_job_logs_start_time ON job_logs(start_time);

CREATE INDEX idx_job_locks_expire_time ON job_locks(expire_time);
