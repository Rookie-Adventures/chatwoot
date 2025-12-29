#!/bin/bash
# Chatwoot 完整一键部署脚本
# 包含环境安装、Nginx 配置、SSL 证书获取

set -e

echo "=========================================="
echo "Chatwoot 完整一键部署脚本"
echo "=========================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
   echo -e "${RED}请使用 sudo 运行此脚本${NC}"
   exit 1
fi

# 获取域名（可以修改）
DOMAIN="chat.trikn.shop"
EMAIL="ruciwunai@gmail.com"  # 用于 SSL 证书

echo -e "${YELLOW}域名: $DOMAIN${NC}"
echo -e "${YELLOW}邮箱: $EMAIL${NC}"
echo ""

# ==========================================
# 步骤 1: 更新系统
# ==========================================
echo -e "${GREEN}[1/12] 更新系统...${NC}"
apt update && apt upgrade -y

# ==========================================
# 步骤 2: 安装 Docker
# ==========================================
echo -e "${GREEN}[2/12] 安装 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}Docker 安装完成${NC}"
else
    echo -e "${YELLOW}Docker 已安装${NC}"
fi

# ==========================================
# 步骤 3: 安装 Docker Compose
# ==========================================
echo -e "${GREEN}[3/12] 安装 Docker Compose...${NC}"
apt install docker-compose-plugin -y

# ==========================================
# 步骤 4: 安装 Nginx 和 Certbot
# ==========================================
echo -e "${GREEN}[4/12] 安装 Nginx 和 Certbot...${NC}"
apt install nginx certbot python3-certbot-nginx -y

# ==========================================
# 步骤 5: 创建 Swap（2GB）
# ==========================================
echo -e "${GREEN}[5/12] 创建 Swap...${NC}"
if [ ! -f /swapfile ]; then
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' >> /etc/fstab
    echo -e "${GREEN}Swap 创建完成${NC}"
else
    echo -e "${YELLOW}Swap 已存在${NC}"
fi

# ==========================================
# 步骤 6: 配置防火墙
# ==========================================
echo -e "${GREEN}[6/12] 配置防火墙...${NC}"
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw --force enable

# ==========================================
# 步骤 7: 检查代码目录
# ==========================================
echo -e "${GREEN}[7/12] 检查代码目录...${NC}"
if [ ! -d "/opt/chatwoot" ]; then
    echo -e "${RED}错误: /opt/chatwoot 目录不存在${NC}"
    echo -e "${YELLOW}请先克隆代码：${NC}"
    echo "cd /opt"
    echo "git clone https://github.com/Rookie-Adventures/chatwoot.git"
    exit 1
fi

cd /opt/chatwoot

# ==========================================
# 步骤 8: 配置 Nginx
# ==========================================
echo -e "${GREEN}[8/12] 配置 Nginx...${NC}"

# 复制 Nginx 配置文件
if [ -f "nginx-chatwoot.conf" ]; then
    cp nginx-chatwoot.conf /etc/nginx/sites-available/chatwoot
    
    # 创建软链接
    ln -sf /etc/nginx/sites-available/chatwoot /etc/nginx/sites-enabled/
    
    # 删除默认配置
    rm -f /etc/nginx/sites-enabled/default
    
    # 测试配置
    nginx -t
    
    # 重载 Nginx
    systemctl reload nginx
    
    echo -e "${GREEN}Nginx 配置完成${NC}"
else
    echo -e "${RED}错误: nginx-chatwoot.conf 文件不存在${NC}"
    exit 1
fi

# ==========================================
# 步骤 9: 启动 Chatwoot 服务
# ==========================================
echo -e "${GREEN}[9/12] 启动 Chatwoot 服务...${NC}"

# 检查 .env 文件
if [ ! -f ".env" ]; then
    echo -e "${RED}错误: .env 文件不存在${NC}"
    exit 1
fi

# 启动 Docker 服务
docker compose -f docker-compose.fast.yaml up -d

# 等待服务启动
echo -e "${YELLOW}等待服务启动（30秒）...${NC}"
sleep 30

# ==========================================
# 步骤 10: 初始化数据库
# ==========================================
echo -e "${GREEN}[10/12] 初始化数据库...${NC}"
docker compose -f docker-compose.fast.yaml exec -T rails bundle exec rails db:chatwoot_prepare

# ==========================================
# 步骤 11: 获取 SSL 证书
# ==========================================
echo -e "${GREEN}[11/12] 获取 SSL 证书...${NC}"

# 检查证书是否已存在
if [ ! -d "/etc/letsencrypt/live/$DOMAIN" ]; then
    echo -e "${YELLOW}正在获取 SSL 证书...${NC}"
    certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $EMAIL
    echo -e "${GREEN}SSL 证书获取成功${NC}"
else
    echo -e "${YELLOW}SSL 证书已存在${NC}"
fi

# ==========================================
# 步骤 12: 验证部署
# ==========================================
echo -e "${GREEN}[12/12] 验证部署...${NC}"

# 检查服务状态
echo -e "${YELLOW}Docker 服务状态：${NC}"
docker compose -f docker-compose.fast.yaml ps

echo ""
echo -e "${GREEN}=========================================="
echo "部署完成！"
echo "==========================================${NC}"
echo ""
echo -e "${GREEN}✅ 访问地址: https://$DOMAIN${NC}"
echo ""
echo -e "${YELLOW}下一步操作：${NC}"
echo "1. 访问 https://$DOMAIN"
echo "2. 创建管理员账户"
echo "3. 访问 https://$DOMAIN/super_admin 验证企业功能"
echo "4. 配置品牌: https://$DOMAIN/super_admin/app_config?config=custom_branding"
echo ""
echo -e "${YELLOW}常用命令：${NC}"
echo "查看日志: cd /opt/chatwoot && docker compose -f docker-compose.fast.yaml logs -f"
echo "重启服务: cd /opt/chatwoot && docker compose -f docker-compose.fast.yaml restart"
echo "停止服务: cd /opt/chatwoot && docker compose -f docker-compose.fast.yaml down"
echo ""
