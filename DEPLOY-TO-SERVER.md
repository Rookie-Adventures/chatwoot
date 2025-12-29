# Chatwoot 服务器部署完整指南
# 目标服务器: Ubuntu 24.04 (2C2G)
# 域名: chat.trikn.shop (请替换为您的域名)

## 📋 服务器要求

### 最低配置
- **CPU**: 2 核心 ✅
- **内存**: 2GB ⚠️ (建议 4GB，2GB 可能需要添加 Swap)
- **存储**: 20GB
- **系统**: Ubuntu 24.04 LTS

### 需要的端口
- `80` - HTTP (自动重定向到 HTTPS)
- `443` - HTTPS
- `22` - SSH

---

## 🚀 部署步骤

### 步骤 1: 准备服务器

#### 1.1 更新系统
```bash
sudo apt update && sudo apt upgrade -y
```

#### 1.2 安装 Docker
```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 启动 Docker
sudo systemctl start docker
sudo systemctl enable docker

# 添加当前用户到 docker 组（避免每次都用 sudo）
sudo usermod -aG docker $USER

# 重新登录使组权限生效
exit
# 重新 SSH 登录
```

#### 1.3 安装 Docker Compose
```bash
sudo apt install docker-compose-plugin -y

# 验证安装
docker compose version
```

#### 1.4 安装 Nginx 和 Certbot（用于 SSL）
```bash
sudo apt install nginx certbot python3-certbot-nginx -y
```

---

### 步骤 2: 配置 DNS

**在域名管理面板添加 A 记录：**
```
类型: A
主机: chat (或 @)
值: 您的服务器公网 IP
TTL: 600
```

**验证 DNS 生效：**
```bash
ping chat.trikn.shop
# 应该返回您的服务器 IP
```

---

### 步骤 3: 上传项目文件到服务器

#### 3.1 在服务器上创建目录
```bash
sudo mkdir -p /opt/chatwoot
sudo chown $USER:$USER /opt/chatwoot
cd /opt/chatwoot
```

#### 3.2 从本地上传文件

**在本地 Windows 上执行：**
```powershell
# 方法 1: 使用 SCP（推荐）
scp -r e:\chatwoot\* user@your-server-ip:/opt/chatwoot/

# 方法 2: 使用 Git（如果已推送到 GitHub）
# 在服务器上执行:
# git clone https://github.com/YOUR_USERNAME/chatwoot.git /opt/chatwoot
```

**需要上传的关键文件：**
```
/opt/chatwoot/
├── docker-compose.fast.yaml       # Docker 配置
├── .env                           # 环境变量
├── lib/chatwoot_hub.rb           # 企业功能解锁
├── enterprise/app/services/internal/reconcile_plan_config_service.rb
├── config/installation_config.yml
├── enterprise/config/premium_installation_config.yml
└── public/brand-assets/          # 您的 Logo 和图标
```

---

### 步骤 4: 配置环境变量

#### 4.1 编辑 .env 文件
```bash
cd /opt/chatwoot
nano .env
```

#### 4.2 修改关键配置
```bash
# 前端 URL（重要！）
FRONTEND_URL=https://chat.trikn.shop

# 强制 SSL
FORCE_SSL=true

# 数据库密码（生成强密码）
POSTGRES_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
# 例如: POSTGRES_PASSWORD=K8mN2pQ5rT9vX3wZ7bC4dF6gH1jL0nM8

# Redis 密码（生成强密码）
REDIS_PASSWORD=$(openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32)
# 例如: REDIS_PASSWORD=P3qR7sT2uV6wX9yZ4aC8bD1eF5gH0jK3

# SECRET_KEY_BASE（生成随机密钥）
SECRET_KEY_BASE=$(openssl rand -hex 64)

# 运行环境
RAILS_ENV=production

# 默认语言
DEFAULT_LOCALE=zh_CN

# 禁用注册（安全）
ENABLE_ACCOUNT_SIGNUP=false
```

