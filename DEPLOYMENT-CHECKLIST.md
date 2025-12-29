# 部署前准备清单

## ✅ 推送到 GitHub 前的准备

### 1. 图片准备

#### 必需图片（放在 `public/brand-assets/` 目录）

```
e:\chatwoot\public\brand-assets\
├── logo.png          # 主 Logo
├── logo-dark.png     # 深色模式 Logo  
└── favicon.png       # 浏览器图标
```

#### 图片规格要求

| 文件名 | 尺寸 | 格式 | 说明 |
|--------|------|------|------|
| `logo.png` | 宽 120-180px<br>高 40-60px | PNG/SVG | 建议透明背景<br>用于亮色模式 |
| `logo-dark.png` | 宽 120-180px<br>高 40-60px | PNG/SVG | 建议透明背景<br>用于深色模式 |
| `favicon.png` | 512x512px | PNG | 正方形<br>浏览器标签页图标 |

#### 在线工具推荐

**生成 Favicon：**
- https://realfavicongenerator.net/ （推荐）
- https://favicon.io/

**调整图片尺寸：**
- https://www.iloveimg.com/resize-image
- https://tinypng.com/ （压缩）

---

### 2. 环境变量配置

#### 检查 `.env` 文件

确保以下配置正确：

```bash
# 域名配置（重要！）
FRONTEND_URL=https://chat.trikn.shop

# 强制 SSL
FORCE_SSL=true

# 数据库密码（必须修改）
POSTGRES_PASSWORD=生成的强密码

# Redis 密码（必须修改）
REDIS_PASSWORD=生成的强密码

# SECRET_KEY_BASE（必须修改）
SECRET_KEY_BASE=生成的随机密钥

# 运行环境
RAILS_ENV=production

# 默认语言
DEFAULT_LOCALE=zh_CN

# 禁用注册
ENABLE_ACCOUNT_SIGNUP=false
```

#### 生成强密码命令

在 PowerShell 中执行：
```powershell
# 生成数据库密码
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})

# 生成 SECRET_KEY_BASE（64 字节）
-join ((48..57) + (97..102) | Get-Random -Count 128 | % {[char]$_})
```

或在 Linux/Mac 中：
```bash
# 生成密码
openssl rand -base64 32 | tr -dc 'a-zA-Z0-9' | head -c 32

# 生成 SECRET_KEY_BASE
openssl rand -hex 64
```

---

### 3. Git 配置

#### 检查 `.gitignore`

确保 `.env` **不在** `.gitignore` 中（您已经移除了）：

```bash
# .gitignore 中应该没有这一行：
# .env
```

**⚠️ 注意：** 
- 如果是私有仓库，可以提交 `.env`
- 如果是公开仓库，**不要提交 `.env`**，在服务器上手动创建

---

## 📤 推送到 GitHub

### 步骤 1: 检查文件

```powershell
cd e:\chatwoot

# 查看将要提交的文件
git status
```

### 步骤 2: 添加文件

```powershell
# 添加所有修改的文件
git add .

# 或者选择性添加
git add docker-compose.fast.yaml
git add .env
git add lib/chatwoot_hub.rb
git add enterprise/
git add config/
git add public/brand-assets/
git add *.md
git add deploy-server.sh
```

### 步骤 3: 提交

```powershell
git commit -m "feat: 企业功能解锁和品牌定制配置

- 解锁所有企业功能
- 配置品牌定制
- 添加部署文档和脚本
- 添加自定义 Logo 和图标"
```

### 步骤 4: 推送到 GitHub

```powershell
# 如果是首次推送
git remote add origin https://github.com/Rookie-Adventures/chatwoot.git
git branch -M main
git push -u origin main

# 如果已经关联过
git push
```

---

## 🖥️ 服务器部署

### 步骤 1: SSH 登录服务器

```bash
ssh user@your-server-ip
```

### 步骤 2: 克隆仓库

```bash
# 安装 Git（如果没有）
sudo apt install git -y

# 克隆仓库
cd /opt
sudo git clone https://github.com/Rookie-Adventures/chatwoot.git
sudo chown -R $USER:$USER /opt/chatwoot
cd /opt/chatwoot
```

### 步骤 3: 验证文件

