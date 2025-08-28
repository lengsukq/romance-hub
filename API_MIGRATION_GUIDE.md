# API 重构迁移指南

## 概述

本项目已将所有API接口重构为统一的POST接口，使用TypeScript重写，提供更好的类型安全和代码维护性。

## 新API结构

### 1. 用户相关API - `/api/v1/user`

**统一POST接口，通过action参数区分不同操作：**

```typescript
// 登录
POST /api/v1/user
{
    "action": "login",
    "data": {
        "username": "用户名",
        "password": "密码"
    }
}

// 注册
POST /api/v1/user
{
    "action": "register", 
    "data": {
        "userEmail": "邮箱",
        "username": "用户名",
        "password": "密码",
        "describeBySelf": "自我描述",
        "lover": "关联者邮箱",
        "avatar": "头像URL(可选)"
    }
}

// 退出登录
POST /api/v1/user
{
    "action": "logout"
}

// 获取用户信息
POST /api/v1/user
{
    "action": "info"
}

// 更新用户信息
POST /api/v1/user
{
    "action": "update",
    "data": {
        "username": "新用户名(可选)",
        "lover": "新关联者(可选)",
        "avatar": "新头像(可选)",
        "describeBySelf": "新描述(可选)"
    }
}

// 获取积分
POST /api/v1/user
{
    "action": "score"
}
```

### 2. 任务相关API - `/api/v1/task`

```typescript
// 获取任务列表
POST /api/v1/task
{
    "action": "list",
    "data": {
        "taskStatus": "任务状态(可选)",
        "searchWords": "搜索关键词(可选)",
        "current": 1,
        "pageSize": 10
    }
}

// 获取任务详情
POST /api/v1/task
{
    "action": "detail",
    "data": {
        "taskId": "任务ID"
    }
}

// 创建任务
POST /api/v1/task
{
    "action": "create",
    "data": {
        "taskName": "任务名称",
        "taskDesc": "任务描述", 
        "taskImage": ["图片URL数组"],
        "taskScore": 积分数,
        "receiverEmail": "接收者邮箱(可选)"
    }
}

// 更新任务
POST /api/v1/task
{
    "action": "update",
    "data": {
        "taskId": "任务ID",
        "taskStatus": 状态码,
        "taskName": "新任务名(可选)",
        "taskDesc": "新描述(可选)",
        "taskImage": ["新图片数组(可选)"],
        "taskScore": 新积分(可选)
    }
}

// 删除任务
POST /api/v1/task
{
    "action": "delete",
    "data": {
        "taskId": "任务ID"
    }
}
```

### 3. 礼物相关API - `/api/v1/gift`

```typescript
// 获取可兑换礼物列表
POST /api/v1/gift
{
    "action": "list",
    "data": {
        "searchWords": "搜索关键词(可选)"
    }
}

// 获取我的礼物列表
POST /api/v1/gift
{
    "action": "mylist",
    "data": {
        "searchWords": "搜索关键词(可选)",
        "type": "筛选类型(可选): 已上架|已下架|待使用|已用完"
    }
}

// 创建礼物
POST /api/v1/gift
{
    "action": "create",
    "data": {
        "giftName": "礼物名称",
        "giftDetail": "礼物描述",
        "needScore": 所需积分,
        "remained": 库存数量,
        "giftImg": "礼物图片URL(可选)",
        "isShow": true
    }
}

// 兑换礼物
POST /api/v1/gift
{
    "action": "exchange",
    "data": {
        "giftId": "礼物ID"
    }
}

// 使用礼物
POST /api/v1/gift
{
    "action": "use",
    "data": {
        "giftId": "礼物ID"
    }
}

// 上架/下架礼物
POST /api/v1/gift
{
    "action": "show",
    "data": {
        "giftId": "礼物ID",
        "isShow": true
    }
}
```

### 4. 留言相关API - `/api/v1/whisper`

```typescript
// 获取我的留言列表
POST /api/v1/whisper
{
    "action": "mylist",
    "data": {
        "searchWords": "搜索关键词(可选)"
    }
}

// 获取TA的留言列表
POST /api/v1/whisper
{
    "action": "talist",
    "data": {
        "searchWords": "搜索关键词(可选)"
    }
}

// 创建留言
POST /api/v1/whisper
{
    "action": "create",
    "data": {
        "content": "留言内容",
        "toUser": "目标用户邮箱(可选,默认为关联者)"
    }
}

// 删除留言
POST /api/v1/whisper
{
    "action": "delete",
    "data": {
        "whisperId": "留言ID"
    }
}
```

### 5. 收藏相关API - `/api/v1/favourite`

