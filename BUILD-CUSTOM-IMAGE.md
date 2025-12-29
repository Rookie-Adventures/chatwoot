# Chatwoot 自定义镜像构建和部署指南

## 🎯 为什么要构建自定义镜像？

### 官方镜像 vs 自定义镜像

| 对比项 | 官方镜像 | 自定义镜像 |
|--------|---------|-----------|
| 品牌定制 | ❌ 无效 | ✅ 有效 |
| 配置文件修改 | ❌ 被覆盖 | ✅ 保留 |
| 代码修改 | ❌ 无法修改 | ✅ 完全控制 |
| 更新控制 | ⚠️ 自动更新 | ✅ 主动控制 |

**结论：要让品牌定制生效，必须构建自定义镜像！**

---

## 🚀 方案一：本地构建和部署（推荐用于测试）

### 步骤 1: 构建镜像

```bash
# 使用自定义配置构建
docker-compose -f docker-compose.custom.yaml build

# 构建时间：首次约 10-20 分钟
```

### 步骤 2: 启动服务

```bash
docker-compose -f docker-compose.custom.yaml up -d
```

### 步骤 3: 初始化数据库

```bash
docker-compose -f docker-compose.custom.yaml exec rails bundle exec rails db:chatwoot_prepare
```

### 步骤 4: 访问应用

```
http://localhost:3000
```

---

## 🐳 方案二：推送到 Docker Hub（推荐用于生产）

### 步骤 1: 构建镜像

```bash
# 构建并打标签
docker build -t your-dockerhub-username/chatwoot-trikn:v1.0 -f docker/Dockerfile .

# 或使用 docker-compose 构建
docker-compose -f docker-compose.custom.yaml build
docker tag chatwoot-trikn:local your-dockerhub-username/chatwoot-trikn:v1.0
```

### 步骤 2: 推送到 Docker Hub

```bash
# 登录 Docker Hub
docker login

# 推送镜像
docker push your-dockerhub-username/chatwoot-trikn:v1.0
```

### 步骤 3: 在服务器上使用

修改 `docker-compose.production.yaml`：
```yaml
services:
  base: &base
    # 使用您的自定义镜像
    image: your-dockerhub-username/chatwoot-trikn:v1.0
    # ... 其他配置
```

然后在服务器上：
```bash
docker-compose -f docker-compose.production.yaml pull
docker-compose -f docker-compose.production.yaml up -d
```

---

## 📋 方案对比

### 方案一：本地构建
**优点：**
- ✅ 快速测试
- ✅ 不需要 Docker Hub 账号
- ✅ 适合开发调试

**缺点：**
- ⚠️ 每次部署都要重新构建
- ⚠️ 镜像只在本地
- ⚠️ 不适合多服务器部署

### 方案二：Docker Hub
**优点：**
- ✅ 一次构建，多处部署
- ✅ 版本管理清晰
- ✅ 适合生产环境
- ✅ 团队协作方便

**缺点：**
- ⚠️ 需要 Docker Hub 账号
- ⚠️ 公开仓库会暴露代码（可用私有仓库）

---

## 🔧 使用阿里云容器镜像服务（国内推荐）

### 步骤 1: 登录阿里云镜像仓库

```bash
docker login --username=your-username registry.cn-hangzhou.aliyuncs.com
```

### 步骤 2: 构建并推送

```bash
# 构建镜像
docker build -t registry.cn-hangzhou.aliyuncs.com/your-namespace/chatwoot-trikn:v1.0 -f docker/Dockerfile .

# 推送镜像
docker push registry.cn-hangzhou.aliyuncs.com/your-namespace/chatwoot-trikn:v1.0
```

### 步骤 3: 在服务器上使用

```yaml
services:
  base: &base
    image: registry.cn-hangzhou.aliyuncs.com/your-namespace/chatwoot-trikn:v1.0
```

---

## 📝 当前已完成的修改

### 1. 品牌配置
- ✅ `config/installation_config.yml`
  - `INSTALLATION_NAME`: 'Trikn 客服'
  - `BRAND_NAME`: 'Trikn'
  - `WIDGET_BRAND_URL`: 'https://trikn.shop'

- ✅ `enterprise/config/premium_installation_config.yml`
  - 同步修改，防止被重置

### 2. 前端组件（可选）
- ⚠️ `app/javascript/widget/components/layouts/ViewWithHeader.vue`
  - 如果想完全移除品牌标语，需要注释掉 Branding 组件

### 3. 图标文件（待替换）
- ⏳ `public/favicon-*.png` - 标签页图标

---

## 🎯 推荐流程

### 本地测试流程：
```bash
# 1. 构建自定义镜像
docker-compose -f docker-compose.custom.yaml build

# 2. 启动服务
docker-compose -f docker-compose.custom.yaml up -d

# 3. 初始化数据库
docker-compose -f docker-compose.custom.yaml exec rails bundle exec rails db:chatwoot_prepare

# 4. 测试品牌定制效果
# 访问 http://localhost:3000
```

### 生产部署流程：
```bash
# 1. 本地构建镜像
docker build -t your-registry/chatwoot-trikn:v1.0 -f docker/Dockerfile .

# 2. 推送到镜像仓库
docker push your-registry/chatwoot-trikn:v1.0

# 3. 在服务器上拉取并部署
# 修改 docker-compose.production.yaml 使用自定义镜像
docker-compose -f docker-compose.production.yaml pull
docker-compose -f docker-compose.production.yaml up -d
```

---

## ⏱️ 构建时间估算

### 首次构建
- **下载基础镜像**: 2-5 分钟
- **安装依赖**: 5-10 分钟
- **编译前端资源**: 3-5 分钟
- **总计**: 10-20 分钟

### 后续构建（有缓存）
- **增量构建**: 2-5 分钟

---

## 🐛 常见问题

### Q1: 构建失败，提示网络错误？

**解决：** 配置 Docker 镜像加速
```bash
# Docker Desktop → Settings → Docker Engine
# 添加镜像源：
{
  "registry-mirrors": [
    "https://docker.m.daocloud.io",
    "https://dockerproxy.com"
  ]
}
```

### Q2: 构建很慢？

**解决：** 使用构建缓存
```bash
# 使用 BuildKit 加速
DOCKER_BUILDKIT=1 docker build -t chatwoot-trikn:local -f docker/Dockerfile .
```

### Q3: 如何验证镜像包含了我的修改？

```bash
# 进入容器检查配置文件
docker run --rm -it chatwoot-trikn:local cat config/installation_config.yml | grep "BRAND_NAME"

# 应该显示: value: 'Trikn'
```

---

## 📊 镜像大小

- **官方镜像**: ~650MB
- **自定义镜像**: ~650MB（大小相同）

---

## 🎉 验证品牌定制

构建并启动后，检查：

1. ✅ 浏览器标签页显示 "Trikn 客服"
2. ✅ 小部件底部显示 "由 Trikn 提供支持"
3. ✅ 点击品牌链接跳转到 https://trikn.shop
4. ✅ 标签页图标（如果已替换）

---

## 📚 下一步

1. **本地测试**: 使用 `docker-compose.custom.yaml` 构建和测试
2. **替换图标**: 准备您的 favicon 文件
3. **推送镜像**: 推送到 Docker Hub 或阿里云
4. **生产部署**: 在服务器上使用自定义镜像

---

**现在开始构建自定义镜像吧！** 🚀

```bash
docker-compose -f docker-compose.custom.yaml build
```
