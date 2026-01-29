# SQLite 本地开发环境设置脚本
Write-Host "🚀 设置 SQLite 本地开发环境..." -ForegroundColor Green

# 设置环境变量
$env:DATABASE_URL = "file:./dev.db"
$env:DATABASE_PROVIDER = "sqlite"
$env:NODE_ENV = "development"

Write-Host "✅ 环境变量已设置:" -ForegroundColor Green
Write-Host "   DATABASE_URL = $env:DATABASE_URL" -ForegroundColor Yellow
Write-Host "   DATABASE_PROVIDER = $env:DATABASE_PROVIDER" -ForegroundColor Yellow
Write-Host "   NODE_ENV = $env:NODE_ENV" -ForegroundColor Yellow

Write-Host "`n🔧 可用的命令:" -ForegroundColor Cyan
Write-Host "   npm run dev          - 启动开发服务器" -ForegroundColor White
Write-Host "   npm run db:studio    - 打开 Prisma Studio" -ForegroundColor White
Write-Host "   npm run db:push      - 推送 schema 到数据库" -ForegroundColor White
Write-Host "   npm run db:generate  - 生成 Prisma 客户端" -ForegroundColor White
Write-Host "   npm run db:reset     - 重置数据库" -ForegroundColor White

Write-Host "`n📋 数据库信息:" -ForegroundColor Cyan
Write-Host "   类型: SQLite" -ForegroundColor White
Write-Host "   文件: ./prisma/dev.db" -ForegroundColor White
Write-Host "   位置: $PWD\prisma\dev.db" -ForegroundColor White

# 检查数据库文件是否存在
if (Test-Path "./prisma/dev.db") {
    Write-Host "`n✅ SQLite 数据库文件已存在" -ForegroundColor Green
    $dbSize = (Get-Item "./prisma/dev.db").Length
    Write-Host "   文件大小: $dbSize 字节" -ForegroundColor White
} else {
    Write-Host "`n⚠️  SQLite 数据库文件不存在，请运行 'npm run db:push' 创建" -ForegroundColor Yellow
}

Write-Host "`n🎯 现在可以开始开发了!" -ForegroundColor Green
