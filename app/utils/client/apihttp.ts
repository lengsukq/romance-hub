import {deleteAct, get, post} from "./fetchUtil";
import type { RegisterParams } from "@/types";

// 基础响应接口
interface BaseResponse {
  code: number;
  msg: string;
  data?: any;
}

// 登录参数接口
interface LoginParams {
  username: string;
  password: string;
}

// 用户信息接口
interface UserInfo {
  userId: number;
  userEmail: string;
  lover: string;
  score: number;
}

// 任务参数接口
interface TaskParams {
  current?: number;
  pageSize?: number;
  taskStatus?: string | null;
  searchWords?: string;
}

// 任务详情参数接口
interface TaskInfoParams {
  taskId: number;
}

// 任务状态更新参数接口（后端 taskStatus 为 string）
interface TaskStateParams {
  taskId: number;
  taskStatus: string;
}

// 图片上传参数接口
interface UploadParams {
  file: File;
}

// 用户信息更新参数接口
interface UserInfoUpdateParams {
  username?: string;
  userEmail?: string;
  lover?: string;
}

// 礼物参数接口（与后端 create 一致）
interface GiftParams {
  giftName?: string;
  giftDetail?: string;
  giftImg?: string;
  needScore?: number;
  remained?: number;
  isShow?: boolean;
}

// 礼物操作参数接口
interface GiftOperationParams {
  giftId: number;
  isShow?: boolean;
}

// 留言参数接口
interface WhisperParams {
  content: string;
  toUser?: string;
}

// 留言查询参数接口
interface WhisperQueryParams {
  searchWords?: string;
}

// 收藏参数接口
interface FavouriteParams {
  collectionId: number;
  collectionType: 'gift' | 'task' | 'whisper';
}

// 收藏查询参数接口
interface FavouriteQueryParams {
  type: 'gift' | 'task' | 'whisper';
}

// 登录接口
export async function loginApi(params: LoginParams): Promise<BaseResponse & { data: UserInfo }> {
    const result = await post(`/api/v1/user`, {
        action: 'login',
        data: params
    });
    return result as BaseResponse & { data: UserInfo };
}

// 退出
export async function logoutApi(): Promise<BaseResponse> {
    return await post(`/api/v1/user`, {
        action: 'logout'
    });
}

// 用户注册
export async function userRegister(params: RegisterParams): Promise<BaseResponse> {
    return post(`/api/v1/user`, {
        action: 'register',
        data: params
    });
}

// 获取用户信息
export async function getUserInfo(): Promise<BaseResponse & { data: UserInfo }> {
    const result = await post(`/api/v1/user`, {
        action: 'info'
    });
    return result as BaseResponse & { data: UserInfo };
}

// 发布任务
export async function postTask(params: any): Promise<BaseResponse> {
    return post(`/api/v1/task`, {
        action: 'create',
        data: params
    });
}

// 获取任务列表
export async function getTask(params: TaskParams): Promise<BaseResponse> {
    return await post(`/api/v1/task`, {
        action: 'list',
        data: params
    });
}

// 获取任务详情
export async function getTaskInfo(params: TaskInfoParams): Promise<BaseResponse> {
    return await post(`/api/v1/task`, {
        action: 'detail',
        data: params
    });
}

// 更新任务状态
export async function upDateTaskState(params: TaskStateParams): Promise<BaseResponse> {
    return await post(`/api/v1/task`, {
        action: 'update',
        data: params
    });
}

// 删除任务
export async function deleteTask(params: TaskInfoParams): Promise<BaseResponse> {
    return await post(`/api/v1/task`, {
        action: 'delete',
        data: params
    });
}

// 上传图片
export async function uploadImages(params: FormData): Promise<BaseResponse> {
    return await post(`/api/v1/common`, {
        action: 'upload'
    }, {
        type: 'FormData',
        body: params,
        headers: {}
    });
}

// 更新用户信息
export async function updateUserInfo(params: UserInfoUpdateParams): Promise<BaseResponse> {
    return post(`/api/v1/user`, {
        action: 'update',
        data: params
    });
}

// 获取积分余额
export async function getScore(): Promise<BaseResponse & { data: { score: number } }> {
    const result = await post(`/api/v1/user`, {
        action: 'score'
    });
    return result as BaseResponse & { data: { score: number } };
}

// 发布礼物信息
export async function addGift(params: GiftParams): Promise<BaseResponse> {
    return post(`/api/v1/gift`, {
        action: 'create',
        data: params
    });
}

// 获取我的礼物列表
export async function getMyGift(params: { type?: string; searchWords?: string }): Promise<BaseResponse> {
    return await post(`/api/v1/gift`, {
        action: 'mylist',
        data: params
    });
}

// 获取礼物兑换列表
export async function getGiftList(params: { searchWords?: string }): Promise<BaseResponse> {
    return await post(`/api/v1/gift`, {
        action: 'list',
        data: params
    });
}

// 兑换礼物
export async function exchangeGift(params: { giftId: number }): Promise<BaseResponse> {
    return await post(`/api/v1/gift`, {
        action: 'exchange',
        data: params
    });
}

// 上架，下架礼物
export async function showGift(params: GiftOperationParams): Promise<BaseResponse> {
    return post(`/api/v1/gift`, {
        action: 'show',
        data: params
    });
}

// 使用礼物
export async function useGift(params: { giftId: number }): Promise<BaseResponse> {
    return await post(`/api/v1/gift`, {
        action: 'use',
        data: params
    });
}

// 发布留言
export async function addWhisper(params: WhisperParams): Promise<BaseResponse> {
    return post(`/api/v1/whisper`, {
        action: 'create',
        data: params
    });
}

// 获取我的留言列表
export async function getMyWhisper(params: WhisperQueryParams): Promise<BaseResponse> {
    return await post(`/api/v1/whisper`, {
        action: 'mylist',
        data: params
    });
}

// 获取TA的留言列表
export async function getTAWhisper(params: WhisperQueryParams): Promise<BaseResponse> {
    return await post(`/api/v1/whisper`, {
        action: 'talist',
        data: params
    });
}

// 添加收藏
export async function addFav(params: FavouriteParams): Promise<BaseResponse> {
    return post(`/api/v1/favourite`, {
        action: 'add',
        data: params
    });
}

// 移除收藏
export async function removeFav(params: FavouriteParams): Promise<BaseResponse> {
    return post(`/api/v1/favourite`, {
        action: 'remove',
        data: params
    });
}

// 获取收藏列表
export async function getFav(params: FavouriteQueryParams): Promise<BaseResponse> {
    return post(`/api/v1/favourite`, {
        action: 'list',
        data: params
    });
}
