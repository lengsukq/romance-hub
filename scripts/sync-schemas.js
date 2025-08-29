#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// 同步schema文件结构
function syncSchemas() {
  const prismaDir = path.join(__dirname, '..', 'prisma');
  const mainSchemaPath = path.join(prismaDir, 'schema.prisma');
  const mysqlSchemaPath = path.join(prismaDir, 'schema.mysql.prisma');
  const postgresqlSchemaPath = path.join(prismaDir, 'schema.postgresql.prisma');

  try {
    // 读取主schema文件
    const mainSchema = fs.readFileSync(mainSchemaPath, 'utf8');
    
    // 提取数据源配置
    const datasourceMatch = mainSchema.match(/datasource db \{[^}]*\}/s);
    const mainDatasource = datasourceMatch ? datasourceMatch[0] : '';
    
    // 提取generator配置
    const generatorMatch = mainSchema.match(/generator client \{[^}]*\}/s);
    const generator = generatorMatch ? generatorMatch[0] : '';
    
    // 提取模型定义（排除数据源和生成器）
    const modelsMatch = mainSchema.match(/model [\s\S]*$/);
    const models = modelsMatch ? modelsMatch[0] : '';
    
    // MySQL schema
    const mysqlSchema = `// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

${generator}

datasource db {
  provider = "mysql"
  url      = env("DATABASE_URL")
}

${models}`;
    
    // PostgreSQL schema
    const postgresqlSchema = `// This is your Prisma schema file,
// learn more about it in the docs: https://pris.ly/d/prisma-schema

${generator}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

${models}`;
    
    // 写入文件
    fs.writeFileSync(mysqlSchemaPath, mysqlSchema);
    fs.writeFileSync(postgresqlSchemaPath, postgresqlSchema);
    
    console.log('✅ Schema文件同步完成！');
    console.log('📝 已更新以下文件：');
    console.log('   - prisma/schema.mysql.prisma');
    console.log('   - prisma/schema.postgresql.prisma');
    console.log('');
    console.log('🔧 下一步：');
    console.log('   1. 运行 npm run db:generate 重新生成客户端');
    console.log('   2. 运行 npm run db:push 更新数据库结构');
    
  } catch (error) {
    console.error('❌ 同步schema文件失败:', error.message);
    process.exit(1);
  }
}

// 运行同步
syncSchemas();
