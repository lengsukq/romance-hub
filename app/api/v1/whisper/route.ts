'use server'
import BizResult from '@/utils/BizResult';
import executeQuery from "@/utils/db";
import { cookieTools } from "@/utils/cookieTools";
import { NextRequest, NextResponse } from 'next/server';
import { WhisperItem, PaginationParams, BaseResponse } from '@/types';
import dayjs from "dayjs";

// 请求体接口
interface WhisperRequest {
    action: 'mylist' | 'talist' | 'create' | 'delete';
    data?: any;
}

// 留言列表查询参数
interface WhisperListData extends PaginationParams {
    searchWords?: string;
}

// 创建留言数据
interface CreateWhisperData {
    content: string;
    toUser?: string;
}

// 删除留言参数
interface DeleteWhisperData {
    whisperId: string;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        const body: WhisperRequest = await req.json();
        const { action, data } = body;

        switch (action) {
            case 'mylist':
                return await handleGetMyWhisperList(req, data as WhisperListData);
            
            case 'talist':
                return await handleGetTAWhisperList(req, data as WhisperListData);
            
            case 'create':
                return await handleCreateWhisper(req, data as CreateWhisperData);
            
            case 'delete':
                return await handleDeleteWhisper(req, data as DeleteWhisperData);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('留言API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 获取我的留言列表
async function handleGetMyWhisperList(req: NextRequest, data: WhisperListData): Promise<NextResponse> {
    try {
        const { userEmail, lover } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { searchWords = '' } = data || {};

        const result = await executeQuery({
            query: `SELECT whisper_list.*, userinfo.username as publisherName, favourite_list.favId
                   FROM whisper_list 
                   LEFT JOIN userinfo ON whisper_list.publisherEmail = userinfo.userEmail 
                   LEFT JOIN favourite_list ON favourite_list.collectionId = whisper_list.whisperId 
                       AND collectionType = 'whisper' AND favourite_list.userEmail = ?
                   WHERE whisper_list.publisherEmail = ? AND title LIKE ? 
                   ORDER BY whisperId DESC`,
            values: [userEmail, userEmail, `%${searchWords}%`]
        });

        // 添加收藏状态
        result.forEach((item: any) => {
            item.isFavorite = !!item.favId;
            delete item.favId;
        });

        return NextResponse.json(BizResult.success(result, '获取我的留言列表成功'));

    } catch (error) {
        console.error('获取我的留言列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取我的留言列表失败'));
    }
}

// 获取TA的留言列表
async function handleGetTAWhisperList(req: NextRequest, data: WhisperListData): Promise<NextResponse> {
    try {
        const { userEmail, lover } = cookieTools(req);
        
        if (!userEmail || !lover) {
            return NextResponse.json(BizResult.fail('', '请先登录或设置关联用户'));
        }

        const { searchWords = '' } = data || {};

        const result = await executeQuery({
            query: `SELECT whisper_list.*, userinfo.username as publisherName, favourite_list.favId
                   FROM whisper_list 
                   LEFT JOIN userinfo ON whisper_list.publisherEmail = userinfo.userEmail 
                   LEFT JOIN favourite_list ON favourite_list.collectionId = whisper_list.whisperId 
                       AND collectionType = 'whisper' AND favourite_list.userEmail = ?
                   WHERE whisper_list.publisherEmail = ? AND title LIKE ? 
                   ORDER BY whisperId DESC`,
            values: [userEmail, lover, `%${searchWords}%`]
        });

        // 添加收藏状态
        result.forEach((item: any) => {
            item.isFavorite = !!item.favId;
            delete item.favId;
        });

        return NextResponse.json(BizResult.success(result, '获取TA的留言列表成功'));

    } catch (error) {
        console.error('获取TA的留言列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取TA的留言列表失败'));
    }
}

// 创建留言
async function handleCreateWhisper(req: NextRequest, data: CreateWhisperData): Promise<NextResponse> {
    try {
        const { userEmail, lover } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { content, toUser } = data;

        // 参数验证
        if (!content || content.trim().length === 0) {
            return NextResponse.json(BizResult.fail('', '留言内容不能为空'));
        }

        if (content.length > 200) {
            return NextResponse.json(BizResult.fail('', '留言内容不能超过200个字'));
        }

        const creationTime = dayjs().format('YYYY-MM-DD HH:mm:ss');
        const targetUser = toUser || lover;

        if (!targetUser) {
            return NextResponse.json(BizResult.fail('', '请指定留言对象'));
        }

        // 检查目标用户是否存在
        const userCheck = await executeQuery({
            query: 'SELECT userEmail FROM userinfo WHERE userEmail = ?',
            values: [targetUser]
        });

        if (userCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '目标用户不存在'));
        }

        const result = await executeQuery({
            query: `INSERT INTO whisper_list (publisherEmail, toUserEmail, title, content, creationTime) 
                   VALUES (?, ?, ?, ?, ?)`,
            values: [userEmail, targetUser, content.substring(0, 20), content, creationTime]
        });

        return NextResponse.json(BizResult.success({ whisperId: (result as any).insertId }, '发布留言成功'));

    } catch (error) {
        console.error('创建留言失败:', error);
        return NextResponse.json(BizResult.fail('', '发布留言失败'));
    }
}

// 删除留言
async function handleDeleteWhisper(req: NextRequest, data: DeleteWhisperData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { whisperId } = data;

        if (!whisperId) {
            return NextResponse.json(BizResult.fail('', '留言ID不能为空'));
        }

        // 检查留言是否存在且有权限删除
        const whisperCheck = await executeQuery({
            query: 'SELECT publisherEmail FROM whisper_list WHERE whisperId = ?',
            values: [whisperId]
        });

        if (whisperCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '留言不存在'));
        }

        if (whisperCheck[0].publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '只能删除自己的留言'));
        }

        await executeQuery({
            query: 'DELETE FROM whisper_list WHERE whisperId = ?',
            values: [whisperId]
        });

        return NextResponse.json(BizResult.success('', '删除留言成功'));

    } catch (error) {
        console.error('删除留言失败:', error);
        return NextResponse.json(BizResult.fail('', '删除留言失败'));
    }
}
