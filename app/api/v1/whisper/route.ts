'use server'
import BizResult from '@/utils/BizResult';
import { WhisperService } from '@/utils/ormService';
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
    whisperId: number;
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

        const whispers = await WhisperService.getMyWhispers(userEmail, searchWords);

        // 添加收藏状态和格式化数据
        const result = [];
        for (const whisper of whispers) {
            const favourite = await WhisperService.checkWhisperFavourite(whisper.whisperId, userEmail);
            result.push({
                ...whisper,
                publisherName: whisper.publisher.username,
                userName: whisper.publisher.username,
                isFavorite: !!favourite,
                favId: favourite?.favId || null
            });
        }

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

        const whispers = await WhisperService.getTAWhispers(userEmail, lover, searchWords);

        // 添加收藏状态和格式化数据
        const result = [];
        for (const whisper of whispers) {
            const favourite = await WhisperService.checkWhisperFavourite(whisper.whisperId, userEmail);
            result.push({
                ...whisper,
                publisherName: whisper.publisher.username,
                userName: whisper.publisher.username,
                isFavorite: !!favourite,
                favId: favourite?.favId || null
            });
        }

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
        const userExists = await WhisperService.checkUserExists(targetUser);

        if (!userExists) {
            return NextResponse.json(BizResult.fail('', '目标用户不存在'));
        }

        const result = await WhisperService.createWhisper({
            publisherEmail: userEmail,
            toUserEmail: targetUser,
            title: content.substring(0, 20),
            content
        });

        return NextResponse.json(BizResult.success({ whisperId: result.whisperId }, '发布留言成功'));

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
        const whisper = await WhisperService.checkWhisperPermission(whisperId);

        if (!whisper) {
            return NextResponse.json(BizResult.fail('', '留言不存在'));
        }

        if (whisper.publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '只能删除自己的留言'));
        }

        await WhisperService.deleteWhisper(whisperId);

        return NextResponse.json(BizResult.success('', '删除留言成功'));

    } catch (error) {
        console.error('删除留言失败:', error);
        return NextResponse.json(BizResult.fail('', '删除留言失败'));
    }
}
