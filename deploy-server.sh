#!/bin/bash
# Chatwoot 2GB RAM 优化版一键部署脚本
# 适用于 Ubuntu 22.04/24.04

set -e

echo "=========================================="
echo "Chatwoot 2GB 内存优化自研部署脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
   echo -e "${RED}请使用 sudo 运行此脚本${NC}"
   exit 1
fi

# 获取基础信息 (如有不同域名，请在这里修改或通过环境变量传入)
DOMAIN="${1:-chat.trikn.shop}"
EMAIL="${2:-ruciwunai@gmail.com}"

echo -e "${YELLOW}目标域名: $DOMAIN${NC}"
echo -e "${YELLOW}系统环境: Ubuntu (2GB RAM)${NC}"
echo ""

# 1. 强制开启 4G Swap (2GB 内存也得配，防止瞬时爆内存)
echo -e "${GREEN}[1/8] 开启 4GB 虚拟内存...${NC}"
if [ ! -f /swapfile ]; then
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "${GREEN}Swap 开启成功${NC}"
else
    echo -e "${YELLOW}Swap 已存在，跳过${NC}"
fi

# 2. 安装 Docker & Nginx
echo -e "${GREEN}[2/8] 检查并安装基础依赖...${NC}"
apt update

# 检查 Docker 是否已安装
if command -v docker &> /dev/null; then
    echo -e "${YELLOW}检测到 Docker 已安装 ($ (docker --version))，跳过 Docker 安装${NC}"
else
    echo -e "${YELLOW}正在安装 Docker...${NC}"
    if ! apt install -y docker.io docker-compose-plugin; then
        curl -fsSL https://get.docker.com -o get-docker.sh
        sh get-docker.sh
    fi
fi

# 确保安装 Nginx 和 Certbot (排除 docker 相关的包以防冲突)
apt install -y nginx certbot python3-certbot-nginx

systemctl start docker || true
systemctl enable docker || true
systemctl start nginx
systemctl enable nginx

# 3. 准备代码目录
echo -e "${GREEN}[3/8] 准备代码环境...${NC}"
mkdir -p /opt/chatwoot
# 如果当前目录就是仓库，直接拷贝过去；或者提醒执行 git pull
if [ -f "docker-compose.fast.yaml" ]; then
    echo -e "${YELLOW}检测到当前目录为仓库，正在安装到 /opt/chatwoot...${NC}"
    cp -r . /opt/chatwoot/
else
    echo -e "${RED}错误: 请在 chatwoot 仓库目录下运行此脚本${NC}"
    exit 1
fi

cd /opt/chatwoot

# 4. 配置 .env
echo -e "${GREEN}[4/8] 配置环境变量...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    # 填充关键配置
    sed -i "s|FRONTEND_URL=.*|FRONTEND_URL=https://$DOMAIN|g" .env
    sed -i "s|FORCE_SSL=.*|FORCE_SSL=true|g" .env
    # 针对 2GB 内存的性能优化
    sed -i "s|RAILS_MAX_THREADS=.*|RAILS_MAX_THREADS=3|g" .env
    sed -i "s|SIDEKIQ_CONCURRENCY=.*|SIDEKIQ_CONCURRENCY=10|g" .env
    
    # 生成随机密码防止 Postgres 启动失败
    PASS=$(openssl rand -hex 12)
    sed -i "s|POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=$PASS|g" .env
    echo -e "${GREEN}.env 配置完成 (已优化并发数)${NC}"
else
    echo -e "${YELLOW}.env 已存在，保留原配置${NC}"
fi

# 5. 启动容器
echo -e "${GREEN}[5/8] 启动 Docker 容器 (预编译版)...${NC}"
docker compose -f docker-compose.fast.yaml down || true
docker compose -f docker-compose.fast.yaml up -d

# 6. 数据库初始化 (关键步骤)
echo -e "${GREEN}[6/8] 初始化数据库表结构 (请耐心等待)...${NC}"
# 等待数据库冷启动
sleep 15
docker compose -f docker-compose.fast.yaml exec -T rails bundle exec rails db:chatwoot_prepare || {
    echo -e "${YELLOW}第一次尝试失败，再等10秒重试...${NC}"
    sleep 10
    docker compose -f docker-compose.fast.yaml exec -T rails bundle exec rails db:chatwoot_prepare
}

# 7. 配置 Nginx 转发
echo -e "${GREEN}[7/8] 配置 Nginx 反向代理...${NC}"
if [ -f "nginx-chatwoot-http.conf" ]; then
    cp nginx-chatwoot-http.conf /etc/nginx/sites-available/chatwoot
    ln -sf /etc/nginx/sites-available/chatwoot /etc/nginx/sites-enabled/
    rm -f /etc/nginx/sites-enabled/default
    nginx -t && systemctl reload nginx
    echo -e "${GREEN}Nginx 配置已应用 (含 CSRF 修复)${NC}"
fi

# 8. 申请 SSL
echo -e "${GREEN}[8/8] 申请 SSL 证书...${NC}"
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL || echo -e "${RED}SSL 申请失败，请手动运行 certbot --nginx${NC}"
else
    echo -e "${YELLOW}证书已存在${NC}"
fi

echo ""
echo -e "${GREEN}=========================================="
echo "🎉 部署大功告成！"
echo "==========================================${NC}"
echo -e "${YELLOW}访问地址: https://$DOMAIN${NC}"
echo -e "${YELLOW}超级后台: https://$DOMAIN/super_admin${NC}"
echo ""
echo -e "${YELLOW}常用指令：${NC}"
echo "查看实时日志: docker compose -f docker-compose.fast.yaml logs -f rails"
echo "重启所有服务: docker compose -f docker-compose.fast.yaml restart"
echo ""