```typescript
// 添加收藏
POST /api/v1/favourite
{
    "action": "add",
    "data": {
        "collectionId": "收藏对象ID",
        "collectionType": "task|gift|whisper"
    }
}

// 移除收藏
POST /api/v1/favourite
{
    "action": "remove",
    "data": {
        "collectionId": "收藏对象ID",
        "collectionType": "task|gift|whisper"
    }
}

// 获取收藏列表
POST /api/v1/favourite
{
    "action": "list",
    "data": {
        "type": "task|gift|whisper",
        "searchWords": "搜索关键词(可选)"
    }
}
```

### 6. 通用API - `/api/v1/common`

```typescript
// 文件上传 (使用multipart/form-data)
POST /api/v1/common
Content-Type: multipart/form-data
{
    file: File对象,
    base64: base64字符串(可选)
}

// 健康检查
POST /api/v1/common
{
    "action": "health"
}

// 或者使用GET
GET /api/v1/common
```

## 统一响应格式

所有API都返回统一的响应格式：

```typescript
{
    "code": 200,           // 状态码，200表示成功
    "msg": "操作成功",      // 提示信息
    "data": {},           // 返回数据
    "time": 1701234567890  // 时间戳
}
```

## 旧API与新API对照表

| 旧API | 新API | 说明 |
|-------|-------|------|
| GET /api/user | POST /api/v1/user (action: login) | 用户登录 |
| POST /api/user | POST /api/v1/user (action: register) | 用户注册 |
| GET /api/user/logout | POST /api/v1/user (action: logout) | 退出登录 |
| GET /api/userInfo | POST /api/v1/user (action: info) | 获取用户信息 |
| POST /api/userInfo | POST /api/v1/user (action: update) | 更新用户信息 |
| GET /api/userInfo/score | POST /api/v1/user (action: score) | 获取积分 |
| GET /api/trick/getTaskList | POST /api/v1/task (action: list) | 获取任务列表 |
| GET /api/trick/getTaskInfo | POST /api/v1/task (action: detail) | 获取任务详情 |
| POST /api/trick/postTask | POST /api/v1/task (action: create) | 创建任务 |
| POST /api/gift/addGift | POST /api/v1/gift (action: create) | 创建礼物 |
| GET /api/gift/getGiftList | POST /api/v1/gift (action: list) | 获取礼物列表 |
| GET /api/gift/getMyGift | POST /api/v1/gift (action: mylist) | 获取我的礼物 |
| GET /api/gift/exchangeGift | POST /api/v1/gift (action: exchange) | 兑换礼物 |
| GET /api/gift/useGift | POST /api/v1/gift (action: use) | 使用礼物 |
| GET /api/gift/showGift | POST /api/v1/gift (action: show) | 上架/下架礼物 |
| POST /api/whisper/addWhisper | POST /api/v1/whisper (action: create) | 创建留言 |
| GET /api/whisper/getMyWhisper | POST /api/v1/whisper (action: mylist) | 获取我的留言 |
| GET /api/whisper/getTAWhisper | POST /api/v1/whisper (action: talist) | 获取TA的留言 |
| POST /api/favourite/addFav | POST /api/v1/favourite (action: add) | 添加收藏 |
| POST /api/favourite/getFav | POST /api/v1/favourite (action: list) | 获取收藏列表 |
| POST /api/image-api | POST /api/v1/common | 图片上传 |

## 前端迁移指南

### 1. 更新API调用文件 `app/utils/client/apihttp.ts`

需要更新所有API调用函数，将它们改为调用新的统一接口。

### 2. 示例迁移

**旧代码：**
```typescript
// 获取任务列表
export async function getTask(params: TaskParams): Promise<BaseResponse> {
    return await get(`/api/trick/getTaskList`, params);
}
```

**新代码：**
```typescript
// 获取任务列表
export async function getTask(params: TaskParams): Promise<BaseResponse> {
    return await post(`/api/v1/task`, {
        action: 'list',
        data: params
    });
}
```

## 优势

1. **统一性**: 所有接口都使用POST方法，参数传递方式一致
2. **类型安全**: 完整的TypeScript类型定义
3. **可维护性**: 相关功能集中在同一个文件中
4. **扩展性**: 通过action参数可以轻松添加新功能
5. **版本控制**: 通过/v1路径支持API版本管理

## 注意事项

1. 所有接口都需要登录状态（除了登录和注册）
2. 文件上传接口使用multipart/form-data格式
3. 其他接口都使用application/json格式
4. 错误处理统一，返回格式一致
5. 旧API接口建议逐步废弃，完成迁移后删除
