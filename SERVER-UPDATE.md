# 服务器更新指南

## 🔄 从 GitHub 更新到服务器

### 前提条件
- ✅ 本地代码已推送到 GitHub
- ✅ 服务器已部署 Chatwoot
- ✅ SSH 可以登录服务器

---

## 🚀 更新步骤

### 步骤 1: SSH 登录服务器

```bash
ssh root@your-server-ip
# 或
ssh user@your-server-ip
```

### 步骤 2: 进入项目目录

```bash
cd /opt/chatwoot
```

### 步骤 3: 拉取最新代码

```bash
git pull origin develop
```

**如果提示冲突或错误：**
```bash
# 放弃本地修改，强制更新
git fetch origin
git reset --hard origin/develop
```

### 步骤 4: 重启服务

```bash
docker compose -f docker-compose.fast.yaml restart
```

**或者完全重启：**
```bash
docker compose -f docker-compose.fast.yaml down
docker compose -f docker-compose.fast.yaml up -d
```

### 步骤 5: 查看日志确认

```bash
docker compose -f docker-compose.fast.yaml logs -f rails
```

等待看到：
```
* Listening on http://0.0.0.0:3000
```

按 `Ctrl + C` 退出日志查看

### 步骤 6: 验证更新

访问：
```
https://chat.trikn.shop/super_admin/app_config?config=custom_branding
```

尝试修改品牌配置，确认可以成功保存。

---

## 📋 完整命令（复制粘贴）

```bash
# 登录服务器
ssh root@your-server-ip

# 进入项目目录
cd /opt/chatwoot

# 拉取最新代码
git pull origin develop

# 重启服务
docker compose -f docker-compose.fast.yaml restart

# 查看日志
docker compose -f docker-compose.fast.yaml logs -f rails
```

---

## 🔍 验证更新是否成功

### 检查挂载的文件

```bash
# 检查修改的文件是否存在
ls -la lib/chatwoot_hub.rb
ls -la app/models/installation_config.rb
ls -la enterprise/app/services/internal/reconcile_plan_config_service.rb

# 查看文件内容（确认修改已应用）
grep "enterprise" lib/chatwoot_hub.rb
grep "locked = false" app/models/installation_config.rb
```

应该看到我们的修改。

### 检查容器内的文件

```bash
# 进入容器查看
docker compose -f docker-compose.fast.yaml exec rails cat /app/lib/chatwoot_hub.rb | grep "enterprise"

# 应该显示：
# 'enterprise'
```

---

## 🐛 常见问题

### Q1: git pull 提示冲突

**原因：** 服务器上有本地修改

**解决：**
```bash
# 查看冲突文件
git status

# 放弃本地修改
git reset --hard origin/develop

# 或者暂存本地修改
git stash
git pull
```

### Q2: 重启后服务无法启动

**检查：**
```bash
# 查看所有服务状态
docker compose -f docker-compose.fast.yaml ps

# 查看错误日志
docker compose -f docker-compose.fast.yaml logs rails
docker compose -f docker-compose.fast.yaml logs sidekiq
```

**常见原因：**
- 文件路径错误
- 挂载的文件不存在
- 权限问题

**解决：**
```bash
# 确保文件存在
ls -la app/models/installation_config.rb

# 如果文件不存在，重新拉取
git pull origin develop
```

### Q3: 修改后界面仍然无法保存

**检查：**
```bash
# 确认 installation_config.rb 已挂载
docker compose -f docker-compose.fast.yaml exec rails cat /app/app/models/installation_config.rb | grep "locked = false"
```

**如果没有显示，说明挂载失败：**
```bash
# 完全重启
docker compose -f docker-compose.fast.yaml down
docker compose -f docker-compose.fast.yaml up -d
```

---

## 🔄 更新流程图

```
本地修改 → Git Push → GitHub
                         ↓
服务器 SSH 登录 → git pull → 重启服务 → 验证
```

---

## 📊 更新前后对比

| 项目 | 更新前 | 更新后 |
|------|--------|--------|
| 企业功能 | ❌ 锁定 | ✅ 解锁 |
| 界面修改品牌 | ❌ 被拒绝 | ✅ 可以修改 |
| 配置持久化 | ❌ 会被重置 | ✅ 永久保存 |
| 挂载文件数 | 5 个 | 6 个 |

---

## 🎯 更新后的功能

更新后，您可以：

1. ✅ 在超级管理员后台直接修改品牌
2. ✅ 修改后立即生效
3. ✅ 配置永久保存，不会被重置
4. ✅ 所有企业功能可用

---

## 📝 更新记录

### 2025-12-29 更新内容

**新增文件：**
- `app/models/installation_config.rb` - 解锁配置修改权限

**修改文件：**
- `docker-compose.fast.yaml` - 添加新文件挂载

**效果：**
- ✅ 可以在界面直接修改品牌配置
- ✅ 不再出现 "The change you wanted was rejected" 错误

---

## 🔒 安全提示

### 更新前备份

```bash
# 备份数据库
docker compose -f docker-compose.fast.yaml exec postgres pg_dump -U postgres chatwoot > backup_$(date +%Y%m%d).sql

# 备份配置
cp .env .env.backup
```

### 更新后验证

- [ ] 服务正常启动
- [ ] 可以登录
- [ ] 企业功能正常
- [ ] 可以修改品牌配置
- [ ] 对话功能正常

---

## 📞 需要帮助？

如果更新遇到问题：

1. 查看日志：`docker compose -f docker-compose.fast.yaml logs -f`
2. 检查文件：`ls -la app/models/installation_config.rb`
3. 重新拉取：`git reset --hard origin/develop`
4. 完全重启：`docker compose -f docker-compose.fast.yaml down && docker compose -f docker-compose.fast.yaml up -d`

---

**祝您更新顺利！** 🚀
