/**
 * 数据库配置工具
 * 支持通过环境变量动态选择 SQLite/MySQL/PostgreSQL
 */

export type DatabaseProvider = 'sqlite' | 'mysql' | 'postgresql';

export interface DatabaseConfig {
  provider: DatabaseProvider;
  url: string;
}

/**
 * 获取数据库配置
 */
export function getDatabaseConfig(): DatabaseConfig {
  const provider = (process.env.DATABASE_PROVIDER || 'sqlite') as DatabaseProvider;
  const url = process.env.DATABASE_URL || '';

  // 验证配置
  if (!url) {
    throw new Error('DATABASE_URL 环境变量未设置');
  }

  // 验证provider
  if (!['sqlite', 'mysql', 'postgresql'].includes(provider)) {
    throw new Error(`不支持的数据库类型: ${provider}. 支持的类型: sqlite, mysql, postgresql`);
  }

  return { provider, url };
}

/**
 * 根据数据库类型生成默认配置
 */
export function generateDatabaseUrl(provider: DatabaseProvider, options: any = {}): string {
  switch (provider) {
    case 'sqlite':
      return options.file || 'file:./dev.db';
      
    case 'mysql':
      const {
        host = 'localhost',
        port = 3306,
        database = 'love_trick',
        username = 'root',
        password = ''
      } = options;
      return `mysql://${username}:${password}@${host}:${port}/${database}`;
      
    case 'postgresql':
      const {
        host: pgHost = 'localhost',
        port: pgPort = 5432,
        database: pgDatabase = 'love_trick',
        username: pgUsername = 'postgres',
        password: pgPassword = ''
      } = options;
      return `postgresql://${pgUsername}:${pgPassword}@${pgHost}:${pgPort}/${pgDatabase}`;
      
    default:
      throw new Error(`不支持的数据库类型: ${provider}`);
  }
}

/**
 * 获取数据库连接状态信息
 */
export function getDatabaseInfo(): string {
  const config = getDatabaseConfig();
  
  switch (config.provider) {
    case 'sqlite':
      return `SQLite 数据库: ${config.url.replace('file:', '')}`;
    case 'mysql':
      const mysqlUrl = new URL(config.url);
      return `MySQL 数据库: ${mysqlUrl.hostname}:${mysqlUrl.port}${mysqlUrl.pathname}`;
    case 'postgresql':
      const pgUrl = new URL(config.url);
      return `PostgreSQL 数据库: ${pgUrl.hostname}:${pgUrl.port}${pgUrl.pathname}`;
    default:
      return `未知数据库类型: ${config.provider}`;
  }
}

/**
 * 验证数据库连接配置
 */
export function validateDatabaseConfig(): { valid: boolean; message: string } {
  try {
    const config = getDatabaseConfig();
    
    // 基础URL格式验证
    if (config.provider === 'sqlite') {
      if (!config.url.startsWith('file:')) {
        return { valid: false, message: 'SQLite URL 必须以 file: 开头' };
      }
    } else {
      try {
        new URL(config.url);
      } catch {
        return { valid: false, message: '数据库URL格式无效' };
      }
    }
    
    return { valid: true, message: `数据库配置有效: ${config.provider}` };
  } catch (error) {
    return { valid: false, message: (error as Error).message };
  }
}
