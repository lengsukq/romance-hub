#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const supportedProviders = ['sqlite', 'mysql', 'postgresql'];

function switchDatabase(provider) {
  if (!supportedProviders.includes(provider)) {
    console.error(`❌ 不支持的数据库类型: ${provider}`);
    console.log(`✅ 支持的数据库类型: ${supportedProviders.join(', ')}`);
    process.exit(1);
  }

  const schemaPath = path.join(__dirname, '..', 'prisma', 'schema.prisma');
  let sourceSchemaPath;

  if (provider === 'sqlite') {
    // SQLite使用默认schema
    sourceSchemaPath = schemaPath;
  } else {
    sourceSchemaPath = path.join(__dirname, '..', 'prisma', `schema.${provider}.prisma`);
  }

  try {
    // 检查源schema文件是否存在
    if (!fs.existsSync(sourceSchemaPath) && provider !== 'sqlite') {
      console.error(`❌ Schema文件不存在: ${sourceSchemaPath}`);
      process.exit(1);
    }

    // 如果不是SQLite，复制对应的schema文件
    if (provider !== 'sqlite') {
      const schemaContent = fs.readFileSync(sourceSchemaPath, 'utf8');
      fs.writeFileSync(schemaPath, schemaContent);
    }

    console.log(`✅ 已切换到 ${provider.toUpperCase()} 数据库`);
    console.log(`📝 Schema文件: prisma/schema.prisma`);
    console.log(`🔧 请运行以下命令完成切换:`);
    console.log(`   npm run db:generate`);
    
    // 根据数据库类型提供配置建议
    switch (provider) {
      case 'sqlite':
        console.log(`📋 环境变量配置:`);
        console.log(`   DATABASE_URL=file:./dev.db`);
        break;
      case 'mysql':
        console.log(`📋 环境变量配置:`);
        console.log(`   DATABASE_URL=mysql://username:password@localhost:3306/database_name`);
        break;
      case 'postgresql':
        console.log(`📋 环境变量配置:`);
        console.log(`   DATABASE_URL=postgresql://username:password@localhost:5432/database_name`);
        break;
    }

  } catch (error) {
    console.error(`❌ 切换数据库失败:`, error.message);
    process.exit(1);
  }
}

// 获取命令行参数
const provider = process.argv[2];

if (!provider) {
  console.log(`使用方法: node scripts/switch-database.js <provider>`);
  console.log(`支持的数据库类型: ${supportedProviders.join(', ')}`);
  process.exit(1);
}

switchDatabase(provider);
