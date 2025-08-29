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
    collectionId: string;
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
        const existingFav = await FavouriteService.checkFavouriteExists(userEmail, collectionId, collectionType);

        if (existingFav) {
            return NextResponse.json(BizResult.fail('', '已经收藏过了'));
        }

        // 验证收藏对象是否存在
        const itemExists = await FavouriteService.validateCollectionItem(collectionId, collectionType);

        if (!itemExists) {
            return NextResponse.json(BizResult.fail('', '收藏对象不存在'));
        }

        // 添加收藏
        const result = await FavouriteService.addFavourite({
            userEmail,
            collectionId,
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
        const existingFav = await FavouriteService.checkFavouriteExists(userEmail, collectionId, collectionType);

        if (!existingFav) {
            return NextResponse.json(BizResult.fail('', '尚未收藏'));
        }

        // 移除收藏
        await FavouriteService.removeFavourite(userEmail, collectionId, collectionType);

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

        // 格式化返回数据
        const formattedResult = result.map((item: any) => {
            const baseData = {
                favId: item.favId,
                collectionId: item.collectionId,
                collectionType: item.collectionType,
                favTime: item.creationTime
            };

            if (type === 'task' && item.task) {
                return {
                    ...baseData,
                    ...item.task,
                    publisherName: item.task.publisher?.username
                };
            } else if (type === 'gift' && item.gift) {
                return {
                    ...baseData,
                    ...item.gift,
                    publisherName: item.gift.publisher?.username
                };
            } else if (type === 'whisper' && item.whisper) {
                return {
                    ...baseData,
                    ...item.whisper,
                    publisherName: item.whisper.publisher?.username
                };
            }
            return baseData;
        }).filter(item => item);

        // 处理任务图片数组
        if (type === 'task') {
            formattedResult.forEach((item: any) => {
                if (item.taskImage) {
                    item.taskImage = item.taskImage.split(',');
                }
                item.isApprove = item.isApprove;
            });
        }

        return NextResponse.json(BizResult.success(formattedResult, `获取${type === 'task' ? '任务' : type === 'gift' ? '礼物' : '留言'}收藏列表成功`));

    } catch (error) {
        console.error('获取收藏列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取收藏列表失败'));
    }
}
