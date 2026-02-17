# App 与 Web 功能对比

## 一、功能矩阵总览

| 模块 | 功能点 | App (Flutter) | Web (Next.js) | 说明 |
|------|--------|---------------|---------------|------|
| **登录/注册** | 登录 | ✅ /login | ✅ / (根页) | Web 根路径即登录页 |
| | 注册 | ✅ /register | ✅ 弹窗/组件 | Web 为「点击头像注册」 |
| **首页** | 今日一言 | ✅ 情话卡片 + 复制/更新 | ✅ 已对齐 | 同一 API 代理 |
| | 入口导航 | ✅ 心诺/赠礼/私语/藏心 + **我的赠礼** | ✅ 心诺/赠礼/私语/藏心/设置/吾心 | 见下差异 |
| **心诺** | 列表 | ✅ 分页+状态筛选+搜索 | ✅ 分页+状态筛选+搜索 | 一致 |
| | 立一诺 | ✅ /post-task | ✅ /trick/postTask | 一致 |
| | 详情 | ✅ 收藏/删除/多图预览 | ✅ 收藏/删除 | Web 缺多图点击全屏预览 |
| | 接受/完成任务 | ❌ 无按钮 | ❌ 无按钮 | 后端有 updateTask，两端均未做 UI |
| **赠礼** | 可兑列表 | ✅ | ✅ /trick/gift/getList | 一致 |
| | 兑换 | ✅ | ✅ | 一致 |
| | 上架 | ✅ /add-gift | ✅ /trick/gift/addGift | 一致 |
| | 吾架（我的赠礼） | ✅ /my-gifts | ✅ /trick/gift（下拉：已上架/已下架/待使用/已用完） | 一致 |
| | 使用礼物 | ✅ | ✅ | 一致 |
| **私语** | 良人/吾之列表 | ✅ type=my\|ta | ✅ TAWhisper / myWhisper | 一致 |
| | 写私语 | ✅ /post-whisper | ✅ /trick/whisper | 一致 |
| **藏心** | 收藏列表 | ✅ type=task\|gift\|whisper | ✅ taskList/giftList/whisperList | 一致 |
| **吾心** | 吾之信息/良人信息 | ✅ | ✅ | 一致 |
| | 一言 | ✅ 展示+编辑 | ✅ 展示+编辑 | 已对齐 |
| | 设置入口 | ✅ 单入口进配置页 | ✅ 单入口进 /trick/config | 一致 |
| **设置/配置** | 吾之信息编辑 | ✅ 配置页内 | ✅ 配置页内 | 一致 |
| | 图床 | ✅ | ✅ | 一致 |
| | 通知配置 | ✅ | ✅ | 已对齐 |
| | 系统配置 (WEB_URL) | ✅ | ✅ | 已对齐 |
| | 关于 | ✅ | ✅ | 一致 |
| **云阁/后端地址** | 配置 BaseURL | ✅ 吾心页「云阁」 | ❌ 已按需求去掉 | 有意差异 |

---

## 二、差异与可补功能

### 1. 首页入口

- **已对齐**：Web 首页已增加「我的赠礼」卡片，跳转 `/trick/gift`（吾架），与 App 一致。

### 2. 任务详情

- **已对齐**：
  - **接受/完成任务**：Web 与 App 任务详情页均已增加「接受」「完成任务」按钮（接受者可见「接受」，进行中时发布者/接受者可见「完成任务」），并调用更新状态接口。
  - **多图预览**：Web 任务详情支持多图点击，打开全屏 Modal 可切换上一张/下一张，与 App ImageViewer 行为一致。

### 3. 任务详情时间展示

- **已对齐**：App 任务详情与私语列表等已使用 `DateUtils.formatDateTimeDisplay`（yyyy-MM-dd HH:mm），与 Web `formatDateTime` 一致。

### 4. 其他

- **藏心入口**：App 首页「藏心」→ 收藏列表再选 type；Web 首页「藏心」→ 直接进心诺收藏，底部 SectionTabs 可切赠礼/私语。能力一致，仅首屏默认不同。
- **日期显示**：Web 已统一用 `formatDateTime`/`formatDate`；App 除部分页面外，日期未统一工具，可按需在 App 抽公共格式化方法并逐步替换。

---

## 三、路由对照（便于对照实现）

| 能力 | App 路径 | Web 路径 |
|------|----------|----------|
| 登录 | /login | / |
| 注册 | /register | 注册组件/弹窗 |
| 首页 | /index | /trick/home |
| 心诺列表 | /tasks | /trick |
| 立一诺 | /post-task | /trick/postTask |
| 任务详情 | /task/:taskId | /trick/taskInfo?taskId= |
| 赠礼可兑 | /gifts | /trick/gift/getList |
| 吾架 | /my-gifts | /trick/gift |
| 上架 | /add-gift | /trick/gift/addGift |
| 私语列表 | /whispers?type=my\|ta | /trick/whisper/TAWhisper 或 myWhisper |
| 写私语 | /post-whisper | /trick/whisper |
| 藏心 | /favourites?type= | /trick/favourite/taskList 等 |
| 吾心 | /user-info | /trick/myInfo |
| 设置 | /config | /trick/config |

---

## 四、总结

- **已对齐**：今日一言、一言展示与编辑、设置（图床/通知/系统配置）、单设置入口、日期格式化（Web 已做）。
- **有意差异**：Web 不配置「云阁/后端地址」。
- **可补**：  
  1）Web 首页增加「我的赠礼」入口；  
  2）任务详情「接受/完成任务」按钮（两端均可做）；  
  3）Web 任务详情多图点击全屏预览；  
  4）App 任务详情及全局日期统一格式化。
