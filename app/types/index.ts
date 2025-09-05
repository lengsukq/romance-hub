// 全局类型定义文件

// 基础响应接口
export interface BaseResponse<T = any> {
  code: number;
  msg: string;
  data?: T;
}

// 用户相关类型
export interface UserInfo {
  userId: number;
  userEmail: string;
  lover: string;
  score: number;
  username?: string;
  avatar?: string;
  describeBySelf?: string;
  registrationTime?: string;
}

export interface LoginParams {
  username: string;
  password: string;
}

export interface RegisterParams extends LoginParams {
  userEmail: string;
  describeBySelf: string;
  lover: string;
  avatar?: string;
  // 新增关联者信息字段
  loverUsername?: string;
  loverAvatar?: string;
  loverDescribeBySelf?: string;
}

// 任务相关类型
export interface TaskItem {
  taskId: number;
  taskName: string;
  creationTime: string;
  taskImage: string[];
  taskScore: number;
  publisherName: string;
  taskStatus: string;
  taskDesc?: string;
  publisherId?: string;
  recipientId?: string;
  completionTime?: string;
}

export interface TaskParams {
  current?: number;
  pageSize?: number;
  taskStatus?: string | null;
  searchWords?: string;
}

export interface TaskInfoParams {
  taskId: number;
}

export interface TaskStateParams {
  taskId: number;
  taskStatus: number;
}

export interface PostTaskParams {
  taskName: string;
  taskDesc: string;
  taskImage: string[];
  taskScore: number;
  recipientId?: string;
}

// 礼物相关类型
export interface GiftItem {
  giftId: number;
  giftName: string;
  giftDesc: string;
  giftImage: string;
  score: number;
  publisherId: string;
  publisherName: string;
  isShow: boolean;
  creationTime: string;
  exchangeStatus?: string;
  exchangeTime?: string;
  recipientId?: string;
}

export interface GiftParams {
  giftName?: string;
  giftDesc?: string;
  giftImage?: string;
  score?: number;
}

export interface GiftOperationParams {
  giftId: number;
  isShow?: boolean;
}

export interface GiftQueryParams {
  type?: string;
  searchWords?: string;
}

// 留言相关类型
export interface WhisperItem {
  whisperId: number;
  title?: string;
  content: string;
  fromUserId: string;
  fromUserName: string;
  toUserId: string;
  toUserName: string;
  userName: string;
  creationTime: string;
  isRead?: boolean;
  favId?: number | null;
}

export interface WhisperParams {
  content: string;
  toUser?: string;
}

export interface WhisperQueryParams {
  searchWords?: string;
}

// 收藏相关类型
export interface FavouriteParams {
  collectionId: number;
  collectionType: 'gift' | 'task' | 'whisper';
}

export interface FavouriteQueryParams {
  type: 'gift' | 'task' | 'whisper';
}

export interface FavouriteItem {
  favouriteId: number;
  collectionId: number;
  collectionType: 'gift' | 'task' | 'whisper';
  userId: string;
  creationTime: string;
  item?: TaskItem | GiftItem | WhisperItem;
}

// HTTP 请求相关类型
export interface HttpOptions {
  method?: string;
  headers?: HeadersInit;
  credentials?: RequestCredentials;
  mode?: RequestMode;
  body?: string | FormData;
  type?: string;
  Type?: string;
}

export interface RequestParams {
  [key: string]: any;
}

// 文件上传相关类型
export interface UploadParams {
  file: File;
}

export interface UploadResponse {
  url: string;
  filename: string;
}

// 分页相关类型
export interface PaginationParams {
  current?: number;
  pageSize?: number;
}

export interface PaginationResponse<T = any> {
  list: T[];
  total: number;
  current: number;
  pageSize: number;
  hasMore?: boolean;
}

// 搜索相关类型
export interface SearchParams {
  searchWords?: string;
  searchType?: string;
}

// 状态枚举
export enum TaskStatus {
  PENDING = 'pending',
  ACCEPTED = 'accepted', 
  COMPLETED = 'completed',
  CANCELLED = 'cancelled'
}

export enum GiftStatus {
  ON_SALE = 'on_sale',
  OFF_SALE = 'off_sale',
  EXCHANGED = 'exchanged',
  USED = 'used'
}

// 组件Props类型
export interface ComponentProps {
  children?: React.ReactNode;
  className?: string;
}

// 常用的事件处理器类型
export type EventHandler<T = HTMLElement> = (event: React.SyntheticEvent<T>) => void;
export type ChangeHandler<T = HTMLInputElement> = (event: React.ChangeEvent<T>) => void;
export type ClickHandler<T = HTMLElement> = (event: React.MouseEvent<T>) => void;

// 数据库查询相关类型
export interface DBQueryParams {
  query: string;
  values?: any[];
}

export interface DBResult {
    affectedRows?: number;
    insertId?: number;
    [key: string]: any;
}

export interface DBInsertResult {
    insertId: number;
    affectedRows: number;
}

// Cookie工具相关类型
export interface CookieData {
  userEmail: string;
  userId: number;
  userName: string;
  lover: string;
}

// 业务结果类型
export interface BizResultType<T = any> {
  code: number;
  desc: string;
  data: T;
  success: boolean;
}
