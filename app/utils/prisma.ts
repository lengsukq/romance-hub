import { PrismaClient } from '../../generated/prisma';
import { getDatabaseInfo, validateDatabaseConfig } from './database-config';

// 创建全局Prisma实例
declare global {
  var prisma: PrismaClient | undefined;
}

// 在构建时跳过数据库配置验证
if (process.env.NODE_ENV !== 'production' && process.env.NEXT_PHASE !== 'phase-production-build') {
  // 验证数据库配置
  const configValidation = validateDatabaseConfig();
  if (!configValidation.valid) {
    console.error('❌ 数据库配置错误:', configValidation.message);
    throw new Error(configValidation.message);
  }

  // 输出数据库信息
  console.log('🗄️ ', getDatabaseInfo());
}

// 在开发环境中复用实例，避免热重载时创建多个连接
const prisma = globalThis.prisma || new PrismaClient({
  log: process.env.NODE_ENV === 'development' 
    ? ['query', 'info', 'warn', 'error'] 
    : ['error'],
});

if (process.env.NODE_ENV !== 'production') {
  globalThis.prisma = prisma;
}

// 数据库连接测试（仅在运行时，非构建时）
if (process.env.NODE_ENV !== 'production' && process.env.NEXT_PHASE !== 'phase-production-build') {
  prisma.$connect()
    .then(() => {
      console.log('✅ 数据库连接成功');
    })
    .catch((error) => {
      console.error('❌ 数据库连接失败:', error);
    });
}

export default prisma;
