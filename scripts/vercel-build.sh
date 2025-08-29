#!/bin/bash

echo "🚀 开始 Vercel 构建流程..."

# 设置环境变量
export PRISMA_GENERATE_SKIP_AUTOINSTALL=false
export NEXT_TELEMETRY_DISABLED=1

echo "📦 安装依赖..."
npm ci

echo "🔧 生成 Prisma 客户端..."
npx prisma generate

echo "🏗️ 构建 Next.js 应用..."
npm run build

echo "✅ 构建完成！"
