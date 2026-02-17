import BizResult from '@/utils/BizResult';
import { FavouriteService } from '@/utils/ormService';
import { cookieTools } from "@/utils/cookieTools";
import { NextRequest, NextResponse } from 'next/server';
import { FavouriteItem, BaseResponse } from '@/types';

// 请求体接口
interface FavouriteRequest {
    action: 'add' | 'remove' | 'list';
    data?: any;
}

// 添加/移除收藏参数
interface FavouriteOperationData {
    collectionId: number;
    collectionType: 'gift' | 'task' | 'whisper';
}

// 获取收藏列表参数
interface FavouriteListData {
    type: 'gift' | 'task' | 'whisper';
    searchWords?: string;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        const body: FavouriteRequest = await req.json();
        const { action, data } = body;

        switch (action) {
            case 'add':
                return await handleAddFavourite(req, data as FavouriteOperationData);
            
            case 'remove':
                return await handleRemoveFavourite(req, data as FavouriteOperationData);
            
            case 'list':
                return await handleGetFavouriteList(req, data as FavouriteListData);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('收藏API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 导出 GET 方法以避免构建时错误
export async function GET(): Promise<NextResponse> {
    return NextResponse.json(BizResult.fail('', '请使用 POST 方法'));
}

// 添加收藏
async function handleAddFavourite(req: NextRequest, data: FavouriteOperationData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { collectionId, collectionType } = data;

        if (!collectionId || !collectionType) {
            return NextResponse.json(BizResult.fail('', '参数不完整'));
        }

        // 检查是否已经收藏
        const existingFav = await FavouriteService.checkFavouriteExists(userEmail, collectionId.toString(), collectionType);

        if (existingFav) {
            return NextResponse.json(BizResult.fail('', '已经收藏过了'));
        }

        // 验证收藏对象是否存在
        const itemExists = await FavouriteService.validateCollectionItem(collectionId.toString(), collectionType);

        if (!itemExists) {
            return NextResponse.json(BizResult.fail('', '收藏对象不存在'));
        }

        // 添加收藏
        const result = await FavouriteService.addFavourite({
            userEmail,
            collectionId: collectionId.toString(),
            collectionType
        });

        return NextResponse.json(BizResult.success({ favId: result.favId }, '收藏成功'));

    } catch (error) {
        console.error('添加收藏失败:', error);
        return NextResponse.json(BizResult.fail('', '收藏失败'));
    }
}

// 移除收藏
async function handleRemoveFavourite(req: NextRequest, data: FavouriteOperationData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { collectionId, collectionType } = data;

        if (!collectionId || !collectionType) {
            return NextResponse.json(BizResult.fail('', '参数不完整'));
        }

        // 检查收藏是否存在
        const existingFav = await FavouriteService.checkFavouriteExists(userEmail, collectionId.toString(), collectionType);

        if (!existingFav) {
            return NextResponse.json(BizResult.fail('', '尚未收藏'));
        }

        // 移除收藏
        await FavouriteService.removeFavourite(userEmail, collectionId.toString(), collectionType);

        return NextResponse.json(BizResult.success('', '取消收藏成功'));

    } catch (error) {
        console.error('移除收藏失败:', error);
        return NextResponse.json(BizResult.fail('', '取消收藏失败'));
    }
}

// 获取收藏列表
async function handleGetFavouriteList(req: NextRequest, data: FavouriteListData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { type, searchWords = '' } = data;

        if (!type) {
            return NextResponse.json(BizResult.fail('', '请指定收藏类型'));
        }

        let result: any[] = [];

        switch (type) {
            case 'task':
                result = await FavouriteService.getTaskFavourites(userEmail, searchWords);
                break;
                
            case 'gift':
                result = await FavouriteService.getGiftFavourites(userEmail, searchWords);
                break;
                
            case 'whisper':
                result = await FavouriteService.getWhisperFavourites(userEmail, searchWords);
                break;
                
            default:
                return NextResponse.json(BizResult.fail('', '不支持的收藏类型'));
        }

        // 格式化返回数据：同时兼容 Web 与 App
        // - Web：期望数组每项为「扁平」结构，直接有 taskId/giftId/whisperId 等，用于 TaskCard / GiftList / WhisperForm
        // - App：期望每项有 favouriteId, collectionId, userId, creationTime, item（嵌套）
        // 因此每项同时包含 base + item（嵌套）+ 展开 item 到顶层，便于 Web 直接当 TaskItem[]/GiftItem[]/WhisperItem[] 使用
        const formattedResult = result.map((item: any) => {
            const collectionIdNum = parseInt(item.collectionId, 10) || 0;
            const baseData = {
                favouriteId: item.favId,
                collectionId: collectionIdNum,
                collectionType: item.collectionType,
                userId: userEmail,
                creationTime: item.creationTime != null ? String(item.creationTime) : '',
            };

            if (type === 'task' && item.task) {
                const t = item.task;
                const taskImage = typeof t.taskImage === 'string' ? (t.taskImage ? t.taskImage.split(',') : []) : (t.taskImage || []);
                const taskItem = {
                    taskId: t.taskId,
                    taskName: t.taskName,
                    taskDesc: t.taskDesc ?? null,
                    taskImage,
                    taskScore: t.taskScore ?? 0,
                    taskStatus: t.taskStatus ?? '未开始',
                    creationTime: t.creationTime != null ? String(t.creationTime) : '',
                    completionTime: t.completionTime != null ? String(t.completionTime) : null,
                    isApprove: t.isApprove !== 0 && t.isApprove !== false,
                    publisherEmail: t.publisherEmail,
                    receiverEmail: t.receiverEmail ?? null,
                    publisherName: t.publisher?.username ?? t.publisherEmail ?? '',
                    publisherId: t.publisherEmail,
                    recipientId: t.receiverEmail ?? null,
                };
                return { ...baseData, item: taskItem, ...taskItem };
            }
            if (type === 'gift' && item.gift) {
                const g = item.gift;
                const giftItem = {
                    giftId: g.giftId,
                    giftName: g.giftName,
                    giftDetail: g.giftDetail ?? null,
                    giftImg: g.giftImg ?? null,
                    needScore: g.needScore ?? 0,
                    remained: g.remained ?? 0,
                    isShow: g.isShow !== false,
                    creationTime: g.creationTime != null ? String(g.creationTime) : '',
                    publisherEmail: g.publisherEmail,
                    publisherName: g.publisher?.username ?? g.publisherEmail ?? '',
                    publisherId: g.publisherEmail,
                };
                return { ...baseData, item: giftItem, ...giftItem };
            }
            if (type === 'whisper' && item.whisper) {
                const w = item.whisper;
                const whisperItem = {
                    whisperId: w.whisperId,
                    title: w.title ?? null,
                    content: w.content ?? '',
                    publisherEmail: w.publisherEmail,
                    toUserEmail: w.toUserEmail ?? null,
                    creationTime: w.creationTime != null ? String(w.creationTime) : '',
                    isRead: w.isRead === true,
                    publisherName: w.publisher?.username ?? w.publisherEmail ?? '',
                    userName: w.publisher?.username ?? w.publisherEmail ?? '',
                };
                return { ...baseData, item: whisperItem, ...whisperItem };
            }
            return null;
        }).filter((x: any) => x != null);

        return NextResponse.json(BizResult.success(formattedResult, `获取${type === 'task' ? '任务' : type === 'gift' ? '礼物' : '留言'}收藏列表成功`));

    } catch (error) {
        console.error('获取收藏列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取收藏列表失败'));
    }
}
