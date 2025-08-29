# 🚀 Vercel 部署指南

## 📋 部署前准备

### 1. 环境变量配置

在 Vercel 项目设置中配置以下环境变量：

```bash
# 数据库配置
DATABASE_PROVIDER=postgresql
DATABASE_URL=postgresql://username:password@host:port/database

# 安全配置
JWT_SECRET_KEY=your_super_secret_jwt_key_here

# 图床配置
DRAWING_BED=SM
SM_TOKEN=your_sm_token_here

# 微信机器人（可选）
WX_ROBOT_URL=https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=your-key

# 构建配置
NEXT_TELEMETRY_DISABLED=1
SKIP_ENV_VALIDATION=1
```

### 2. Node.js 版本设置

在 Vercel 项目设置中：
- 进入 **Settings** → **General** → **Node.js Version**
- 选择 **22.x** (推荐) 或 **20.x**

## 🔧 部署配置文件

### vercel.json
项目已包含优化的 `vercel.json` 配置文件，包含：
- Node.js 22.x 运行时
- Prisma 构建优化
- API 路由配置
- CORS 头设置

### next.config.js
针对 Vercel 部署优化：
- Prisma 客户端外部化
- 服务器组件包配置
- 构建优化设置

## 🗄️ 数据库设置

### PostgreSQL (推荐)
```bash
# 使用 Vercel Postgres 或外部 PostgreSQL 服务
DATABASE_PROVIDER=postgresql
DATABASE_URL=postgresql://user:pass@host:port/dbname
```

### MySQL
```bash
DATABASE_PROVIDER=mysql
DATABASE_URL=mysql://user:pass@host:port/dbname
```

## 🚨 常见部署问题解决

### 1. Prisma 客户端生成问题
**错误**: `Prisma has detected that this project was built on Vercel...`
**解决**: 项目已在 `package.json` 中添加 `postinstall` 脚本自动生成客户端

### 2. Node.js 版本警告
**错误**: `Node.js version 18.x is deprecated`
**解决**: 在 Vercel 设置中将 Node.js 版本改为 22.x

### 3. API 路由构建错误
**错误**: `Failed to collect page data for /api/v1/favourite`
**解决**: 项目已添加运行时检查和 GET 方法导出

### 4. 环境变量未加载
**解决**: 确保在 Vercel 项目设置中正确配置所有必需的环境变量

## 📦 部署步骤

### 方法一：GitHub 连接（推荐）
1. 将代码推送到 GitHub
2. 在 Vercel 中导入 GitHub 仓库
3. 配置环境变量
4. 部署

### 方法二：Vercel CLI
```bash
# 安装 Vercel CLI
npm i -g vercel

# 登录
vercel login

# 部署
vercel --prod
```

## 🔍 部署后验证

1. **访问应用** - 检查首页是否正常加载
2. **API 测试** - 验证 `/api/v1/user` 等接口是否正常
3. **数据库连接** - 确认数据库操作正常
4. **图片上传** - 测试图床功能是否正常

## 📊 性能优化建议

1. **启用 Vercel Analytics**
2. **配置 CDN 缓存**
3. **使用 Vercel Edge Functions**（如需要）
4. **监控数据库连接池**

## 🛠️ 故障排除

### 查看部署日志
在 Vercel Dashboard 中查看：
- Build Logs
- Function Logs
- Runtime Logs

### 常用调试命令
```bash
# 本地构建测试
npm run build

# 检查 Prisma 客户端
npx prisma generate

# 类型检查
npm run type-check
```

## 📞 获取帮助

如果遇到部署问题：
1. 查看 [Vercel 官方文档](https://vercel.com/docs)
2. 检查项目的 [常见问题](./README.md#常见问题与解决方案)
3. 提交 [Issue](https://github.com/lengsukq/romance-hub/issues)