**保存并退出：** `Ctrl + X`, `Y`, `Enter`

---

### 步骤 5: 增加 Swap（2GB 内存必须）

```bash
# 创建 2GB Swap
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# 永久生效
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 验证
free -h
```

---

### 步骤 6: 启动 Chatwoot

#### 6.1 启动服务
```bash
cd /opt/chatwoot
docker compose -f docker-compose.fast.yaml up -d
```

#### 6.2 查看日志（确认启动成功）
```bash
docker compose -f docker-compose.fast.yaml logs -f rails
```

**等待看到：**
```
* Listening on http://0.0.0.0:3000
```

按 `Ctrl + C` 退出日志查看

#### 6.3 初始化数据库
```bash
docker compose -f docker-compose.fast.yaml exec rails bundle exec rails db:chatwoot_prepare
```

---

### 步骤 7: 配置 Nginx 反向代理

#### 7.1 创建 Nginx 配置
```bash
sudo nano /etc/nginx/sites-available/chatwoot
```

#### 7.2 添加以下内容
```nginx
upstream chatwoot {
  server 127.0.0.1:3000;
}

server {
  listen 80;
  server_name chat.trikn.shop;
  
  # 临时允许 HTTP（用于获取 SSL 证书）
  location /.well-known/acme-challenge/ {
    root /var/www/html;
  }
  
  # 其他请求重定向到 HTTPS
  location / {
    return 301 https://$server_name$request_uri;
  }
}

server {
  listen 443 ssl http2;
  server_name chat.trikn.shop;

  client_max_body_size 50M;
  
  # SSL 证书（稍后由 certbot 自动配置）
  # ssl_certificate /etc/letsencrypt/live/chat.trikn.shop/fullchain.pem;
  # ssl_certificate_key /etc/letsencrypt/live/chat.trikn.shop/privkey.pem;

  location / {
    proxy_pass http://chatwoot;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
    proxy_set_header X-Forwarded-Host $host;
    proxy_set_header X-Forwarded-Port $server_port;
  }

  location /cable {
    proxy_pass http://chatwoot;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    proxy_set_header Host $host;
  }
}
```

**保存并退出**

#### 7.3 启用配置
```bash
sudo ln -s /etc/nginx/sites-available/chatwoot /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

### 步骤 8: 获取 SSL 证书

```bash
sudo certbot --nginx -d chat.trikn.shop
```

**按照提示操作：**
1. 输入邮箱
2. 同意服务条款
3. 选择是否重定向 HTTP 到 HTTPS（选择 2 - 重定向）

**验证自动续期：**
```bash
sudo certbot renew --dry-run
```

---

### 步骤 9: 配置防火墙

```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp
sudo ufw enable
```

---

### 步骤 10: 访问并配置

#### 10.1 访问应用
```
https://chat.trikn.shop
```

#### 10.2 创建管理员账户
点击 "Create Account" 创建第一个管理员账户

#### 10.3 验证企业功能
访问：`https://chat.trikn.shop/super_admin`

应该看到：
- ✅ 计划显示为 "Enterprise"
- ✅ 所有功能可用

#### 10.4 配置品牌
进入 `https://chat.trikn.shop/super_admin/app_config?config=custom_branding`

修改：
- Installation Name
- Brand Name
- Logo 路径：`/brand-assets/your-logo.png`

---

## 📁 上传自定义 Logo

### 方法 1: 从本地上传
```bash
# 在本地 Windows 上
scp e:\chatwoot\public\brand-assets\* user@your-server-ip:/opt/chatwoot/public/brand-assets/
```

### 方法 2: 在服务器上下载
```bash
cd /opt/chatwoot/public/brand-assets
wget https://yourdomain.com/logo.png
```

### 方法 3: 直接复制到容器
```bash
docker cp /path/to/logo.png chatwoot-rails-1:/app/public/brand-assets/
```

---

## 🔧 常用管理命令

