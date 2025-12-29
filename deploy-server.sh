#!/bin/bash
# Chatwoot 服务器一键部署脚本
# 适用于 Ubuntu 24.04

set -e

echo "=========================================="
echo "Chatwoot 服务器部署脚本"
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

# 步骤 1: 更新系统
echo -e "${GREEN}[1/10] 更新系统...${NC}"
apt update && apt upgrade -y

# 步骤 2: 安装 Docker
echo -e "${GREEN}[2/10] 安装 Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    systemctl start docker
    systemctl enable docker
    echo -e "${GREEN}Docker 安装完成${NC}"
else
    echo -e "${YELLOW}Docker 已安装${NC}"
fi

# 步骤 3: 安装 Docker Compose
echo -e "${GREEN}[3/10] 安装 Docker Compose...${NC}"
apt install docker-compose-plugin -y

# 步骤 4: 安装 Nginx 和 Certbot
echo -e "${GREEN}[4/10] 安装 Nginx 和 Certbot...${NC}"
apt install nginx certbot python3-certbot-nginx -y

# 步骤 5: 创建 Swap（2GB）
echo -e "${GREEN}[5/10] 创建 Swap...${NC}"
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

# 步骤 6: 创建项目目录
echo -e "${GREEN}[6/10] 创建项目目录...${NC}"
mkdir -p /opt/chatwoot
chown $SUDO_USER:$SUDO_USER /opt/chatwoot

# 步骤 7: 配置防火墙
echo -e "${GREEN}[7/10] 配置防火墙...${NC}"
ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 22/tcp
ufw --force enable

echo ""
echo -e "${GREEN}=========================================="
echo "基础环境安装完成！"
echo "==========================================${NC}"
echo ""
echo -e "${YELLOW}下一步操作：${NC}"
echo "1. 上传项目文件到 /opt/chatwoot"
echo "2. 配置 .env 文件"
echo "3. 运行: cd /opt/chatwoot && docker compose -f docker-compose.fast.yaml up -d"
echo "4. 初始化数据库: docker compose -f docker-compose.fast.yaml exec rails bundle exec rails db:chatwoot_prepare"
echo "5. 配置 Nginx 和 SSL"
echo ""
echo -e "${GREEN}详细步骤请查看 DEPLOY-TO-SERVER.md${NC}"
echo ""
