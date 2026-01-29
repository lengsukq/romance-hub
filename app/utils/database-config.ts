/**
 * 数据库配置工具
 * 项目已全面迁移到 PostgreSQL
 */

export interface DatabaseConfig {
  url: string;
}

/**
 * 获取数据库配置
 */
export function getDatabaseConfig(): DatabaseConfig {
  const url = process.env.DATABASE_URL || '';

  // 验证配置
  if (!url) {
    throw new Error('DATABASE_URL 环境变量未设置');
  }

  // 验证 PostgreSQL URL 格式
  if (!url.startsWith('postgresql://') && !url.startsWith('postgres://')) {
    throw new Error('DATABASE_URL 必须是 PostgreSQL 连接字符串');
  }

  return { url };
}

/**
 * 获取数据库连接状态信息
 */
export function getDatabaseInfo(): string {
  try {
    const config = getDatabaseConfig();
    const pgUrl = new URL(config.url);
    // 隐藏密码
    const safeUrl = `${pgUrl.protocol}//${pgUrl.username}@${pgUrl.hostname}:${pgUrl.port}${pgUrl.pathname}`;
    return `PostgreSQL 数据库: ${safeUrl}`;
  } catch (error) {
    return `数据库配置错误: ${(error as Error).message}`;
  }
}

/**
 * 验证数据库连接配置
 */
export function validateDatabaseConfig(): { valid: boolean; message: string } {
  try {
    const config = getDatabaseConfig();
    
    // 验证 URL 格式
    try {
      const url = new URL(config.url);
      if (!url.protocol.startsWith('postgres')) {
        return { valid: false, message: 'DATABASE_URL 必须是 PostgreSQL 连接字符串' };
      }
    } catch {
      return { valid: false, message: '数据库URL格式无效' };
    }
    
    return { valid: true, message: 'PostgreSQL 数据库配置有效' };
  } catch (error) {
    return { valid: false, message: (error as Error).message };
  }
}
