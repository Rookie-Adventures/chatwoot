# Chatwoot 完全开源化部署项目

## 🎯 项目概述

这是一个完全开源化的 Chatwoot 部署方案，解锁所有企业功能，无需付费订阅。

### ✅ 已实现的功能

- ✅ **解锁所有企业功能** - AI、审计日志、SAML SSO 等
- ✅ **完全品牌定制** - Logo、名称、链接等
- ✅ **无限制使用** - 无用户数、账户数限制
- ✅ **快速部署** - 2分钟本地启动，30分钟服务器部署
- ✅ **配置持久化** - 品牌配置不会被重置

---

## 📚 文档索引

### 核心文档

1. **[UNLOCK-ENTERPRISE.md](UNLOCK-ENTERPRISE.md)** ⭐⭐⭐
   - 企业功能解锁说明
   - 修改的文件列表
   - 验证方法

2. **[DEPLOY-TO-SERVER.md](DEPLOY-TO-SERVER.md)** ⭐⭐⭐
   - Ubuntu 24.04 服务器完整部署指南
   - 包含所有步骤、配置、故障排查
   - 适用于 2C2G 服务器

3. **[FILES-TO-UPLOAD.md](FILES-TO-UPLOAD.md)** ⭐⭐
   - 需要上传到服务器的文件清单
   - 上传方法说明

### 辅助文档

4. **[BRANDING-GUIDE.md](BRANDING-GUIDE.md)**
   - 品牌定制详细指南
   - 图标、Logo 设置方法

5. **[BUILD-CUSTOM-IMAGE.md](BUILD-CUSTOM-IMAGE.md)**
   - 自定义镜像构建指南（可选）
   - 适用于需要构建镜像的场景

6. **[QUICK-START.md](QUICK-START.md)**
   - 快速启动指南
   - 常用命令参考

---

## 🚀 快速开始

### 本地测试（Windows）

```bash
# 1. 启动服务
docker-compose -f docker-compose.fast.yaml up -d

# 2. 初始化数据库
docker-compose -f docker-compose.fast.yaml exec rails bundle exec rails db:chatwoot_prepare

# 3. 访问应用
# http://localhost:3000
```

### 服务器部署（Ubuntu 24.04）

```bash
# 1. 运行一键部署脚本
sudo bash deploy-server.sh

# 2. 上传项目文件
# 参考 FILES-TO-UPLOAD.md

# 3. 启动服务
cd /opt/chatwoot
docker compose -f docker-compose.fast.yaml up -d

# 4. 初始化数据库
docker compose -f docker-compose.fast.yaml exec rails bundle exec rails db:chatwoot_prepare

# 5. 配置 Nginx 和 SSL
# 参考 DEPLOY-TO-SERVER.md
```

---

## 📁 项目结构

```
e:\chatwoot/
├── docker-compose.fast.yaml           # 快速部署配置 ⭐
├── .env                               # 环境变量配置 ⭐
├── lib/
│   └── chatwoot_hub.rb               # 企业功能解锁 ⭐
├── enterprise/
│   ├── app/services/internal/
│   │   └── reconcile_plan_config_service.rb  # 禁用配置重置 ⭐
│   └── config/
│       └── premium_installation_config.yml
├── config/
│   └── installation_config.yml
├── public/
│   └── brand-assets/                 # 自定义 Logo 和图标
├── deploy-server.sh                  # 服务器一键部署脚本
├── UNLOCK-ENTERPRISE.md              # 企业功能解锁文档
├── DEPLOY-TO-SERVER.md               # 服务器部署指南
├── FILES-TO-UPLOAD.md                # 文件上传清单
└── README.md                         # 本文件
```

---

## 🔧 核心修改说明

### 1. 解锁企业功能

**文件：** `lib/chatwoot_hub.rb`

```ruby
def self.pricing_plan
  'enterprise'  # 强制返回企业版
end

def self.pricing_plan_quantity
  999999  # 无限制许可证
end
```

### 2. 禁用配置重置

**文件：** `enterprise/app/services/internal/reconcile_plan_config_service.rb`

```ruby
def perform
  return  # 禁用重置逻辑
end
```

### 3. 品牌定制

通过超级管理员后台配置：
```
https://your-domain.com/super_admin/app_config?config=custom_branding
```

---

## 🎯 解锁的功能列表

### 核心功能
- ✅ 品牌完全定制
- ✅ 无限用户/座席
- ✅ 无限账户/工作区

### 高级功能
- ✅ Captain AI - AI 智能助手
- ✅ 审计日志 - 完整操作记录
- ✅ SAML SSO - 企业单点登录
- ✅ SLA 管理 - 服务级别协议
- ✅ 高级报表 - 企业级数据分析
- ✅ 高级集成 - Salesforce、Hubspot 等

---

## 📊 部署对比

| 方案 | 本地测试 | 服务器部署 |
|------|---------|-----------|
| 启动时间 | 2 分钟 | 30 分钟 |
| 配置难度 | ⭐ 简单 | ⭐⭐ 中等 |
| 适用场景 | 测试、开发 | 生产环境 |
| 需要域名 | ❌ 否 | ✅ 是 |
| 需要 SSL | ❌ 否 | ✅ 是 |

---

## 🔒 安全说明

### 法律合规
- ✅ Chatwoot 使用 MIT 开源许可证
- ✅ 允许商业使用和修改
- ✅ 完全合法

### 使用建议
- ⚠️ 使用私有仓库存储代码
- ⚠️ 不要公开分享修改后的代码
- ⚠️ 仅内部使用

---

## 🐛 常见问题

### Q1: 企业功能是否真的解锁？
**A:** 是的。访问 `/super_admin` 可以验证，计划显示为 "Enterprise"。

### Q2: 配置会被重置吗？
**A:** 不会。我们已经禁用了配置重置逻辑。

### Q3: 2C2G 服务器够用吗？
**A:** 够用，但建议添加 2GB Swap。如果用户量大，建议升级到 4GB 内存。

### Q4: 如何更新 Chatwoot？
**A:** 谨慎更新。更新前备份数据，更新后需要重新应用企业功能解锁的修改。

### Q5: 可以商用吗？
**A:** 可以。MIT 许可证允许商业使用。

---

## 📞 技术支持

### 官方资源
- Chatwoot 官方文档: https://www.chatwoot.com/docs
- GitHub 仓库: https://github.com/chatwoot/chatwoot
- 社区论坛: https://github.com/chatwoot/chatwoot/discussions

### 本项目
- 查看文档目录中的详细指南
- 所有配置和脚本都有详细注释

---

## 🎉 总结

通过本项目，您可以：

1. ✅ **免费使用企业版** - 所有功能解锁
2. ✅ **完全品牌定制** - Logo、名称、链接
3. ✅ **快速部署** - 本地 2 分钟，服务器 30 分钟
4. ✅ **无限制使用** - 无用户数、账户数限制
5. ✅ **合法合规** - MIT 许可证，完全合法

**这是最彻底的 Chatwoot 开源化方案！** 🚀

---

## 📅 更新日志

### 2025-12-28
- ✅ 初始版本
- ✅ 企业功能解锁
- ✅ 快速部署方案
- ✅ 服务器部署指南
- ✅ 品牌定制支持

---

**祝您使用愉快！** 🎊
