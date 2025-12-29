# Chatwoot 品牌定制指南

## 📋 需求清单

1. ✅ 通过变量设置标签页名称
2. ✅ 通过变量修改小部件底部的 "由 *** 提供支持"
3. ✅ 通过变量修改品牌链接
4. ✅ 替换标签页图标（favicon）

---

## 🎯 实施方案

### 方案特点
- ✅ **改动小**：只需修改 2 个配置文件 + 1 个图标文件
- ✅ **实现简单**：不需要写代码，只改配置
- ✅ **彻底有效**：修改后不会被重置

---

## 📝 详细步骤

### 步骤 1：修改两个配置文件

**为什么要修改两个文件？**

Chatwoot 社区版有一个自动重置机制：
- 定时任务会检查版本更新
- 检查时会将品牌配置重置为 `enterprise/config/premium_installation_config.yml` 中的默认值
- 所以必须**同时修改两个文件**，才能防止被重置

#### 文件 1：`config/installation_config.yml`

找到以下配置项并修改：

```yaml
# 标签页标题
- name: INSTALLATION_NAME
  value: 'Trikn 客服'  # 改成您的品牌名

# 品牌名称（小部件底部显示）
- name: BRAND_NAME
  value: 'Trikn'  # 改成您的品牌名

# 品牌链接（小部件底部点击跳转）
- name: WIDGET_BRAND_URL
  value: 'https://trikn.shop'  # 改成您的网站

# 邮件中的品牌链接
- name: BRAND_URL
  value: 'https://trikn.shop'  # 改成您的网站
```

#### 文件 2：`enterprise/config/premium_installation_config.yml`

**重要！** 同步修改这个文件，防止被重置：

```yaml
# 标签页标题
- name: INSTALLATION_NAME
  value: 'Trikn 客服'  # 与上面保持一致

# 品牌名称
- name: BRAND_NAME
  value: 'Trikn'  # 与上面保持一致

# 品牌链接
- name: WIDGET_BRAND_URL
  value: 'https://trikn.shop'  # 与上面保持一致

- name: BRAND_URL
  value: 'https://trikn.shop'  # 与上面保持一致
```

---

### 步骤 2：替换标签页图标

#### 方法 A：使用 .ico 文件（推荐）

```bash
# 1. 准备您的图标文件（.ico 格式，推荐 32x32 或 16x16）
# 2. 替换文件
cp your-icon.ico public/favicon.ico
```

**在线转换工具：**
- https://www.favicon-generator.org/
- https://realfavicongenerator.net/

#### 方法 B：使用 SVG 文件

修改配置文件：
```yaml
- name: LOGO_THUMBNAIL
  value: '/brand-assets/your-logo.svg'  # 512x512px
```

然后替换文件：
```bash
cp your-logo.svg public/brand-assets/logo_thumbnail.svg
```

---

### 步骤 3：使用自动化脚本（可选）

我已经为您创建了自动化脚本 `customize-brand.sh`：

```bash
# 1. 编辑脚本，修改品牌信息
nano customize-brand.sh

# 修改这些变量：
BRAND_NAME="Trikn"
INSTALLATION_NAME="Trikn 客服"
BRAND_URL="https://trikn.shop"

# 2. 运行脚本
chmod +x customize-brand.sh
./customize-brand.sh
```

---

## 🐳 构建和部署

### 1. 提交代码

```bash
git add .
git commit -m "feat: 自定义品牌配置"
git push origin main
```

### 2. 构建 Docker 镜像

```bash
# 构建镜像
docker build -t your-dockerhub-username/chatwoot-custom:v1.0 .

# 推送到 Docker Hub
docker login
docker push your-dockerhub-username/chatwoot-custom:v1.0
```

### 3. 修改 docker-compose.yml

```yaml
services:
  base: &base
    # 使用您自己的镜像
    image: your-dockerhub-username/chatwoot-custom:v1.0
    # ... 其他配置保持不变
```

### 4. 部署到服务器

```bash
# 在服务器上
docker-compose pull
docker-compose up -d

# 初始化数据库（首次部署）
docker-compose exec rails bundle exec rails db:chatwoot_prepare
```

---

## 🔍 验证修改

### 1. 检查标签页标题

打开浏览器，访问您的 Chatwoot 实例，查看浏览器标签页标题是否变为 "Trikn 客服"。

### 2. 检查小部件品牌

在网站上打开聊天小部件，查看底部是否显示 "由 Trikn 提供支持"。

### 3. 检查品牌链接

点击小部件底部的品牌文字，确认跳转到您的网站。

---

## ❓ 常见问题

### Q1: 修改后没有生效？

**原因：** 可能是缓存问题

**解决：**
```bash
# 清除 Rails 缓存
docker-compose exec rails bundle exec rails cache:clear

# 重启服务
docker-compose restart rails

# 清除浏览器缓存（Ctrl + Shift + Delete）
```

### Q2: 配置被重置回 Chatwoot？

**原因：** 只修改了 `installation_config.yml`，没有修改 `premium_installation_config.yml`

**解决：** 按照步骤 1，同时修改两个配置文件

### Q3: 图标没有变化？

**原因：** 浏览器缓存了旧图标

**解决：**
```bash
# 1. 强制刷新（Ctrl + F5）
# 2. 清除浏览器缓存
# 3. 使用隐私模式测试
```

---

## 📊 修改对比

| 配置项 | 默认值 | 修改后 |
|--------|--------|--------|
| 标签页标题 | Chatwoot | Trikn 客服 |
| 小部件品牌 | 由 Chatwoot 支持 | 由 Trikn 提供支持 |
| 品牌链接 | https://www.chatwoot.com | https://trikn.shop |
| 标签页图标 | Chatwoot Logo | 您的 Logo |

---

## 🎉 总结

通过以上步骤，您可以：

1. ✅ 完全控制品牌显示
2. ✅ 不受企业版限制
3. ✅ 修改不会被重置
4. ✅ 改动小、实现简单、效果彻底

**下一步：**
- 运行 `customize-brand.sh` 脚本
- 替换 `public/favicon.ico` 图标
- 构建并部署自定义镜像

祝您部署顺利！🚀
