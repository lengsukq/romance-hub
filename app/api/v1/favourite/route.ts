'use server'
import BizResult from '@/utils/BizResult';
import executeQuery from "@/utils/db";
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
        const existingFav = await executeQuery({
            query: 'SELECT favId FROM favourite_list WHERE userEmail = ? AND collectionId = ? AND collectionType = ?',
            values: [userEmail, collectionId, collectionType]
        });

        if (existingFav.length > 0) {
            return NextResponse.json(BizResult.fail('', '已经收藏过了'));
        }

        // 验证收藏对象是否存在
        let tableName = '';
        let idField = '';
        
        switch (collectionType) {
            case 'task':
                tableName = 'tasklist';
                idField = 'taskId';
                break;
            case 'gift':
                tableName = 'gift_list';
                idField = 'giftId';
                break;
            case 'whisper':
                tableName = 'whisper_list';
                idField = 'whisperId';
                break;
            default:
                return NextResponse.json(BizResult.fail('', '不支持的收藏类型'));
        }

        const itemCheck = await executeQuery({
            query: `SELECT ${idField} FROM ${tableName} WHERE ${idField} = ?`,
            values: [collectionId]
        });

        if (itemCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '收藏对象不存在'));
        }

        // 添加收藏
        const result = await executeQuery({
            query: 'INSERT INTO favourite_list (userEmail, collectionId, collectionType) VALUES (?, ?, ?)',
            values: [userEmail, collectionId, collectionType]
        });

        return NextResponse.json(BizResult.success({ favId: (result as any).insertId }, '收藏成功'));

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
        const existingFav = await executeQuery({
            query: 'SELECT favId FROM favourite_list WHERE userEmail = ? AND collectionId = ? AND collectionType = ?',
            values: [userEmail, collectionId, collectionType]
        });

        if (existingFav.length === 0) {
            return NextResponse.json(BizResult.fail('', '尚未收藏'));
        }

        // 移除收藏
        await executeQuery({
            query: 'DELETE FROM favourite_list WHERE userEmail = ? AND collectionId = ? AND collectionType = ?',
            values: [userEmail, collectionId, collectionType]
        });

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

        let query = '';
        let queryValues: any[] = [userEmail];

        switch (type) {
            case 'task':
                query = `SELECT f.favId, f.collectionId, f.collectionType, f.creationTime as favTime,
                               t.taskName, t.taskDesc, t.taskImage, t.taskScore, t.publisherEmail, t.taskStatus, t.creationTime,
                               u.username as publisherName
                        FROM favourite_list f 
                        LEFT JOIN tasklist t ON f.collectionId = t.taskId 
                        LEFT JOIN userinfo u ON t.publisherEmail = u.userEmail
                        WHERE f.userEmail = ? AND f.collectionType = 'task' AND t.taskName LIKE ?
                        ORDER BY f.favId DESC`;
                queryValues.push(`%${searchWords}%`);
                break;
                
            case 'gift':
                query = `SELECT f.favId, f.collectionId, f.collectionType, f.creationTime as favTime,
                               g.giftName, g.giftDetail, g.giftImg, g.needScore, g.remained, g.publisherEmail, g.isShow, g.creationTime,
                               u.username as publisherName
                        FROM favourite_list f 
                        LEFT JOIN gift_list g ON f.collectionId = g.giftId 
                        LEFT JOIN userinfo u ON g.publisherEmail = u.userEmail
                        WHERE f.userEmail = ? AND f.collectionType = 'gift' AND g.giftName LIKE ?
                        ORDER BY f.favId DESC`;
                queryValues.push(`%${searchWords}%`);
                break;
                
            case 'whisper':
                query = `SELECT f.favId, f.collectionId, f.collectionType, f.creationTime as favTime,
                               w.title, w.content, w.publisherEmail, w.toUserEmail, w.creationTime,
                               u.username as publisherName
                        FROM favourite_list f 
                        LEFT JOIN whisper_list w ON f.collectionId = w.whisperId 
                        LEFT JOIN userinfo u ON w.publisherEmail = u.userEmail
                        WHERE f.userEmail = ? AND f.collectionType = 'whisper' AND w.title LIKE ?
                        ORDER BY f.favId DESC`;
                queryValues.push(`%${searchWords}%`);
                break;
                
            default:
                return NextResponse.json(BizResult.fail('', '不支持的收藏类型'));
        }

        const result = await executeQuery({
            query: query,
            values: queryValues
        });

        // 处理任务图片数组
        if (type === 'task') {
            result.forEach((item: any) => {
                if (item.taskImage) {
                    item.taskImage = item.taskImage.split(',');
                }
                item.isApprove = item.isApprove !== 0;
            });
        }

        return NextResponse.json(BizResult.success(result, `获取${type === 'task' ? '任务' : type === 'gift' ? '礼物' : '留言'}收藏列表成功`));

    } catch (error) {
        console.error('获取收藏列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取收藏列表失败'));
    }
}
