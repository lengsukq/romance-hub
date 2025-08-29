'use server'
import BizResult from '@/utils/BizResult';
import { GiftService } from '@/utils/ormService';
import { cookieTools } from "@/utils/cookieTools";
import { NextRequest, NextResponse } from 'next/server';
import { GiftItem, PaginationParams, BaseResponse } from '@/types';
import { randomImages } from "@/utils/third-party-tools";
import { addScore, subtractScore } from "@/utils/commonORM";

// 请求体接口
interface GiftRequest {
    action: 'list' | 'mylist' | 'detail' | 'create' | 'update' | 'exchange' | 'use' | 'show';
    data?: any;
}

// 礼物列表查询参数
interface GiftListData extends PaginationParams {
    searchWords?: string;
    type?: string;
}

// 创建礼物数据
interface CreateGiftData {
    giftName: string;
    giftDetail: string;
    needScore: number;
    remained: number;
    giftImg?: string;
    isShow?: boolean;
}

// 更新礼物数据
interface UpdateGiftData {
    giftId: string;
    giftName?: string;
    giftDetail?: string;
    needScore?: number;
    remained?: number;
    giftImg?: string;
    isShow?: boolean;
}

// 礼物操作参数
interface GiftOperationData {
    giftId: string;
}

// 礼物显示/隐藏参数
interface GiftShowData {
    giftId: string;
    isShow: boolean;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        // 运行时检查，避免构建时执行
        if (typeof window !== 'undefined' || process.env.NODE_ENV === 'test') {
            return NextResponse.json(BizResult.fail('', '构建环境下不可执行'));
        }

        const body: GiftRequest = await req.json();
        const { action, data } = body;

        switch (action) {
            case 'list':
                return await handleGetGiftList(req, data as GiftListData);
            
            case 'mylist':
                return await handleGetMyGiftList(req, data as GiftListData);
            
            case 'detail':
                return await handleGetGiftDetail(req, data as GiftOperationData);
            
            case 'create':
                return await handleCreateGift(req, data as CreateGiftData);
            
            case 'update':
                return await handleUpdateGift(req, data as UpdateGiftData);
            
            case 'exchange':
                return await handleExchangeGift(req, data as GiftOperationData);
            
            case 'use':
                return await handleUseGift(req, data as GiftOperationData);
            
            case 'show':
                return await handleShowGift(req, data as GiftShowData);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('礼物API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 获取礼物列表（可兑换的礼物）
async function handleGetGiftList(req: NextRequest, data: GiftListData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { searchWords = '' } = data || {};

        const result = await GiftService.getAvailableGifts(searchWords);

        // 转换数据格式以匹配原有的返回结构
        const transformedResult = result.map(gift => ({
            ...gift,
            publisherName: gift.publisher.username
        }));

        return NextResponse.json(BizResult.success(transformedResult, '获取礼物列表成功'));

    } catch (error) {
        console.error('获取礼物列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取礼物列表失败'));
    }
}

// 获取我的礼物列表
async function handleGetMyGiftList(req: NextRequest, data: GiftListData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { searchWords = '', type = '' } = data || {};

        const result = await GiftService.getMyGifts({
            userEmail,
            searchWords,
            type
        });

        return NextResponse.json(BizResult.success(result, '获取我的礼物列表成功'));

    } catch (error) {
        console.error('获取我的礼物列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取我的礼物列表失败'));
    }
}

// 获取礼物详情
async function handleGetGiftDetail(req: NextRequest, data: GiftOperationData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftId } = data;

        if (!giftId) {
            return NextResponse.json(BizResult.fail('', '礼物ID不能为空'));
        }

        const result = await GiftService.getGiftDetail(giftId);

        if (result) {
            const transformedResult = {
                ...result,
                publisherName: result.publisher.username
            };
            return NextResponse.json(BizResult.success(transformedResult, '获取礼物详情成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '礼物不存在'));
        }

    } catch (error) {
        console.error('获取礼物详情失败:', error);
        return NextResponse.json(BizResult.fail('', '获取礼物详情失败'));
    }
}

// 创建礼物
async function handleCreateGift(req: NextRequest, data: CreateGiftData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftName, giftDetail, needScore, remained, giftImg, isShow = true } = data;

        // 参数验证
        if (!giftName || !giftDetail) {
            return NextResponse.json(BizResult.fail('', '请填写完整的礼物信息'));
        }

        if (giftName.length > 10) {
            return NextResponse.json(BizResult.fail('', '礼物名称不能超过10个字'));
        }

        if (giftDetail.length > 20) {
            return NextResponse.json(BizResult.fail('', '礼物描述不能超过20个字'));
        }

        if (needScore < 0) {
            return NextResponse.json(BizResult.fail('', '所需积分不能小于0'));
        }

        if (remained <= 0) {
            return NextResponse.json(BizResult.fail('', '库存必须大于0'));
        }

        const finalGiftImg = giftImg || await randomImages();

        const result = await GiftService.createGift({
            publisherEmail: userEmail,
            giftImg: finalGiftImg,
            giftName,
            giftDetail,
            needScore,
            remained,
            isShow
        });

        return NextResponse.json(BizResult.success({ giftId: result.giftId }, '创建礼物成功'));

    } catch (error) {
        console.error('创建礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '创建礼物失败'));
    }
}

