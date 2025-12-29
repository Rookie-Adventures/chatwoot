#!/bin/bash
# Chatwoot 品牌定制脚本
# 用途：一键修改品牌配置，防止被社区版重置逻辑覆盖

# 配置您的品牌信息
BRAND_NAME="Trikn"                    # 您的品牌名称
INSTALLATION_NAME="Trikn 客服"        # 标签页标题
BRAND_URL="https://trikn.shop"        # 品牌链接
WIDGET_BRAND_URL="https://trikn.shop" # 小部件品牌链接

echo "=========================================="
echo "Chatwoot 品牌定制脚本"
echo "=========================================="
echo ""
echo "品牌名称: $BRAND_NAME"
echo "标签页标题: $INSTALLATION_NAME"
echo "品牌链接: $BRAND_URL"
echo ""

# 1. 修改主配置文件
echo "📝 修改 config/installation_config.yml ..."
sed -i "s|value: 'Chatwoot'|value: '$BRAND_NAME'|g" config/installation_config.yml
sed -i "s|value: 'https://www.chatwoot.com'|value: '$BRAND_URL'|g" config/installation_config.yml

# 2. 修改企业版配置文件（防止被重置）
echo "📝 修改 enterprise/config/premium_installation_config.yml ..."
sed -i "s|value: 'Chatwoot'|value: '$BRAND_NAME'|g" enterprise/config/premium_installation_config.yml
sed -i "s|value: 'https://www.chatwoot.com'|value: '$BRAND_URL'|g" enterprise/config/premium_installation_config.yml

echo ""
echo "✅ 配置文件修改完成！"
echo ""
echo "📋 后续步骤："
echo "1. 替换 public/favicon.ico 为您的图标"
echo "2. 提交代码: git add . && git commit -m 'feat: 品牌定制'"
echo "3. 构建镜像: docker build -t your-registry/chatwoot-custom:v1.0 ."
echo "4. 推送镜像: docker push your-registry/chatwoot-custom:v1.0"
echo ""
echo "=========================================="
