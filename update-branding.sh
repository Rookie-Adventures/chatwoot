#!/bin/bash
# Chatwoot 品牌配置脚本
# 直接修改数据库中的品牌配置

echo "=========================================="
echo "Chatwoot 品牌配置脚本"
echo "=========================================="
echo ""

# 配置您的品牌信息
INSTALLATION_NAME="Trikn 客服"
BRAND_NAME="Trikn"
BRAND_URL="https://trikn.shop"
WIDGET_BRAND_URL="https://trikn.shop"
LOGO="/brand-assets/logo.png"
LOGO_DARK="/brand-assets/logo-dark.png"
LOGO_THUMBNAIL="/brand-assets/favicon.png"

echo "品牌名称: $BRAND_NAME"
echo "安装名称: $INSTALLATION_NAME"
echo "品牌链接: $BRAND_URL"
echo ""

# 进入 Rails 控制台执行配置
docker compose -f docker-compose.fast.yaml exec -T rails bundle exec rails runner "
# 更新品牌配置
configs = {
  'INSTALLATION_NAME' => '$INSTALLATION_NAME',
  'BRAND_NAME' => '$BRAND_NAME',
  'BRAND_URL' => '$BRAND_URL',
  'WIDGET_BRAND_URL' => '$WIDGET_BRAND_URL',
  'LOGO' => '$LOGO',
  'LOGO_DARK' => '$LOGO_DARK',
  'LOGO_THUMBNAIL' => '$LOGO_THUMBNAIL'
}

configs.each do |name, value|
  config = InstallationConfig.find_or_create_by(name: name)
  config.update!(value: value, locked: false)
  puts \"✅ 已更新: #{name} = #{value}\"
end

puts \"\"
puts \"🎉 品牌配置更新完成！\"
puts \"\"
puts \"请刷新浏览器查看效果\"
"

echo ""
echo "=========================================="
echo "配置完成！"
echo "=========================================="
echo ""
echo "下一步："
echo "1. 刷新浏览器"
echo "2. 查看标签页标题是否变为 '$INSTALLATION_NAME'"
echo "3. 查看 Logo 是否显示正确"
echo ""