// 更新礼物
async function handleUpdateGift(req: NextRequest, data: UpdateGiftData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftId, giftName, giftDetail, needScore, remained, giftImg, isShow } = data;

        if (!giftId) {
            return NextResponse.json(BizResult.fail('', '礼物ID不能为空'));
        }

        // 检查礼物是否存在且有权限修改
        const giftCheck = await GiftService.checkGiftPermission(giftId);

        if (!giftCheck) {
            return NextResponse.json(BizResult.fail('', '礼物不存在'));
        }

        if (giftCheck.publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '没有权限修改此礼物'));
        }

        const updateData: {
            giftName?: string;
            giftDetail?: string;
            needScore?: number;
            remained?: number;
            giftImg?: string;
            isShow?: boolean;
        } = {};

        // 动态构建更新字段
        if (giftName) {
            if (giftName.length > 10) {
                return NextResponse.json(BizResult.fail('', '礼物名称不能超过10个字'));
            }
            updateData.giftName = giftName;
        }
        if (giftDetail) {
            if (giftDetail.length > 20) {
                return NextResponse.json(BizResult.fail('', '礼物描述不能超过20个字'));
            }
            updateData.giftDetail = giftDetail;
        }
        if (needScore !== undefined) {
            if (needScore < 0) {
                return NextResponse.json(BizResult.fail('', '所需积分不能小于0'));
            }
            updateData.needScore = needScore;
        }
        if (remained !== undefined) {
            if (remained < 0) {
                return NextResponse.json(BizResult.fail('', '库存不能小于0'));
            }
            updateData.remained = remained;
        }
        if (giftImg) {
            updateData.giftImg = giftImg;
        }
        if (isShow !== undefined) {
            updateData.isShow = isShow;
        }

        if (Object.keys(updateData).length === 0) {
            return NextResponse.json(BizResult.fail('', '没有要更新的字段'));
        }

        await GiftService.updateGift(giftId, updateData);

        return NextResponse.json(BizResult.success('', '更新礼物成功'));

    } catch (error) {
        console.error('更新礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '更新礼物失败'));
    }
}

// 兑换礼物
async function handleExchangeGift(req: NextRequest, data: GiftOperationData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftId } = data;

        if (!giftId) {
            return NextResponse.json(BizResult.fail('', '礼物ID不能为空'));
        }

        // 获取礼物信息
        const gift = await GiftService.getGiftForExchange(giftId);

        if (!gift) {
            return NextResponse.json(BizResult.fail('', '礼物不存在或已下架'));
        }

        if (gift.remained <= 0) {
            return NextResponse.json(BizResult.fail('', '礼物库存不足'));
        }

        if (gift.publisherEmail === userEmail) {
            return NextResponse.json(BizResult.fail('', '不能兑换自己发布的礼物'));
        }

        // 扣减积分
        const scoreResult = await subtractScore(gift.needScore, userEmail);
        
        if (typeof scoreResult === 'object' && 'error' in scoreResult) {
            return NextResponse.json(BizResult.fail('', scoreResult.error));
        }

        // 减少礼物库存
        await GiftService.decrementGiftStock(giftId);

        // 记录兑换记录（如果有兑换记录表的话）
        // 这里可以添加兑换记录的逻辑

        return NextResponse.json(BizResult.success('', '兑换成功'));

    } catch (error) {
        console.error('兑换礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '兑换失败'));
    }
}

// 使用礼物
async function handleUseGift(req: NextRequest, data: GiftOperationData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftId } = data;

        if (!giftId) {
            return NextResponse.json(BizResult.fail('', '礼物ID不能为空'));
        }

        // 检查礼物是否存在且属于当前用户
        const gift = await GiftService.getGiftDetail(giftId);

        if (!gift || gift.publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '礼物不存在或不属于您'));
        }

        if (gift.remained <= 0) {
            return NextResponse.json(BizResult.fail('', '礼物已用完'));
        }

        // 使用礼物（减少库存）
        await GiftService.decrementGiftStock(giftId);

        return NextResponse.json(BizResult.success('', '使用成功'));

    } catch (error) {
        console.error('使用礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '使用礼物失败'));
    }
}

// 上架/下架礼物
async function handleShowGift(req: NextRequest, data: GiftShowData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { giftId, isShow } = data;

        if (!giftId) {
            return NextResponse.json(BizResult.fail('', '礼物ID不能为空'));
        }

        // 检查礼物是否存在且属于当前用户
        const giftCheck = await GiftService.checkGiftPermission(giftId);

        if (!giftCheck) {
            return NextResponse.json(BizResult.fail('', '礼物不存在'));
        }

        if (giftCheck.publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '没有权限操作此礼物'));
        }

        await GiftService.toggleGiftShow(giftId, isShow);

        return NextResponse.json(BizResult.success('', isShow ? '上架成功' : '下架成功'));

    } catch (error) {
        console.error('操作礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '操作失败'));
    }
}
