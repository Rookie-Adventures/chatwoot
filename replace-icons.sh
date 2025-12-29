#!/bin/bash
# Chatwoot 图标替换脚本
# 用途：从一个源图标生成所有尺寸的 favicon

# 使用 ImageMagick 从源图标生成各种尺寸
# 安装: sudo apt install imagemagick

SOURCE_ICON="your-logo.png"  # 您的源图标（推荐 512x512 或更大）

if [ ! -f "$SOURCE_ICON" ]; then
    echo "❌ 错误: 找不到源图标文件 $SOURCE_ICON"
    echo "请将您的图标文件放在当前目录，并命名为 your-logo.png"
    exit 1
fi

echo "=========================================="
echo "Chatwoot 图标替换脚本"
echo "=========================================="
echo ""
echo "源图标: $SOURCE_ICON"
echo ""

# 创建临时目录
mkdir -p temp_icons

# 生成各种尺寸的图标
echo "📝 生成 favicon 图标..."
convert "$SOURCE_ICON" -resize 16x16 public/favicon-16x16.png
convert "$SOURCE_ICON" -resize 32x32 public/favicon-32x32.png
convert "$SOURCE_ICON" -resize 96x96 public/favicon-96x96.png
convert "$SOURCE_ICON" -resize 512x512 public/favicon-512x512.png

echo "📝 生成 Apple 图标..."
convert "$SOURCE_ICON" -resize 57x57 public/apple-icon-57x57.png
convert "$SOURCE_ICON" -resize 60x60 public/apple-icon-60x60.png
convert "$SOURCE_ICON" -resize 72x72 public/apple-icon-72x72.png
convert "$SOURCE_ICON" -resize 76x76 public/apple-icon-76x76.png
convert "$SOURCE_ICON" -resize 114x114 public/apple-icon-114x114.png
convert "$SOURCE_ICON" -resize 120x120 public/apple-icon-120x120.png
convert "$SOURCE_ICON" -resize 144x144 public/apple-icon-144x144.png
convert "$SOURCE_ICON" -resize 152x152 public/apple-icon-152x152.png
convert "$SOURCE_ICON" -resize 180x180 public/apple-icon-180x180.png
convert "$SOURCE_ICON" -resize 180x180 public/apple-icon.png
convert "$SOURCE_ICON" -resize 180x180 public/apple-icon-precomposed.png

echo "📝 生成 Android 图标..."
convert "$SOURCE_ICON" -resize 36x36 public/android-icon-36x36.png
convert "$SOURCE_ICON" -resize 48x48 public/android-icon-48x48.png
convert "$SOURCE_ICON" -resize 72x72 public/android-icon-72x72.png
convert "$SOURCE_ICON" -resize 96x96 public/android-icon-96x96.png
convert "$SOURCE_ICON" -resize 144x144 public/android-icon-144x144.png
convert "$SOURCE_ICON" -resize 192x192 public/android-icon-192x192.png

echo "📝 生成 Microsoft 图标..."
convert "$SOURCE_ICON" -resize 70x70 public/ms-icon-70x70.png
convert "$SOURCE_ICON" -resize 144x144 public/ms-icon-144x144.png
convert "$SOURCE_ICON" -resize 150x150 public/ms-icon-150x150.png
convert "$SOURCE_ICON" -resize 310x310 public/ms-icon-310x310.png

echo ""
echo "✅ 所有图标生成完成！"
echo ""
echo "📋 生成的图标："
echo "  - Favicon: 16x16, 32x32, 96x96, 512x512"
echo "  - Apple: 9 种尺寸"
echo "  - Android: 6 种尺寸"
echo "  - Microsoft: 4 种尺寸"
echo ""
echo "=========================================="
