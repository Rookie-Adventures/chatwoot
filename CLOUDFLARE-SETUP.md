# Cloudflare + Chatwoot 配置指南

## 🌐 Cloudflare DNS 配置

### 步骤 1: 添加 A 记录

登录 Cloudflare → 选择域名 `trikn.shop` → DNS 记录

添加以下记录：

```
类型: A
名称: chat
IPv4 地址: 您的服务器公网 IP
代理状态: DNS only（灰色云朵）⚠️ 重要！
TTL: Auto
```

**⚠️ 重要：首次配置时必须选择 "DNS only"（灰色云朵），不要开启代理！**

原因：
- 需要先获取 SSL 证书
- Certbot 需要直接访问服务器
- 证书获取后可以开启 Cloudflare 代理

---

## 🔐 SSL 证书配置

### 方案 A: 使用 Let's Encrypt（推荐）

**步骤：**

1. **Cloudflare DNS 设置为 "DNS only"（灰色云朵）**

2. **在服务器上获取证书**
   ```bash
   sudo certbot --nginx -d chat.trikn.shop
   ```

3. **证书获取成功后，可以选择性开启 Cloudflare 代理**
   - 回到 Cloudflare DNS 设置
   - 点击云朵图标，变为橙色（代理已启用）

4. **Cloudflare SSL/TLS 设置**
   - 进入 SSL/TLS → 概述
   - 加密模式选择：**Full (strict)** ⭐

### 方案 B: 使用 Cloudflare Origin Certificate（高级）

如果开启了 Cloudflare 代理，可以使用 Cloudflare 的源证书：

1. **生成 Origin Certificate**
   - Cloudflare → SSL/TLS → Origin Server
   - Create Certificate
   - 保存证书和私钥

2. **在服务器上配置**
   ```bash
   # 保存证书
   sudo nano /etc/ssl/certs/cloudflare-origin.pem
   # 粘贴证书内容
   
   # 保存私钥
   sudo nano /etc/ssl/private/cloudflare-origin.key
   # 粘贴私钥内容
   
   # 设置权限
   sudo chmod 644 /etc/ssl/certs/cloudflare-origin.pem
   sudo chmod 600 /etc/ssl/private/cloudflare-origin.key
   ```

3. **修改 Nginx 配置**
   ```nginx
   ssl_certificate /etc/ssl/certs/cloudflare-origin.pem;
   ssl_certificate_key /etc/ssl/private/cloudflare-origin.key;
   ```

---

## ⚙️ Cloudflare 推荐设置

### 1. SSL/TLS 设置

```
SSL/TLS → 概述
├── 加密模式: Full (strict) ⭐
└── 始终使用 HTTPS: 开启 ✅
```

### 2. 速度优化

```
速度 → 优化
├── Auto Minify: 开启 HTML, CSS, JS ✅
├── Brotli: 开启 ✅
└── Rocket Loader: 关闭 ❌ (可能影响 Chatwoot)
```

### 3. 缓存设置

```
缓存 → 配置
├── 缓存级别: 标准 ✅
└── 浏览器缓存 TTL: 4 小时 ✅
```

**⚠️ 重要：** 添加页面规则，排除 Chatwoot API：

```
页面规则 → 创建页面规则

URL: chat.trikn.shop/api/*
设置:
  - 缓存级别: Bypass
  - 禁用性能
```

### 4. 防火墙规则（可选）

```
安全性 → WAF
├── 托管规则: 开启 ✅
└── 速率限制: 可选配置
```

---

## 🔄 推荐配置流程

### 初次部署（推荐）：

1. **Cloudflare DNS: DNS only（灰色云朵）**
2. **部署 Chatwoot 到服务器**
3. **使用 Certbot 获取 Let's Encrypt 证书**
4. **验证 HTTPS 正常工作**
5. **（可选）开启 Cloudflare 代理（橙色云朵）**
6. **Cloudflare SSL 模式改为 Full (strict)**

### 已有证书（高级）：

1. **Cloudflare DNS: 代理已启用（橙色云朵）**
2. **使用 Cloudflare Origin Certificate**
3. **Cloudflare SSL 模式: Full (strict)**

---

## 🐛 常见问题

### Q1: 开启 Cloudflare 代理后，Certbot 续期失败？

**解决：**
```bash
# 方法 1: 临时关闭代理
# 在 Cloudflare 关闭代理 → 续期 → 重新开启代理

# 方法 2: 使用 DNS 验证
sudo certbot certonly --dns-cloudflare -d chat.trikn.shop
```

### Q2: 502 Bad Gateway 错误？

**原因：** Cloudflare SSL 模式设置错误

**解决：**
- 确保 Cloudflare SSL 模式为 **Full (strict)**
- 确保服务器有有效的 SSL 证书

### Q3: WebSocket 连接失败？

**解决：**
Cloudflare 默认支持 WebSocket，但需要确保：
- SSL 模式为 Full (strict)
- 没有启用 Rocket Loader

---

## 📊 配置对比

| 配置 | 优点 | 缺点 | 推荐 |
|------|------|------|------|
| DNS only + Let's Encrypt | 简单、免费 | 无 CDN 加速 | ⭐⭐⭐ 初学者 |
| 代理 + Origin Cert | CDN 加速、DDoS 防护 | 配置复杂 | ⭐⭐ 高级用户 |

---

## ✅ 推荐配置（最简单）

```
1. Cloudflare DNS: DNS only（灰色云朵）
2. 服务器: Let's Encrypt 证书
3. Nginx: 标准 HTTPS 配置
4. 测试成功后，可选开启 Cloudflare 代理
```

这样配置最稳定，也最容易排查问题。

---

## 🔍 验证配置

### 检查 DNS
```bash
nslookup chat.trikn.shop
# 应该返回您的服务器 IP
```

### 检查 SSL
```bash
curl -I https://chat.trikn.shop
# 应该返回 200 OK
```

### 检查 WebSocket
在浏览器控制台：
```javascript
new WebSocket('wss://chat.trikn.shop/cable')
// 应该成功连接
```

---

## 📝 Nginx 配置（配合 Cloudflare）

```nginx
server {
  listen 443 ssl http2;
  server_name chat.trikn.shop;

  # SSL 证书
  ssl_certificate /etc/letsencrypt/live/chat.trikn.shop/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/chat.trikn.shop/privkey.pem;

  # 信任 Cloudflare IP（如果开启了代理）
  set_real_ip_from 173.245.48.0/20;
  set_real_ip_from 103.21.244.0/22;
  set_real_ip_from 103.22.200.0/22;
  set_real_ip_from 103.31.4.0/22;
  set_real_ip_from 141.101.64.0/18;
  set_real_ip_from 108.162.192.0/18;
  set_real_ip_from 190.93.240.0/20;
  set_real_ip_from 188.114.96.0/20;
  set_real_ip_from 197.234.240.0/22;
  set_real_ip_from 198.41.128.0/17;
  set_real_ip_from 162.158.0.0/15;
  set_real_ip_from 104.16.0.0/13;
  set_real_ip_from 104.24.0.0/14;
  set_real_ip_from 172.64.0.0/13;
  set_real_ip_from 131.0.72.0/22;
  real_ip_header CF-Connecting-IP;

  # 其他配置...
}
```

---

**推荐：先用 DNS only 模式部署，成功后再考虑开启 Cloudflare 代理。** ✅
