# Chatwoot 本地部署快速指南

## ✅ 问题已解决

### 问题原因
- ❌ `docker-compose.yaml` 是开发环境配置，需要构建镜像
- ✅ 应该使用 `docker-compose.production.yaml` 生产环境配置

---

## 🚀 正确的启动命令

### 1. 启动服务（使用生产配置）

```bash
docker-compose -f docker-compose.production.yaml up -d
```

### 2. 查看启动进度

```bash
# 查看服务状态
docker-compose -f docker-compose.production.yaml ps

# 查看日志
docker-compose -f docker-compose.production.yaml logs -f
```

### 3. 初始化数据库（首次运行）

```bash
# 等待所有服务启动完成（约 1-2 分钟）
# 然后运行数据库初始化
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:chatwoot_prepare
```

### 4. 访问应用

```
http://localhost:3000
```

---

## 📋 常用命令（生产配置）

### 查看服务状态
```bash
docker-compose -f docker-compose.production.yaml ps
```

### 查看日志
```bash
# 所有服务
docker-compose -f docker-compose.production.yaml logs -f

# Rails 服务
docker-compose -f docker-compose.production.yaml logs -f rails

# Sidekiq 后台任务
docker-compose -f docker-compose.production.yaml logs -f sidekiq
```

### 重启服务
```bash
docker-compose -f docker-compose.production.yaml restart
```

### 停止服务
```bash
docker-compose -f docker-compose.production.yaml down
```

### 完全清理（包括数据）
```bash
docker-compose -f docker-compose.production.yaml down -v
```

---

## 🔧 进入容器

### Rails 控制台
```bash
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails console
```

### 数据库控制台
```bash
docker-compose -f docker-compose.production.yaml exec postgres psql -U postgres -d chatwoot
```

### Redis 控制台
```bash
docker-compose -f docker-compose.production.yaml exec redis redis-cli -a dev_redis_password_123
```

---

## 📝 当前配置

### 环境变量（.env）
```bash
RAILS_ENV=production                      # 生产环境
FRONTEND_URL=http://0.0.0.0:3000         # 前端地址
POSTGRES_PASSWORD=dev_postgres_password_123  # 数据库密码
REDIS_PASSWORD=dev_redis_password_123    # Redis 密码
```

### 端口映射
```
127.0.0.1:3000  → Rails 应用
127.0.0.1:5432  → PostgreSQL
127.0.0.1:6379  → Redis
```

### 品牌配置
```
标签页标题: Trikn 客服
品牌名称: Trikn
品牌链接: https://trikn.shop
```

---

## ⏱️ 首次启动时间

1. **下载镜像**: 2-5 分钟（约 650MB）
2. **启动服务**: 30-60 秒
3. **数据库初始化**: 30-60 秒

**总计**: 约 3-7 分钟

---

## 🎯 启动后的步骤

### 1. 等待服务完全启动

```bash
# 查看日志，等待看到类似信息：
# rails    | * Listening on http://0.0.0.0:3000
docker-compose -f docker-compose.production.yaml logs -f rails
```

### 2. 初始化数据库

```bash
docker-compose -f docker-compose.production.yaml exec rails bundle exec rails db:chatwoot_prepare
```

### 3. 创建管理员账户

访问 http://localhost:3000，点击 "Create Account" 创建管理员账户。

### 4. 验证品牌定制

- ✅ 浏览器标签页显示 "Trikn 客服"
- ✅ 小部件底部显示 "由 Trikn 提供支持"
- ✅ 点击品牌链接跳转到 https://trikn.shop

---

## 🐛 故障排查

### 问题 1: 镜像下载失败

```bash
# 使用国内镜像加速
# 在 Docker Desktop 设置中添加镜像源：
# https://docker.m.daocloud.io
# https://dockerproxy.com
```

### 问题 2: 端口被占用

```bash
# 查看端口占用
netstat -ano | findstr :3000

# 停止占用的进程
taskkill /PID <进程ID> /F
```

### 问题 3: 数据库连接失败

```bash
# 检查 PostgreSQL 是否启动
docker-compose -f docker-compose.production.yaml ps postgres

# 查看 PostgreSQL 日志
docker-compose -f docker-compose.production.yaml logs postgres

# 重启 PostgreSQL
docker-compose -f docker-compose.production.yaml restart postgres
```

### 问题 4: Redis 连接失败

```bash
# 测试 Redis 连接
docker-compose -f docker-compose.production.yaml exec redis redis-cli -a dev_redis_password_123 ping
# 应该返回: PONG
```

---

## 📊 服务架构

```
┌─────────────────────────────────────┐
│     http://localhost:3000           │
│         (Rails 应用)                 │
└──────────┬──────────────────────────┘
           │
    ┌──────┴──────┐
    │             │
┌───▼────┐   ┌───▼────┐
│Postgres│   │ Redis  │
│  5432  │   │  6379  │
└────────┘   └────────┘
    │             │
    └─────┬───────┘
          │
    ┌─────▼─────┐
    │  Sidekiq  │
    │ (后台任务) │
    └───────────┘
```

---

## 🎉 成功标志

启动成功后，您应该看到：

```bash
$ docker-compose -f docker-compose.production.yaml ps

NAME                  STATUS    PORTS
chatwoot-postgres-1   Up        127.0.0.1:5432->5432/tcp
chatwoot-rails-1      Up        127.0.0.1:3000->3000/tcp
chatwoot-redis-1      Up        127.0.0.1:6379->6379/tcp
chatwoot-sidekiq-1    Up
```

---

## 📚 下一步

1. ✅ 测试品牌定制效果
2. ✅ 配置小部件
3. ✅ 测试聊天功能
4. ✅ 准备构建自定义镜像

---

祝您部署顺利！🚀
