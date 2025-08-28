# 💕 Love Trick - 情侣任务管理系统

> 💝 给女朋友写的专属情侣任务和商城系统 | 纯H5页面 | 完全免费部署 | 无需服务器  
> 🚀 React-Next.js全栈项目，让爱情更有趣！

[![Next.js](https://img.shields.io/badge/Next.js-15.5.2-black?logo=next.js)](https://nextjs.org/)
[![React](https://img.shields.io/badge/React-19.1.1-blue?logo=react)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.6.2-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Prisma](https://img.shields.io/badge/Prisma-6.15.0-green?logo=prisma)](https://www.prisma.io/)
[![GitHub stars](https://img.shields.io/github/stars/lengsukq/love-trick?style=social)](https://github.com/lengsukq/love-trick/stargazers)
[![GitHub forks](https://img.shields.io/github/forks/lengsukq/love-trick?style=social)](https://github.com/lengsukq/love-trick/network/members)

## 🚀 快速开始

想要快速体验？只需3步：

```bash
# 1. 克隆项目
git clone https://github.com/lengsukq/love-trick.git
cd love-trick

# 2. 安装依赖
npm install

# 3. 启动项目（使用SQLite零配置）
npm run dev
```

🎉 打开 http://localhost:9999 开始你的爱情之旅！

## ✨ 核心功能

🔐 **用户系统**
- 用户注册登录（注册点击登录页圆形大图）
- 个人信息管理与情侣绑定

🎯 **任务系统**
- 发布任务给对方
- 接受并完成任务
- 任务状态追踪

🏪 **积分商城**
- 类商品交易系统，完成任务获取积分
- 积分兑换礼物（商品）
- 上架自己的礼物给对方兑换

📸 **图片管理**
- 支持SM图床、IMGBB图床
- 完全不占用服务器空间
- 让家庭自建服务器也能实现高清大图存储

💬 **留言功能**
- 给对方留言表达心意
- 留言状态管理

🤖 **智能通知**
- 发布/接受/完成任务时微信企业机器人通知
- 使用礼物时自动通知

❤️ **收藏系统**
- 收藏喜欢的任务、礼物、留言
- 个人收藏管理
***
![mainImg.png](readmeImg%2FmainImg.png)

## 🏗️ 技术架构

### 前端技术栈
- **Next.js 15.5.2** - React全栈框架，支持SSR/SSG
- **React 19.1.1** - 用户界面库
- **TypeScript 5.6.2** - 类型安全的JavaScript
- **Tailwind CSS** - 原子化CSS框架
- **Framer Motion** - 动画库
- **React Redux** - 状态管理

### 后端技术栈
- **Next.js API Routes** - 服务端API接口
- **Prisma ORM 6.15.0** - 现代化数据库访问层
- **JWT** - 身份认证
- **中间件验证** - 路由安全保护

### 数据库支持
🗄️ **多数据库兼容** - 通过Prisma ORM支持：
- **SQLite** (开发环境推荐) - 零配置，开箱即用
- **MySQL** (生产环境推荐) - 高性能关系型数据库  
- **PostgreSQL** (企业级推荐) - 功能丰富的开源数据库

### 外部集成
- **图床服务** - SM图床、IMGBB图床（支持高清图片上传）
- **企业微信机器人** - 实时消息推送，任务状态同步

## 📊 数据库模型

### 核心数据表
- **UserInfo** - 用户信息表
- **TaskList** - 任务列表表  
- **GiftList** - 礼物列表表
- **WhisperList** - 留言列表表
- **FavouriteList** - 收藏列表表

![sql.png](readmeImg%2Fsql.png)

## 📚 无需服务器，0成本搭建教程 
🔗 [详细教程](https://blog.lengsu.top/article/love-trick)

## ⚙️ 环境配置

### 创建.env.local文件

在项目根目录创建`.env.local`文件，配置以下环境变量：

```bash
# ===========================================
# 🗄️ 数据库配置 (Database Configuration)
# ===========================================

# 数据库提供商选择: sqlite, mysql, postgresql
DATABASE_PROVIDER=sqlite

# 数据库连接URL (根据DATABASE_PROVIDER选择对应格式)
# SQLite: file:./dev.db
# MySQL: mysql://username:password@host:port/database  
# PostgreSQL: postgresql://username:password@host:port/database
DATABASE_URL=file:./dev.db

# ===========================================
# 🔐 安全配置 (Security Configuration)
# ===========================================

# JWT密钥 - 用于cookie加密，请替换为复杂的随机字符串
JWT_SECRET_KEY=your_super_secret_jwt_key_here

# ===========================================
# 🤖 微信机器人配置 (WeChat Robot Configuration)  
# ===========================================

# 企业微信机器人webhook URL (可选)
WX_ROBOT_URL=https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=your-webhook-key

# ===========================================
# 📸 图床配置 (Image Hosting Configuration)
# ===========================================

# 图床选择: SM, IMGBB
DRAWING_BED=SM

# SM图床配置 (当DRAWING_BED=SM时需要)
# 注册地址: https://smms.app/
SM_TOKEN=your_sm_token_here

# IMGBB图床配置 (当DRAWING_BED=IMGBB时需要)
# 注册地址: https://imgbb.com/
IMGBB_API=your_imgbb_api_key_here
```

### 📝 配置说明

#### 数据库配置
- **开发环境推荐**: 使用SQLite (`DATABASE_PROVIDER=sqlite`)，零配置开箱即用
- **生产环境推荐**: 使用MySQL或PostgreSQL，性能更优
- 使用Prisma ORM，支持数据库迁移和类型安全

#### 图床配置
- 支持两种图床服务：**SM图床**和**IMGBB图床**
- **SM图床**：注册 https://smms.app/ 获取API Token
- **IMGBB图床**：注册 https://imgbb.com/ 获取API Key
- 选择其中一种配置即可，建议使用SM图床（免费、稳定）

#### 数据库快速切换
项目支持通过npm脚本快速切换数据库：
```bash
# 切换到SQLite
npm run db:sqlite

# 切换到MySQL  
npm run db:mysql

# 切换到PostgreSQL
npm run db:postgresql
```

## 🔄 项目迭代状态

### ✅ 已完成优化
- ✅ **数据库架构升级** - 从原生SQL迁移到Prisma ORM
- ✅ **多数据库支持** - 支持SQLite/MySQL/PostgreSQL
- ✅ **Next.js 15升级** - 升级到最新版本，性能更优
- ✅ **React 19升级** - 最新React特性支持
- ✅ **Cookie安全优化** - 服务器端二次校验
- ✅ **类型安全** - 全面TypeScript化
- ✅ **中间件验证** - 路由级别的安全保护

### 🚧 持续改进中
- 🔄 接口参数校验完善
- 🔄 二次确认逻辑优化
- 🔄 错误处理机制增强
- 🔄 性能优化和缓存策略

## 🐳 Docker 部署

### 1. 构建或拉取镜像
```bash
# 构建本地镜像（需要先进入项目目录）
docker build -t love-trick .

# 或拉取远程镜像
docker pull queensu/love-trick
```

### 2. 运行容器

#### SQLite模式（推荐新手）
```bash
docker run -d -p 9999:9999 --name love-trick \
  -e DATABASE_PROVIDER=sqlite \
  -e DATABASE_URL=file:./dev.db \
  -e JWT_SECRET_KEY=your_jwt_secret_key \
  -e DRAWING_BED=SM \
  -e SM_TOKEN=your_sm_token \
  -e WX_ROBOT_URL=your_webhook_url \
  -v $(pwd)/data:/app/data \
  love-trick
```

#### MySQL模式（生产环境推荐）
```bash
docker run -d -p 9999:9999 --name love-trick \
  -e DATABASE_PROVIDER=mysql \
  -e DATABASE_URL=mysql://username:password@host:port/database \
  -e JWT_SECRET_KEY=your_jwt_secret_key \
  -e DRAWING_BED=SM \
  -e SM_TOKEN=your_sm_token \
  -e WX_ROBOT_URL=your_webhook_url \
  love-trick
```

#### PostgreSQL模式
```bash
docker run -d -p 9999:9999 --name love-trick \
  -e DATABASE_PROVIDER=postgresql \
  -e DATABASE_URL=postgresql://username:password@host:port/database \
  -e JWT_SECRET_KEY=your_jwt_secret_key \
  -e DRAWING_BED=SM \
  -e SM_TOKEN=your_sm_token \
  -e WX_ROBOT_URL=your_webhook_url \
  love-trick
```

## 🚀 开发启动流程

### 1. 克隆项目
```bash
git clone https://github.com/your-username/love-trick.git
cd love-trick
```

### 2. 安装依赖
```bash
# 使用npm
npm install

# 或使用yarn
yarn install
```

### 3. 环境配置
```bash
# 复制并编辑环境变量文件
cp .env.example .env.local

# 编辑配置文件
vim .env.local  # 或使用其他编辑器
```

### 4. 数据库初始化
```bash
# 生成Prisma客户端
npm run db:generate

# 推送数据库schema（开发环境）
npm run db:push

# 或运行数据库迁移（生产环境）
npm run db:migrate
```

### 5. 启动开发服务器
```bash
# 启动开发服务器
npm run dev
# 或
yarn dev
```

### 6. 访问应用
打开浏览器访问：http://localhost:9999

## 📦 生产环境部署

### 1. 安装依赖
```bash
npm install --production
```

### 2. 数据库迁移
```bash
# 生产环境数据库迁移
npm run db:migrate

# 生成Prisma客户端
npm run db:generate
```

### 3. 构建项目
```bash
npm run build
```

### 4. 启动生产服务器
```bash
npm start
```

### 5. 访问应用
浏览器访问：http://你的服务器IP:9999

## 🛠️ 数据库管理命令

```bash
# 生成Prisma客户端
npm run db:generate

# 推送schema到数据库（开发）
npm run db:push

# 拉取数据库schema
npm run db:pull

# 创建数据库迁移
npm run db:migrate

# 重置数据库
npm run db:reset

# 打开数据库管理界面
npm run db:studio

# 快速切换数据库
npm run db:sqlite    # 切换到SQLite
npm run db:mysql     # 切换到MySQL  
npm run db:postgresql # 切换到PostgreSQL
```

## 📂 项目结构

```
love-trick/
├── app/                    # Next.js 13+ App Router
│   ├── api/               # API路由
│   │   └── v1/           # API版本
│   ├── components/        # React组件
│   ├── hooks/            # 自定义Hooks
│   ├── store/            # Redux状态管理
│   ├── trick/            # 应用页面
│   ├── types/            # TypeScript类型定义
│   └── utils/            # 工具函数
├── prisma/               # Prisma数据库配置
│   ├── schema.prisma    # 主schema文件
│   ├── schema.mysql.prisma     # MySQL schema
│   ├── schema.postgresql.prisma # PostgreSQL schema
│   └── schema.sqlite.prisma    # SQLite schema
├── scripts/              # 构建脚本
├── public/               # 静态资源
└── generated/            # Prisma生成的客户端
```

## 🤝 贡献指南

1. Fork 项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

## 📄 许可证

本项目基于 MIT 许可证开源。详情请参阅 [LICENSE](LICENSE) 文件。

## 🙏 致谢

- [Next.js](https://nextjs.org/) - React全栈框架
- [Prisma](https://www.prisma.io/) - 现代化数据库工具
- [Tailwind CSS](https://tailwindcss.com/) - 原子化CSS框架
- [React](https://reactjs.org/) - 用户界面库

## 📞 支持与反馈

- 🐛 [报告Bug](https://github.com/lengsukq/love-trick/issues)
- 💡 [功能建议](https://github.com/lengsukq/love-trick/issues)
- 📖 [查看文档](https://blog.lengsu.top/article/love-trick)
- 🌐 [在线体验](https://love-trick.lengsu.top/)

## 👨‍💻 关于作者

**lengsukq** - 全干工程师 🚀

- 🌍 **个人博客**: [https://blog.lengsu.top/](https://blog.lengsu.top/)
- 🐙 **GitHub**: [https://github.com/lengsukq](https://github.com/lengsukq)
- 💼 **技术栈**: Vue3/React/Next.js/Node.js/Python/Docker

### 🎯 更多精彩项目

- 💬 [AI集合站-NextChat](https://chat.lengsu.top/) - Web端一站式大模型整合
- 🛠️ [工具箱](https://tools.lengsu.top/) - 各种实用工具集合
- 🎵 [Bilibili音乐解析](https://bilibili-music.lengsu.top/) - 支持解析单个/收藏夹
- 🖼️ [Pic-Su](https://pic-su.top/) - 图片管理系统
- ✍️ [AI降重](https://parap.lengsu.top/) - 解析查重报告并自定义大模型降重

---

<div align="center">

**如果这个项目对你有帮助，请给它一个 ⭐️**

Made with ❤️ by [lengsukq](https://github.com/lengsukq)

</div>