### 查看服务状态
```bash
docker compose -f docker-compose.fast.yaml ps
```

### 查看日志
```bash
# 所有服务
docker compose -f docker-compose.fast.yaml logs -f

# 特定服务
docker compose -f docker-compose.fast.yaml logs -f rails
docker compose -f docker-compose.fast.yaml logs -f sidekiq
```

### 重启服务
```bash
docker compose -f docker-compose.fast.yaml restart
```

### 停止服务
```bash
docker compose -f docker-compose.fast.yaml down
```

### 更新代码后重启
```bash
cd /opt/chatwoot
git pull  # 如果使用 Git
docker compose -f docker-compose.fast.yaml restart
```

### 进入 Rails 控制台
```bash
docker compose -f docker-compose.fast.yaml exec rails bundle exec rails console
```

### 数据库备份
```bash
docker compose -f docker-compose.fast.yaml exec postgres pg_dump -U postgres chatwoot > backup_$(date +%Y%m%d).sql
```

---

## 🐛 故障排查

### 问题 1: 内存不足
```bash
# 查看内存使用
free -h

# 查看 Docker 容器内存
docker stats

# 如果内存不足，增加 Swap 或升级服务器
```

### 问题 2: 无法访问
```bash
# 检查 Nginx
sudo nginx -t
sudo systemctl status nginx

# 检查端口
sudo netstat -tlnp | grep :80
sudo netstat -tlnp | grep :443

# 检查防火墙
sudo ufw status
```

### 问题 3: SSL 证书问题
```bash
# 检查证书
sudo certbot certificates

# 手动续期
sudo certbot renew

# 重新获取证书
sudo certbot --nginx -d chat.trikn.shop --force-renewal
```

### 问题 4: 数据库连接失败
```bash
# 检查 PostgreSQL
docker compose -f docker-compose.fast.yaml logs postgres

# 重启数据库
docker compose -f docker-compose.fast.yaml restart postgres
```

---

## 📊 性能优化（2C2G 服务器）

### 1. 限制 Docker 内存
编辑 `docker-compose.fast.yaml`：
```yaml
services:
  rails:
    mem_limit: 1g
  sidekiq:
    mem_limit: 512m
```

### 2. 减少 Sidekiq 并发
在 `.env` 中：
```bash
SIDEKIQ_CONCURRENCY=5  # 默认 10，减少到 5
```

### 3. 启用日志轮转
```bash
# 限制 Docker 日志大小
sudo nano /etc/docker/daemon.json
```

添加：
```json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

重启 Docker：
```bash
sudo systemctl restart docker
```

---

## 🔒 安全建议

1. ✅ 使用强密码
2. ✅ 禁用 root SSH 登录
3. ✅ 配置 SSH 密钥认证
4. ✅ 定期更新系统
5. ✅ 定期备份数据
6. ✅ 启用防火墙
7. ✅ 监控服务器资源

---

## 📅 维护计划

### 每周
- 检查服务状态
- 查看错误日志

### 每月
- 备份数据库
- 更新系统包
- 检查 SSL 证书

### 每季度
- 更新 Chatwoot 版本
- 审查安全设置

---

## 🎉 部署完成检查清单

- [ ] DNS 已配置并生效
- [ ] Docker 和 Docker Compose 已安装
- [ ] 环境变量已正确配置
- [ ] Swap 已添加（2GB 内存必须）
- [ ] Chatwoot 服务已启动
- [ ] Nginx 反向代理已配置
- [ ] SSL 证书已获取
- [ ] 防火墙已配置
- [ ] 管理员账户已创建
- [ ] 企业功能已验证
- [ ] 品牌已定制
- [ ] 备份策略已设置

---

## 📞 获取帮助

- Chatwoot 官方文档: https://www.chatwoot.com/docs
- GitHub Issues: https://github.com/chatwoot/chatwoot/issues
- 社区论坛: https://github.com/chatwoot/chatwoot/discussions

---

**祝您部署顺利！** 🚀
