#!/bin/bash
set -e

# 检查是否提供了签名密钥
if [ -n "$SIGNING_KEY" ]; then
  echo "设置签名密钥..."
  
  # 创建签名密钥文件
  echo "$SIGNING_KEY" | base64 -d > android/wordflow-key.jks
  
  # 创建key.properties文件
  echo "storePassword=$KEY_STORE_PASSWORD" > android/key.properties
  echo "keyPassword=$KEY_PASSWORD" >> android/key.properties
  echo "keyAlias=$KEY_ALIAS" >> android/key.properties
  echo "storeFile=../wordflow-key.jks" >> android/key.properties
  
  echo "签名配置完成"
else
  echo "警告: 未提供签名密钥，将构建未签名的APK"
fi

# 构建APK
echo "开始构建APK..."
flutter build apk --release

echo "APK构建完成，输出路径: build/app/outputs/flutter-apk/app-release.apk"

# 如果指定了输出目录，则复制APK到该目录
if [ -n "$OUTPUT_DIR" ]; then
  mkdir -p $OUTPUT_DIR
  cp build/app/outputs/flutter-apk/app-release.apk $OUTPUT_DIR/
  echo "APK已复制到: $OUTPUT_DIR/app-release.apk"
fi