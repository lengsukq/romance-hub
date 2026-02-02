# 锦书 · Romance Hub

> 两心相知，一事一诺。情侣任务与心意管理，Web + Flutter 双端。

[![Next.js](https://img.shields.io/badge/Next.js-16-black?logo=next.js)](https://nextjs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue?logo=flutter)](https://flutter.dev/)
[![Prisma](https://img.shields.io/badge/Prisma-6-green?logo=prisma)](https://www.prisma.io/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Neon-blue)](https://neon.tech/)

---

## 简介

**锦书** 是一套情侣向的任务与心意管理系统：支持发布心诺（任务）、赠礼（积分兑换）、私语（留言）、藏心（收藏），以及吾之信息与良人信息展示。后端为 Next.js + Prisma + PostgreSQL，提供 Web 管理页与 REST API；客户端支持 **Web 端**（Next.js 页面）与 **Flutter App**（iOS / Android / Windows / macOS 等），界面采用古风文案与统一设计规范（君归矣、心诺、赠礼、私语、吾心、云阁等）。

- **Web**：访问 `/trick` 系列页面，配置、任务、礼物、私语、收藏、个人信息等。
- **App**：Flutter 应用「锦书」，首页一念即达、心诺 / 赠礼 / 私语 / 藏心 / 吾心，云阁（后端地址）可配置，图床可在吾心→设置中配置（与良人共用）。
- **双账号**：注册时支持二人同契（一次性注册两个关联账号），配置与良人共用。

---

## 快速开始

### 环境要求

- Node.js >= 22
- PostgreSQL（推荐 [Neon](https://neon.tech)）
- 可选：Flutter 3.x（仅需运行或构建 App 时）

### 1. 克隆与安装

```bash
git clone https://github.com/lengsukq/romance-hub.git
cd romance-hub
yarn install
```

### 2. 环境变量

在项目根目录创建 `.env` 或 `.env.local`：

```bash
# 必填：数据库与鉴权
DATABASE_URL=postgresql://user:password@host/db?sslmode=require
JWT_SECRET_KEY=你的随机密钥

# 可选：图床兜底（未在应用内配置图床时使用）
DRAWING_BED=IMGBB
IMGBB_API=你的_imgbb_api_key
```

### 3. 数据库

```bash
yarn db:generate
yarn db:push
```

### 4. 启动

```bash
yarn dev
```

浏览器访问 **http://localhost:9999**。  
（可选）在 `flutter_app` 目录执行 `flutter run` 运行 App，登录页配置云阁地址为 `http://你的本机IP:9999` 即可连到本地后端。

---

## 功能概览

| 模块 | 说明 |
|------|------|
| **心诺** | 发布 / 接受 / 完成任务，状态追踪，完成可通知（如企业微信） |
| **赠礼** | 积分兑换礼物，上架自己的礼物给对方兑换，使用可通知 |
| **私语** | 给对方留言，已读/未读，新私语可通知 |
| **藏心** | 收藏心诺、赠礼、私语，统一列表 |
| **吾心** | 吾之信息（头像、用户名、一言等）、良人信息；编辑弹框、设置入口（图床等） |
| **云阁** | 后端地址配置（Web：配置页；App：登录页 + 吾心页云阁卡片） |
| **图床** | 应用内图床设置（与良人共用），或服务端 `.env` 兜底（DRAWING_BED + IMGBB_API） |
| **通知** | 图床/通知等配置在 Web `/trick/config` 或 App 吾心→设置中管理，可接企业微信等 |

- Web：配置与内容管理主要在 `/trick/config`、`/trick/myInfo`、任务/礼物/私语/收藏等页面。
- App：底部 Tab 首页 / 心诺 / 赠礼 / 私语 / 吾心；吾心页右上角设置进入图床与吾之信息编辑。

---

## 技术栈

### 后端与 Web

- **Next.js 16**（App Router）+ **React 19** + **TypeScript**
- **Prisma** + **PostgreSQL**（推荐 Neon）
- **JWT / Cookie** 鉴权，API 路由：`/api/v1/user`、`/api/v1/task`、`/api/v1/gift`、`/api/v1/whisper`、`/api/v1/favourite`、`/api/v1/config`、`/api/v1/common`（上传等）

### Flutter App

- **Flutter 3.x** + **Dart 3**
- **go_router**、**Provider**、**Dio**；Material 3，遵循项目内「锦书」UI 设计规则（古风文案、大圆角、主色等）

### 数据库

- **UserInfo** / **TaskList** / **GiftList** / **WhisperList** / **FavouriteList**
- **SystemConfig** / **ImageBedConfig** / **NotificationConfig**（配置与良人同步逻辑在后端）

---

## 项目结构

```
romance-hub/
├── app/                    # Next.js 应用
│   ├── api/v1/             # API：user, task, gift, whisper, favourite, config, common
│   ├── trick/              # Web 页面：config, myInfo, gift, postTask, taskInfo, favourite, whisper
│   ├── components/        # 公共组件
│   └── utils/              # 服务与工具（configService, imageTools, ormService 等）
├── prisma/
│   └── schema.prisma       # 数据模型与迁移
├── flutter_app/            # Flutter 应用「锦书」
│   ├── lib/
│   │   ├── core/           # 配置、模型、路由、服务、工具
│   │   ├── features/      # auth, home, task, gift, whisper, favourite, user, config
│   │   └── shared/        # 通用组件
│   └── docs/              # UI 设计规则等
├── .github/workflows/      # CI（如 Flutter 全平台构建发布）
├── Dockerfile              # 服务端镜像
├── package.json
└── README.md
```

---

## 配置说明

### 必填环境变量

- `DATABASE_URL`：PostgreSQL 连接串。
- `JWT_SECRET_KEY`：Cookie 等鉴权加密用，请使用足够随机的字符串。

### 可选：图床兜底

- 未在「应用内图床设置」配置时，可使用服务端兜底：
  - `DRAWING_BED=IMGBB`
  - `IMGBB_API=你的 key`
- 应用内图床（Web `/trick/config` 或 App 吾心→设置）与良人共用，保存时后端会同步到关联者。

### 数据库常用命令

```bash
yarn db:generate   # 生成 Prisma 客户端
yarn db:push       # 开发环境同步 schema
yarn db:migrate    # 生产迁移
yarn db:studio     # 打开 Prisma Studio
```

---

## 部署

### 服务端（Docker）

```bash
docker build -t romance-hub .
docker run -d -p 9999:9999 --name romance-hub \
  -e DATABASE_URL="postgresql://..." \
  -e JWT_SECRET_KEY="..." \
  romance-hub
```

### 服务端（Vercel）

- 将仓库导入 Vercel，配置 `DATABASE_URL`、`JWT_SECRET_KEY`。
- 建议使用 Vercel Postgres 或 Neon 等 PostgreSQL 服务。

### Flutter App

- 本地：`cd flutter_app && flutter run -d <android|ios|windows|...>`
- 发布：可参考 `.github/workflows/build-release.yml` 构建 Android / Windows / macOS / Linux 等产物。

---

## 常见问题

| 现象 | 建议 |
|------|------|
| 数据库连接失败 | 检查 `DATABASE_URL` 与网络/白名单 |
| 图床上传失败 | 检查应用内图床配置或 `.env` 兜底（IMGBB_API 等） |
| 端口 9999 占用 | 使用 `next dev -p 其他端口` 或结束占用进程 |
| App 连不上后端 | 确认云阁地址（含协议与端口）与后端实际一致 |

---

## 文档与链接

- 详细搭建与说明：[博客文档](https://blog.lengsu.top/article/romance-hub)
- 问题与建议：[GitHub Issues](https://github.com/lengsukq/romance-hub/issues)

---

## 许可证与致谢

- 本项目采用 [MIT](LICENSE) 许可证。
- 致谢 Next.js、Prisma、Flutter、React 等开源项目。

---

<div align="center">

**两心相知，一事一诺。**

Made with ❤️ by [lengsukq](https://github.com/lengsukq)

</div>
