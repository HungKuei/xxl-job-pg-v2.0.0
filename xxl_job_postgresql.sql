
CREATE TABLE xxl_job_info
(
 id  serial  NOT NULL,
 job_group  integer  NOT NULL,
 job_cron  varchar(128) NOT NULL ,
 job_desc  varchar(255) NOT NULL,
 add_time  timestamp with time zone DEFAULT NULL,
 update_time  timestamp with time zone DEFAULT NULL,
 author  varchar(64) DEFAULT NULL ,
 alarm_email  varchar(255) DEFAULT NULL ,
 executor_route_strategy  varchar(50) DEFAULT NULL ,
 executor_handler  varchar(255) DEFAULT NULL ,
 executor_param  varchar(512) DEFAULT NULL ,
 executor_block_strategy  varchar(50) DEFAULT NULL ,
 executor_timeout  integer  NOT NULL DEFAULT '0' ,
 executor_fail_retry_count  integer  NOT NULL DEFAULT '0' ,
 glue_type  varchar(50) NOT NULL ,
 glue_source  text ,
 glue_remark  varchar(128) DEFAULT NULL ,
 glue_updatetime  timestamp with time zone DEFAULT NULL ,
 child_jobid  varchar(255) DEFAULT NULL ,
 trigger_status  int NOT NULL DEFAULT '0' ,
 trigger_last_time  bigint NOT NULL DEFAULT '0' ,
 trigger_next_time  bigint NOT NULL DEFAULT '0' ,
PRIMARY KEY ( id )
);
comment on table xxl_job_info is '任务信息表';
comment on column xxl_job_info.id  is '主键';
comment on column xxl_job_info.job_group  is '执行器主键ID';
comment on column xxl_job_info.job_cron  is '任务执行CRON';
comment on column xxl_job_info.job_desc  is '任务描述';
comment on column xxl_job_info.add_time  is '任务创建时间';
comment on column xxl_job_info.update_time  is '任务更新时间';
comment on column xxl_job_info.author  is '作者';
comment on column xxl_job_info.alarm_email  is '报警邮件';
comment on column xxl_job_info.executor_route_strategy  is '执行器路由策略';
comment on column xxl_job_info.executor_handler  is '执行器任务handler';
comment on column xxl_job_info.executor_param is '执行器任务参数';
comment on column xxl_job_info.executor_block_strategy  is '阻塞处理策略';
comment on column xxl_job_info.executor_timeout  is '任务执行超时时间，单位秒';
comment on column xxl_job_info.executor_fail_retry_count  is '失败重试次数';
comment on column xxl_job_info.glue_type  is 'GLUE类型';
comment on column xxl_job_info.glue_source  is 'GLUE源代码';
comment on column xxl_job_info.glue_remark  is 'GLUE备注';
comment on column xxl_job_info.glue_updatetime  is 'GLUE更新时间';
comment on column xxl_job_info.child_jobid  is '子任务ID，多个逗号分隔';
comment on column xxl_job_info.trigger_status  is '调度状态：0-停止，1-运行';
comment on column xxl_job_info.trigger_last_time  is '上次调度时间';
comment on column xxl_job_info.trigger_next_time  is '下次调度时间';


CREATE TABLE xxl_job_log (
  id serial NOT NULL ,
  job_group int NOT NULL ,
  job_id int NOT NULL ,
  executor_address varchar(255) DEFAULT NULL ,
  executor_handler varchar(255) DEFAULT NULL,
  executor_param varchar(512) DEFAULT NULL ,
  executor_sharding_param varchar(20) DEFAULT NULL ,
  executor_fail_retry_count int NOT NULL DEFAULT 0 ,
  trigger_time timestamp with time zone DEFAULT NULL,
  trigger_code int NOT NULL ,
  trigger_msg text ,
  handle_time timestamp with time zone DEFAULT NULL ,
  handle_code int NOT NULL ,
  handle_msg text ,
  alarm_status int NOT NULL DEFAULT 0 ,
  PRIMARY KEY (id)
);
CREATE INDEX I_trigger_time ON xxl_job_log (trigger_time);
CREATE INDEX I_handle_code ON xxl_job_log (handle_code);
comment on table xxl_job_log is '任务日志表';
comment on column xxl_job_log.id  is '主键';
comment on column xxl_job_log.job_group  is '执行器主键ID';
comment on column xxl_job_log.job_id  is '任务，主键ID';
comment on column xxl_job_log.executor_address  is '执行器地址，本次执行的地址';
comment on column xxl_job_log.executor_handler  is '执行器任务handler';
comment on column xxl_job_log.executor_param  is '执行器任务参数';
comment on column xxl_job_log.executor_sharding_param  is '执行器任务分片参数，格式如 1/2';
comment on column xxl_job_log.executor_fail_retry_count  is '失败重试次数';
comment on column xxl_job_log.trigger_time  is '调度-时间';
comment on column xxl_job_log.trigger_code  is '调度-结果';
comment on column xxl_job_log.trigger_msg  is '调度-日志';
comment on column xxl_job_log.handle_time  is '执行-时间';
comment on column xxl_job_log.handle_code  is '执行-状态';
comment on column xxl_job_log.handle_msg  is '执行-日志';
comment on column xxl_job_log.alarm_status  is '告警状态：0-默认、1-无需告警、2-告警成功、3-告警失败';

create or replace function upd_timestamp() returns trigger as
$$
begin
  new.update_time = current_timestamp;
  return new;
end
$$
language plpgsql;