```bash
# 检查关键文件
ls -la docker-compose.fast.yaml
ls -la .env
ls -la lib/chatwoot_hub.rb
ls -la public/brand-assets/

# 检查图片文件
ls -la public/brand-assets/*.png
```

### 步骤 4: 修改 .env（如果需要）

```bash
nano .env

# 确认以下配置：
# FRONTEND_URL=https://chat.trikn.shop
# POSTGRES_PASSWORD=强密码
# REDIS_PASSWORD=强密码
```

### 步骤 5: 运行部署脚本

```bash
# 给脚本执行权限
chmod +x deploy-server.sh

# 运行脚本
sudo bash deploy-server.sh
```

---

## 📋 部署后检查清单

### 1. Cloudflare DNS 配置

- [ ] 添加 A 记录：`chat` → 服务器 IP
- [ ] 代理状态：DNS only（灰色云朵）
- [ ] DNS 已生效（`ping chat.trikn.shop`）

### 2. 服务器环境

- [ ] Docker 已安装
- [ ] Docker Compose 已安装
- [ ] Nginx 已安装
- [ ] Certbot 已安装
- [ ] Swap 已添加（2GB）
- [ ] 防火墙已配置

### 3. Chatwoot 服务

- [ ] 代码已克隆
- [ ] .env 配置正确
- [ ] 图片文件存在
- [ ] Docker 服务已启动
- [ ] 数据库已初始化

### 4. Nginx 和 SSL

- [ ] Nginx 配置已创建
- [ ] SSL 证书已获取
- [ ] HTTPS 可以访问

### 5. 功能验证

- [ ] 可以访问 https://chat.trikn.shop
- [ ] 管理员账户已创建
- [ ] 企业功能已解锁（/super_admin）
- [ ] 品牌配置已设置
- [ ] Logo 显示正常

---

## 🎨 品牌配置步骤

### 1. 访问超级管理员后台

```
https://chat.trikn.shop/super_admin/app_config?config=custom_branding
```

### 2. 填写配置

```
Installation Name: Trikn 客服
Brand Name: Trikn
Logo: /brand-assets/logo.png
Logo Dark Mode: /brand-assets/logo-dark.png
Logo Thumbnail: /brand-assets/favicon.png
Widget Brand URL: https://trikn.shop
Brand URL: https://trikn.shop
```

### 3. 保存并验证

- [ ] 标签页标题显示为 "Trikn 客服"
- [ ] 标签页图标显示为您的 favicon
- [ ] 登录页 Logo 显示正确
- [ ] 控制台左上角 Logo 显示正确
- [ ] 小部件底部显示 "由 Trikn 提供支持"

---

## 🔄 更新流程

### 本地修改后更新到服务器

```bash
# 本地
cd e:\chatwoot
git add .
git commit -m "更新说明"
git push

# 服务器
cd /opt/chatwoot
git pull
docker compose -f docker-compose.fast.yaml restart
```

---

## 🐛 常见问题

### Q1: 图片没有显示？

**检查：**
```bash
# 在服务器上
ls -la /opt/chatwoot/public/brand-assets/
docker compose -f docker-compose.fast.yaml exec rails ls -la /app/public/brand-assets/
```

**解决：**
```bash
# 重启服务
docker compose -f docker-compose.fast.yaml restart
```

### Q2: Git 推送失败？

**检查：**
```bash
# 检查远程仓库
git remote -v

# 检查分支
git branch
```

**解决：**
```bash
# 重新设置远程仓库
git remote set-url origin https://github.com/Rookie-Adventures/chatwoot.git

# 强制推送（谨慎使用）
git push -f origin main
```

### Q3: 服务器克隆失败？

**可能原因：** 私有仓库需要认证

**解决：**
```bash
# 使用 Personal Access Token
git clone https://YOUR_TOKEN@github.com/Rookie-Adventures/chatwoot.git

# 或配置 SSH 密钥
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
# 复制公钥到 GitHub Settings → SSH Keys
```

---

## 📚 相关文档

- `CLOUDFLARE-SETUP.md` - Cloudflare 配置指南
- `DEPLOY-TO-SERVER.md` - 服务器部署详细步骤
- `README.md` - 项目总览

---

**准备好后，就可以开始部署了！** 🚀
