# 服务器部署文件清单

## 📦 需要上传到服务器的文件

### 必须文件（核心功能）

```
/opt/chatwoot/
├── docker-compose.fast.yaml                    # Docker 配置文件
├── .env                                        # 环境变量配置
├── lib/
│   └── chatwoot_hub.rb                        # 企业功能解锁
├── enterprise/
│   ├── app/services/internal/
│   │   └── reconcile_plan_config_service.rb  # 禁用配置重置
│   └── config/
│       └── premium_installation_config.yml    # 企业配置
└── config/
    └── installation_config.yml                # 安装配置
```

### 可选文件（品牌定制）

```
/opt/chatwoot/
└── public/
    └── brand-assets/                          # 您的 Logo 和图标
        ├── logo.png                           # 主 Logo
        ├── logo-dark.png                      # 深色模式 Logo
        └── favicon.png                        # 浏览器图标
```

---

## 📋 上传方法

### 方法 1: 使用 SCP（推荐）

在本地 Windows PowerShell 中执行：

```powershell
# 上传整个项目（不包括 node_modules 等）
scp -r e:\chatwoot\docker-compose.fast.yaml user@your-server-ip:/opt/chatwoot/
scp -r e:\chatwoot\.env user@your-server-ip:/opt/chatwoot/
scp -r e:\chatwoot\lib user@your-server-ip:/opt/chatwoot/
scp -r e:\chatwoot\enterprise user@your-server-ip:/opt/chatwoot/
scp -r e:\chatwoot\config user@your-server-ip:/opt/chatwoot/
scp -r e:\chatwoot\public\brand-assets user@your-server-ip:/opt/chatwoot/public/
```

### 方法 2: 使用 Git

```bash
# 在本地提交代码
cd e:\chatwoot
git add .
git commit -m "准备部署到服务器"
git push origin main

# 在服务器上克隆
cd /opt
git clone https://github.com/YOUR_USERNAME/chatwoot.git
```

### 方法 3: 使用 SFTP 客户端

推荐工具：
- WinSCP (Windows)
- FileZilla
- VS Code Remote SSH

---

## ⚠️ 注意事项

### 1. .env 文件安全
上传前确保 `.env` 文件中的密码已修改为强密码：
```bash
POSTGRES_PASSWORD=生成的强密码
REDIS_PASSWORD=生成的强密码
SECRET_KEY_BASE=生成的随机密钥
```

### 2. 文件权限
上传后在服务器上设置正确的权限：
```bash
cd /opt/chatwoot
chmod 600 .env
chmod +x deploy-server.sh
```

### 3. 域名配置
确保 `.env` 中的 `FRONTEND_URL` 已修改为您的域名：
```bash
FRONTEND_URL=https://chat.trikn.shop
```

---

## 🔍 验证文件完整性

在服务器上执行：

```bash
cd /opt/chatwoot

# 检查必须文件
ls -la docker-compose.fast.yaml
ls -la .env
ls -la lib/chatwoot_hub.rb
ls -la enterprise/app/services/internal/reconcile_plan_config_service.rb
ls -la config/installation_config.yml
ls -la enterprise/config/premium_installation_config.yml

# 检查品牌资源（如果有）
ls -la public/brand-assets/
```

所有文件都应该存在且可读。

---

## 📊 文件大小参考

```
docker-compose.fast.yaml    ~2 KB
.env                        ~10 KB
lib/chatwoot_hub.rb        ~5 KB
reconcile_plan_config_service.rb  ~2 KB
installation_config.yml    ~20 KB
premium_installation_config.yml   ~1 KB
```

如果文件大小差异很大，可能上传不完整。

---

## 🚀 上传后的下一步

1. ✅ 验证文件完整性
2. ✅ 修改 .env 配置
3. ✅ 运行部署脚本或手动部署
4. ✅ 配置 Nginx 和 SSL
5. ✅ 访问并测试

详细步骤请查看 `DEPLOY-TO-SERVER.md`