CREATE TABLE xxl_job_logglue (
  id SERIAL NOT NULL,
  job_id int NOT NULL ,
  glue_type varchar(50) DEFAULT NULL ,
  glue_source text ,
  glue_remark varchar(128) NOT NULL ,
  add_time timestamp with time zone NULL DEFAULT NULL,
  update_time timestamp with time zone NULL DEFAULT NULL,
PRIMARY KEY (id)
);
create trigger t_xxl_job_logglue_update_time before update on xxl_job_logglue for each row execute procedure upd_timestamp();
comment on table xxl_job_logglue is '任务GLUE日志表';
comment on column xxl_job_logglue.id  is '主键';
comment on column xxl_job_logglue.job_id  is '任务，主键ID';
comment on column xxl_job_logglue.glue_type  is 'GLUE类型';
comment on column xxl_job_logglue.glue_source  is 'GLUE源代码';
comment on column xxl_job_logglue.glue_remark  is 'GLUE备注';
comment on column xxl_job_logglue.add_time  is '创建时间';
comment on column xxl_job_logglue.update_time  is '修改时间';


CREATE TABLE xxl_job_log_report (
  id SERIAL  NOT NULL,
  trigger_day timestamp with time zone NULL DEFAULT NULL,
  running_count int not null default 0,
  suc_count  int not null default 0,
  fail_count  int not null default 0,
  PRIMARY KEY (id)
) ;
comment on column  xxl_job_log_report.id  is '主键';
comment on column  xxl_job_log_report.trigger_day  is '调度-时间';
comment on column  xxl_job_log_report.running_count  is '运行中-日志数量';
comment on column  xxl_job_log_report.suc_count  is '执行成功-日志数量';
comment on column  xxl_job_log_report.fail_count  is '执行失败-日志数量';

CREATE TABLE xxl_job_registry (
  id SERIAL NOT NULL,
  registry_group varchar(255) NOT NULL,
  registry_key varchar(255) NOT NULL,
  registry_value varchar(255) NOT NULL,
  update_time timestamp NOT NULL DEFAULT current_timestamp,
PRIMARY KEY (id)
);
CREATE INDEX i_g_k_v ON xxl_job_registry (registry_group,registry_key,registry_value);
CREATE INDEX i_u ON xxl_job_registry (update_time);
comment on table xxl_job_registry is '任务注册表';
comment on column xxl_job_registry.id  is '主键';
comment on column xxl_job_registry.registry_group  is '注册分组';
comment on column xxl_job_registry.registry_key  is '注册键';
comment on column xxl_job_registry.registry_value  is '注册值';
comment on column xxl_job_registry.update_time  is '更新时间';


CREATE TABLE xxl_job_group (
  id SERIAL NOT NULL,
  app_name varchar(64) NOT NULL,
  title varchar(12) NOT NULL,
  address_type int NOT NULL DEFAULT 0,
  address_list varchar(512) DEFAULT NULL,
PRIMARY KEY (id)
);
comment on table xxl_job_group is '任务分组表';
comment on column xxl_job_group.id  is '主键';
comment on column xxl_job_group.app_name  is '执行器AppName';
comment on column xxl_job_group.title  is '执行器名称';
comment on column xxl_job_group.address_type  is '执行器地址类型：0=自动注册、1=手动录入';
comment on column xxl_job_group.address_list  is '执行器地址列表，多地址逗号分隔';



CREATE TABLE xxl_job_user (
  id SERIAL NOT NULL,
  username varchar(50) NOT NULL,
  password varchar(50) NOT NULL,
  role int NOT NULL,
  permission varchar(255) DEFAULT NULL,
PRIMARY KEY (id)
);
CREATE UNIQUE INDEX i_username ON xxl_job_user (username);
comment on table xxl_job_user is '任务用户表';
comment on column xxl_job_user.id  is '主键';
comment on column xxl_job_user.username  is '账号';
comment on column xxl_job_user.password  is '密码';
comment on column xxl_job_user.role  is '角色：0-普通用户、1-管理员';
comment on column xxl_job_user.permission  is '权限：执行器ID列表，多个逗号分割';


CREATE TABLE xxl_job_lock (
  lock_name varchar(50) NOT NULL,
PRIMARY KEY (lock_name)
);
comment on table xxl_job_lock is '任务锁表';
comment on column xxl_job_lock.lock_name  is '锁名称';



INSERT INTO  xxl_job_group ( id ,  app_name ,  title ,  address_type ,  address_list ) VALUES (1, 'xxl-job-executor-sample', '示例执行器', 0, NULL);
INSERT INTO  xxl_job_info ( id ,  job_group ,  job_cron ,  job_desc ,  add_time ,  update_time ,  author ,  alarm_email ,  executor_route_strategy ,  executor_handler ,  executor_param ,  executor_block_strategy ,  executor_timeout ,  executor_fail_retry_count ,  glue_type ,  glue_source ,  glue_remark ,  glue_updatetime ,  child_jobid ) VALUES (1, 1, '0 0 0 * * ? *', '测试任务1', '2018-11-03 22:21:31', '2018-11-03 22:21:31', 'XXL', '', 'FIRST', 'demoJobHandler', '', 'SERIAL_EXECUTION', 0, 0, 'BEAN', '', 'GLUE代码初始化', '2018-11-03 22:21:31', '');
INSERT INTO  xxl_job_user ( id ,  username ,  password ,  role ,  permission ) VALUES (1, 'admin', 'e10adc3949ba59abbe56e057f20f883e', 1, NULL);
INSERT INTO  xxl_job_lock  (  lock_name ) VALUES ( 'schedule_lock');

commit;