# API 层说明

本目录为 Next.js 服务端 API，**同时对接 Web 端（Next 页面）与 App 端（Flutter）**。任何对请求/响应结构的修改都需兼顾两端。

## 接口与双端使用一览

| 模块 | action | Web 使用处 | App 使用处 | 响应约定 |
|------|--------|------------|------------|----------|
| **user** | login, register, logout | 登录/注册页 | AuthService | 登录返回 userId, userEmail, username, lover, score 等 |
| **user** | info | myInfo, config | UserService.getUserInfo | data: UserInfo（含 avatar, describeBySelf, registrationTime） |
| **user** | lover | myInfo/useUserAndLoverInfo | UserService.getLoverInfo | data: 良人信息（含 userId, username, avatar, describeBySelf, score, registrationTime） |
| **user** | update, score | myInfo, config | UserService | score 返回 data: { score: number }，App 需解析 data.score |
| **task** | list | trick/page.tsx | TaskService.getTaskList | data: { record, totalPages, total, pageSize, current }；record 每项含 publisherName, taskImage 数组 |
| **task** | detail | trick/taskInfo | TaskService.getTaskDetail | data: 单任务，含 taskImage 数组、publisherName、favId、isFavorite |
| **task** | create, update, delete | postTask, taskInfo | TaskService | 无特殊双端差异 |
| **gift** | list | trick/gift/getList | GiftService.getGiftList | data: 数组，每项含 publisherName，不要嵌套 publisher 对象 |
| **gift** | mylist | trick/gift | GiftService.getMyGiftList | 同上，需带 publisherName |
| **gift** | detail | （Web 未用） | GiftService | 单礼物对象，含 publisherName |
| **gift** | create, exchange, use, show | gift 相关页 | GiftService | 无特殊双端差异 |
| **whisper** | mylist, talist | whisper/myWhisper, TAWhisper | WhisperService | data: 数组，每项含 userName/publisherName、creationTime |
| **whisper** | create, delete | whisperForm | WhisperService | 无特殊双端差异 |
| **favourite** | add, remove | 各列表页收藏按钮 | FavouriteService | 无特殊双端差异 |
| **favourite** | list | favourite/taskList, giftList, whisperList | FavouriteService.getFavouriteList | 每项同时含「顶层展开」与「item」嵌套，Web 用顶层 taskId/giftId/whisperId，App 用 favouriteId/collectionId/item |
| **config** | get_image_beds, update_image_bed 等 | trick/config | ConfigService | 两端 action 一致，按现有实现即可 |
| **common** | upload (FormData) | fileTools.imgUpload | UploadService.uploadImage | data: { url: string } |

## 修改接口时请注意

1. **响应结构**：修改任一接口的返回字段或结构时，需同时确认：
   - **Web**：`app/trick/**` 与 `app/utils/client/apihttp.ts` 等处的调用与类型（如 `res.data.record`、`res.data` 的数组元素形状）。
   - **App**：Flutter 中对应 service / model 的解析（如 `TaskModel.fromJson`、`FavouriteModel.fromJson`）。

2. **兼容方式**：
   - 尽量保持「同一套 JSON 结构」两端都能用（例如任务列表的 `record`、每条任务的 `publisherName`）。
   - 若必须区分，可在同一响应里同时包含双方需要的字段（例如收藏列表同时带 `item` 嵌套和顶层展开的 task/gift/whisper 字段）。
   - 列表/详情中涉及「发布人」的，统一返回 `publisherName`（及必要时 `publisherId`），不要只返回嵌套的 `publisher` 对象，避免 App 解析失败。

3. **建议**：改完接口后，在 Web 与 App 各跑一遍相关页面（如心诺列表/详情、赠礼列表、收藏列表、吾心/良人信息、积分），确认无报错、列表与详情展示正常。
