# Web 端与 App 端功能对比

本文档列出 Web 端已实现、但 App 端尚未实现或未完全对齐的功能，便于按优先级补齐。

---

## 一、已对齐的功能 ✅

| 功能模块 | Web | App | 说明 |
|---------|-----|-----|------|
| 登录 / 注册 | ✅ | ✅ | 双账号注册、登录、后端地址配置 |
| 任务列表 | ✅ | ✅ | 分页、筛选、搜索 |
| 任务详情 | ✅ | ✅ | 查看、收藏、删除、更新状态 |
| 发布任务 | ✅ | ✅ | 多图上传 |
| 可兑换礼物列表 | ✅ | ✅ | getList / getGiftList，兑换、收藏 |
| 添加礼物 | ✅ | ✅ | 创建礼物、图片上传 |
| 我的留言 / TA的留言 | ✅ | ✅ | mylist / talist，收藏 |
| 发布留言 | ✅ | ✅ | create |
| 收藏管理 | ✅ | ✅ | 任务/礼物/留言收藏列表、添加/取消收藏 |
| 用户信息 | ✅ | ✅ | 本人信息、关联者信息、积分 |
| 退出登录 | ✅ | ✅ | 我的页退出 |
| 设置页基础 | ✅ | ✅ | 用户信息编辑、关于 |

---

## 二、App 端缺失或未完全实现的功能

### 1. 我的礼物（货架）— ✅ 已实现

**Web 行为：** 路由 `/trick/gift`，按类型筛选（已上架、已下架、待使用、已用完），使用礼物、上架/下架。

**App 实现：**

- 新增「我的礼物」页 `/my-gifts`（`MyGiftListPage`），调用 `getMyGiftList(type, searchWords)`
- 类型筛选：已上架、已下架、待使用、已用完（FilterChip）
- 待使用：展示「使用」按钮，调用 `useGift`
- 已上架/已下架：展示「下架」/「上架」按钮，调用 `toggleGiftShow`
- 首页新增「我的礼物」卡片；礼物列表页 AppBar 增加「我的礼物」入口
- `GiftModel` 兼容后端字段（giftDetail/giftImg/needScore/remained/publisherEmail）并支持 `remained`

---

### 2. 留言删除 — ✅ 已实现

**Web 行为：** 接口 `delete`，data: `{ whisperId }`。

**App 实现：**

- `WhisperService` 新增 `deleteWhisper(whisperId)`
- 「我的留言」列表项右侧增加删除图标按钮，仅当 `type == 'my'` 时展示
- 删除前弹出确认对话框，删除成功后从列表移除并提示

---

### 3. 配置页扩展 — 中低优先级

**Web 行为：**

- 路由：`/trick/config`
- 除「用户信息编辑」外还有：
  - **图床配置**：多图床管理（增删改、默认图床等）
  - **通知配置**：如 webhook、通知方式等
  - **系统配置**：如 WEB_URL 等

**App 现状：**

- 配置页仅有：用户信息编辑（用户名、描述、头像 URL）、关于

**建议：**

- 若 App 需要上传图片到自建图床，可后续增加「图床配置」的简化版（例如仅选默认图床）
- 通知/系统配置可视产品需求决定是否在 App 暴露，通常优先级低于「我的礼物」和「留言删除」

---

### 4. 头像编辑方式 — 低优先级

**Web 行为：**

- 我的信息 / 配置：头像支持**选择本地图片 + 上传**，得到 URL 再保存

**App 现状：**

- 配置页头像为「输入头像 URL」的文本框，无本地选图与上传

**建议：**

- 在配置页（或用户信息页）增加「从相册选择图片 → 调用上传接口 → 将返回 URL 写入头像」的流程，与 Web 行为一致

---

## 三、API 使用情况简要对照

| 模块 | Web 使用的 action | App 是否调用 |
|------|-------------------|-------------|
| user | login, register, logout, info, update, score, lover | ✅ 全部已用 |
| task | list, detail, create, update, delete | ✅ 全部已用 |
| gift | list, **mylist**, detail, create, update, exchange, use, show | ❌ **mylist / use / show 未在「我的礼物」中使用** |
| whisper | mylist, talist, create, **delete** | ❌ **delete 未实现** |
| favourite | add, remove, list | ✅ 全部已用 |
| config | get_image_beds, get_notifications, get_system_configs, update_*, initialize_configs | ❌ App 未用（仅用户信息走 user/update） |

---

## 四、建议实现顺序

1. **留言删除**：接口已有，只差 App 端调用与列表/详情上的删除入口。
2. **我的礼物**：新页面 + getMyGiftList + useGift + showGift，与 Web「货架」一致。
3. **配置页扩展**：按需求做图床/通知/系统配置的简化版。
4. **头像上传**：配置页或用户信息页增加选图上传，替换或补充当前 URL 输入。

完成 1、2 后，App 与 Web 在「任务、礼物、留言、收藏、用户信息」上的能力可基本对齐；3、4 可按产品规划迭代。
