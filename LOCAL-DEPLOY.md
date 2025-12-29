# Chatwoot 本地 Docker 部署指南

## ✅ 配置已完成

### 已修改的文件：

1. **docker-compose.yaml**
   - ✅ PostgreSQL 端口绑定到 `127.0.0.1:5432`
   - ✅ Redis 端口绑定到 `127.0.0.1:6379`
   - ✅ 使用环境变量设置密码

2. **.env**
   - ✅ `SECRET_KEY_BASE`: 已设置开发密钥
   - ✅ `POSTGRES_PASSWORD`: dev_postgres_password_123
   - ✅ `REDIS_PASSWORD`: dev_redis_password_123

3. **.gitignore**
   - ✅ 已移除 `.env` 忽略（方便提交到您的私有仓库）

---

## 🚀 启动步骤

### 1. 启动所有服务

```bash
# 启动 Docker 服务
docker-compose up -d

# 查看日志
docker-compose logs -f
```

### 2. 初始化数据库（首次运行）

```bash
# 等待服务启动完成（约 30 秒）
# 然后运行数据库初始化
docker-compose exec rails bundle exec rails db:chatwoot_prepare
```

### 3. 访问应用

打开浏览器访问：
```
http://localhost:3000
```

---

## 📋 常用命令

### 查看服务状态
```bash
docker-compose ps
```

### 查看日志
```bash
# 所有服务
docker-compose logs -f

# 特定服务
docker-compose logs -f rails
docker-compose logs -f sidekiq
docker-compose logs -f postgres
docker-compose logs -f redis
```

### 重启服务
```bash
# 重启所有服务
docker-compose restart

# 重启特定服务
docker-compose restart rails
```

### 停止服务
```bash
docker-compose down
```

### 完全清理（包括数据）
```bash
docker-compose down -v
```

---

## 🔧 进入容器调试

### Rails 控制台
```bash
docker-compose exec rails bundle exec rails console
```

### 数据库控制台
```bash
docker-compose exec postgres psql -U postgres -d chatwoot
```

### Redis 控制台
```bash
docker-compose exec redis redis-cli -a dev_redis_password_123
```

### 进入 Rails 容器
```bash
docker-compose exec rails bash
```

---

## 📝 环境变量说明

### 数据库配置
```bash
POSTGRES_HOST=postgres          # Docker 服务名
POSTGRES_USERNAME=postgres      # 数据库用户名
POSTGRES_PASSWORD=dev_postgres_password_123  # 数据库密码
```

### Redis 配置
```bash
REDIS_URL=redis://redis:6379    # Redis 连接地址
REDIS_PASSWORD=dev_redis_password_123  # Redis 密码
```

### 应用配置
```bash
FRONTEND_URL=http://0.0.0.0:3000  # 前端访问地址
RAILS_ENV=development             # 运行环境
```

---

## ⚠️ 注意事项

### 1. 端口占用
确保以下端口未被占用：
- `3000` - Rails 应用
- `3036` - Vite 开发服务器
- `5432` - PostgreSQL（仅本地访问）
- `6379` - Redis（仅本地访问）
- `1025` - MailHog SMTP
- `8025` - MailHog Web UI

### 2. 首次启动较慢
首次启动需要：
- 下载 Docker 镜像
- 构建应用镜像
- 安装依赖
- 编译前端资源

预计耗时：5-15 分钟

### 3. 数据持久化
数据存储在 Docker volumes 中：
- `postgres` - 数据库数据
- `redis` - Redis 数据
- `packs` - 编译的前端资源
- `node_modules` - Node.js 依赖
- `bundle` - Ruby gems

---

## 🐛 故障排查

### 问题 1: 端口已被占用
```bash
# 查看端口占用
netstat -ano | findstr :3000

# 停止占用端口的进程
taskkill /PID <进程ID> /F
```

### 问题 2: 数据库连接失败
```bash
# 检查 PostgreSQL 是否启动
docker-compose ps postgres

# 查看 PostgreSQL 日志
docker-compose logs postgres

# 重启 PostgreSQL
docker-compose restart postgres
```

### 问题 3: Redis 连接失败
```bash
# 检查 Redis 是否启动
docker-compose ps redis

# 测试 Redis 连接
docker-compose exec redis redis-cli -a dev_redis_password_123 ping
# 应该返回: PONG
```

### 问题 4: 前端资源编译失败
```bash
# 重新编译前端资源
docker-compose exec rails bundle exec rails assets:precompile

# 或重启 Vite 服务
docker-compose restart vite
```

### 问题 5: 数据库迁移失败
```bash
# 删除数据库重新创建
docker-compose down -v
docker-compose up -d
docker-compose exec rails bundle exec rails db:chatwoot_prepare
```

---

## 🎯 下一步

### 1. 创建管理员账户
首次访问 http://localhost:3000 时，点击 "Create Account" 创建管理员账户。

### 2. 配置邮件服务（可选）
开发环境已配置 MailHog，可以在 http://localhost:8025 查看发送的邮件。

### 3. 测试品牌定制
查看标签页标题是否显示 "Trikn 客服"，小部件底部是否显示 "由 Trikn 提供支持"。

### 4. 准备生产部署
测试完成后，可以构建生产镜像：
```bash
docker build -t your-registry/chatwoot-trikn:v1.0 .
docker push your-registry/chatwoot-trikn:v1.0
```

---

## 📚 参考资料

- Chatwoot 官方文档: https://www.chatwoot.com/docs
- Docker Compose 文档: https://docs.docker.com/compose/
- 环境变量配置: https://www.chatwoot.com/docs/self-hosted/configuration/environment-variables/

---

祝您部署顺利！🚀
