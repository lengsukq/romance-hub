# Web 端与 App 端功能/API 对齐记录

本文档以 `app/api/README.md`、`app/api/v1/**/route.ts` 与 Web 调用层
`app/utils/client/apihttp.ts` 为基准，记录 Flutter App 与 Web 共用 API 的对齐状态。

## 一、当前已对齐的能力

| 模块 | Web 能力 | App 状态 | 关键文件 |
| --- | --- | --- | --- |
| 登录/注册 | 登录、双账号注册、Cookie 会话 | 已对齐 | `features/auth/services/auth_service.dart` |
| 用户信息 | 本人、良人、积分、编辑资料 | 已对齐 | `core/services/user_service.dart`, `features/config/pages/config_page.dart` |
| 任务 | 列表/分页/搜索/筛选、详情、创建、状态更新、删除、收藏 | 已对齐；分页元信息已兼容 | `core/services/task_service.dart`, `core/models/task_model.dart` |
| 礼物 | 列表、我的礼物、创建、兑换、使用、上架/下架、详情/更新接口 | 已对齐；App service 已补齐 detail/update | `core/services/gift_service.dart` |
| 私语 | 我的/TA 列表、创建、删除、收藏 | 已对齐 | `core/services/whisper_service.dart` |
| 收藏 | 添加、移除、按类型列表 | 已对齐；同时兼容 nested `item` 与顶层展开字段 | `core/services/favourite_service.dart`, `core/models/favourite_model.dart` |
| 配置 | 图床、通知、系统配置、初始化配置 | 已对齐，App 设置页提供最小可用管理入口 | `core/services/config_service.dart`, `features/config/pages/config_page.dart` |
| 上传 | `POST /api/v1/common` multipart `file` | 已对齐 | `core/services/upload_service.dart` |
| 首页 | 今日一言、相守天数、入口导航 | 已对齐；今日一言改为走后端 `/api/v1/sweet-talk` | `core/services/sweet_talk_service.dart`, `features/home/pages/home_page.dart` |

## 二、接口契约要点

所有业务模块基本采用以下结构：

```json
{
  "action": "list",
  "data": {}
}
```

响应统一为：

```json
{
  "code": 200,
  "msg": "success",
  "data": {}
}
```

例外：图片上传接口与 Web 一致，使用：

```txt
POST /api/v1/common
multipart/form-data
file=<image>
```

## 三、已重点兼容的历史差异

- 任务图片：兼容 `taskImage` 为数组、字符串、逗号分隔字符串。
- 任务分页：App 现在可解析 `record,total,pageSize,totalPages,current`。
- 任务状态：App 默认状态统一为后端/Web 生命周期值 `pending`，避免中文默认值混入业务判断。
- 礼物字段：兼容 `giftImg/giftImage`、`giftDetail/giftDesc`、`needScore/score`。
- 收藏列表：优先读取 nested `item`，缺失时回退读取顶层展开字段。
- 配置字段：图床/通知布尔值兼容 bool、数字、字符串。
- 今日一言：App 不再直接请求外部情话 API，而是复用 Web 后端代理 `/api/v1/sweet-talk`。

## 四、后续维护建议

1. 修改 `app/api/v1/**/route.ts` 返回结构时，同步检查：
   - Web：`app/trick/**`、`app/utils/client/apihttp.ts`
   - App：`flutter_app/lib/core/services/**`、`flutter_app/lib/core/models/**`
2. 列表接口涉及发布人时，继续返回扁平字段 `publisherName` / `publisherId`，不要只返回嵌套对象。
3. 收藏列表继续同时返回 nested `item` 与顶层展开字段，保证 Web/App 双端兼容。
4. App 端模型解析应继续保持宽松兼容，避免后端字段类型轻微变化导致页面崩溃。
