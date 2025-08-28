'use server'
import BizResult from '@/utils/BizResult';
import executeQuery from "@/utils/db";
import { cookieTools } from "@/utils/cookieTools";
import { NextRequest, NextResponse } from 'next/server';
import { GiftItem, PaginationParams, BaseResponse } from '@/types';
import { randomImages } from "@/utils/third-party-tools";
import { addScore, subtractScore } from "@/utils/commonSQL";

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

        const result = await executeQuery({
            query: `SELECT g.*, u.username as publisherName 
                   FROM gift_list g 
                   LEFT JOIN userinfo u ON g.publisherEmail = u.userEmail 
                   WHERE g.isShow = 1 AND g.remained > 0 AND g.giftName LIKE ?
                   ORDER BY g.giftId DESC`,
            values: [`%${searchWords}%`]
        });

        return NextResponse.json(BizResult.success(result, '获取礼物列表成功'));

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

        let whereCondition = 'publisherEmail = ? AND giftName LIKE ?';
        let queryValues: any[] = [userEmail, `%${searchWords}%`];

        // 根据类型筛选
        switch (type) {
            case '已上架':
                whereCondition += ' AND isShow = 1';
                break;
            case '已下架':
                whereCondition += ' AND isShow = 0';
                break;
            case '待使用':
                whereCondition += ' AND remained > 0';
                break;
            case '已用完':
                whereCondition += ' AND remained = 0';
                break;
        }

        const result = await executeQuery({
            query: `SELECT * FROM gift_list WHERE ${whereCondition} ORDER BY giftId DESC`,
            values: queryValues
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

        const result = await executeQuery({
            query: `SELECT g.*, u.username as publisherName 
                   FROM gift_list g 
                   LEFT JOIN userinfo u ON g.publisherEmail = u.userEmail 
                   WHERE g.giftId = ?`,
            values: [giftId]
        });

        if (result.length > 0) {
            return NextResponse.json(BizResult.success(result[0], '获取礼物详情成功'));
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
        const isShowValue = isShow ? 1 : 0;

        const result = await executeQuery({
            query: `INSERT INTO gift_list (publisherEmail, giftImg, giftName, giftDetail, needScore, remained, isShow) 
                   VALUES (?, ?, ?, ?, ?, ?, ?)`,
            values: [userEmail, finalGiftImg, giftName, giftDetail, needScore, remained, isShowValue]
        });

        return NextResponse.json(BizResult.success({ giftId: (result as any).insertId }, '创建礼物成功'));

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
        const giftCheck = await executeQuery({
            query: 'SELECT publisherEmail FROM gift_list WHERE giftId = ?',
            values: [giftId]
        });

        if (giftCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '礼物不存在'));
        }

        if (giftCheck[0].publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '没有权限修改此礼物'));
        }

        const updateFields: string[] = [];
        const updateValues: any[] = [];

        // 动态构建更新字段
        if (giftName) {
            if (giftName.length > 10) {
                return NextResponse.json(BizResult.fail('', '礼物名称不能超过10个字'));
            }
            updateFields.push('giftName = ?');
            updateValues.push(giftName);
        }
        if (giftDetail) {
            if (giftDetail.length > 20) {
                return NextResponse.json(BizResult.fail('', '礼物描述不能超过20个字'));
            }
            updateFields.push('giftDetail = ?');
            updateValues.push(giftDetail);
        }
        if (needScore !== undefined) {
            if (needScore < 0) {
                return NextResponse.json(BizResult.fail('', '所需积分不能小于0'));
            }
            updateFields.push('needScore = ?');
            updateValues.push(needScore);
        }
        if (remained !== undefined) {
            if (remained < 0) {
                return NextResponse.json(BizResult.fail('', '库存不能小于0'));
            }
            updateFields.push('remained = ?');
            updateValues.push(remained);
        }
        if (giftImg) {
            updateFields.push('giftImg = ?');
            updateValues.push(giftImg);
        }
        if (isShow !== undefined) {
            updateFields.push('isShow = ?');
            updateValues.push(isShow ? 1 : 0);
        }

        if (updateFields.length === 0) {
            return NextResponse.json(BizResult.fail('', '没有要更新的字段'));
        }

        updateValues.push(giftId);

        await executeQuery({
            query: `UPDATE gift_list SET ${updateFields.join(', ')} WHERE giftId = ?`,
            values: updateValues
        });

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
        const giftInfo = await executeQuery({
            query: 'SELECT * FROM gift_list WHERE giftId = ? AND isShow = 1',
            values: [giftId]
        });

        if (giftInfo.length === 0) {
            return NextResponse.json(BizResult.fail('', '礼物不存在或已下架'));
        }

        const gift = giftInfo[0];

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
        await executeQuery({
            query: 'UPDATE gift_list SET remained = remained - 1 WHERE giftId = ?',
            values: [giftId]
        });

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
        const giftCheck = await executeQuery({
            query: 'SELECT * FROM gift_list WHERE giftId = ? AND publisherEmail = ?',
            values: [giftId, userEmail]
        });

        if (giftCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '礼物不存在或不属于您'));
        }

        const gift = giftCheck[0];

        if (gift.remained <= 0) {
            return NextResponse.json(BizResult.fail('', '礼物已用完'));
        }

        // 使用礼物（减少库存）
        await executeQuery({
            query: 'UPDATE gift_list SET remained = remained - 1 WHERE giftId = ?',
            values: [giftId]
        });

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
        const giftCheck = await executeQuery({
            query: 'SELECT publisherEmail FROM gift_list WHERE giftId = ?',
            values: [giftId]
        });

        if (giftCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '礼物不存在'));
        }

        if (giftCheck[0].publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '没有权限操作此礼物'));
        }

        await executeQuery({
            query: 'UPDATE gift_list SET isShow = ? WHERE giftId = ?',
            values: [isShow ? 1 : 0, giftId]
        });

        return NextResponse.json(BizResult.success('', isShow ? '上架成功' : '下架成功'));

    } catch (error) {
        console.error('操作礼物失败:', error);
        return NextResponse.json(BizResult.fail('', '操作失败'));
    }
}
