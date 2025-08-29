# 数据库配置指南

本项目支持三种数据库：SQLite、MySQL、PostgreSQL。通过环境变量控制数据库选择。

## 环境变量配置

在你的 `.env` 文件中添加以下配置：

### 1. SQLite 配置（开发推荐）

```env
DATABASE_PROVIDER=sqlite
DATABASE_URL=file:./dev.db
```

### 2. MySQL 配置

```env
DATABASE_PROVIDER=mysql
DATABASE_URL=mysql://username:password@localhost:3306/database_name

# 或者使用环境变量拼接
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=romance_hub
MYSQL_USER=root
MYSQL_PASSWORD=your_password
DATABASE_URL=mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${MYSQL_HOST}:${MYSQL_PORT}/${MYSQL_DATABASE}
```

### 3. PostgreSQL 配置

```env
DATABASE_PROVIDER=postgresql
DATABASE_URL=postgresql://username:password@localhost:5432/database_name

# 或者使用环境变量拼接
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DATABASE=romance_hub
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
DATABASE_URL=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DATABASE}
```

## 数据库迁移命令

### 初始化数据库
```bash
# 如果没有现有数据库，创建新的迁移
npx prisma migrate dev --name init

# 如果有现有数据库，拉取schema
npx prisma db pull
```

### 生成客户端
```bash
npx prisma generate
```

### 重置数据库
```bash
npx prisma migrate reset
```

## 快速切换数据库

使用便捷的npm脚本一键切换数据库类型：

### 方法一：使用npm脚本（推荐）

```bash
# 切换到SQLite
npm run db:sqlite

# 切换到MySQL  
npm run db:mysql

# 切换到PostgreSQL
npm run db:postgresql
```

### 方法二：手动切换

```bash
# 1. 切换schema
npm run db:switch sqlite  # 或 mysql, postgresql

# 2. 生成客户端
npm run db:generate

# 3. 更新环境变量
```

### 环境变量配置

1. **开发环境（SQLite）**：
   ```env
   DATABASE_URL=file:./dev.db
   ```

2. **生产环境（MySQL）**：
   ```env
   DATABASE_URL=mysql://user:pass@host:3306/db
   ```

3. **测试环境（PostgreSQL）**：
   ```env
   DATABASE_URL=postgresql://user:pass@host:5432/db
   ```

## 注意事项

- 每次切换数据库类型后需要运行 `npx prisma generate`
- SQLite 文件会在项目根目录创建
- 确保目标数据库服务已启动并可连接
- 生产环境建议使用 MySQL 或 PostgreSQL
