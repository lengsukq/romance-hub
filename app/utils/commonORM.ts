import { UserService } from './ormService';

// 积分操作结果接口
interface ScoreResult {
    score: number;
}

// 积分操作错误结果接口
interface ScoreErrorResult {
    error: string;
}

// 添加积分
export async function addScore(value: number, userEmail: string): Promise<ScoreResult[]> {
    try {
        const result = await UserService.addScore(userEmail, value);
        return [result];
    } catch (e) {
        console.error('添加积分失败:', e);
        throw new Error(`添加积分失败: ${e}`);
    }
}

// 扣减积分
export async function subtractScore(value: number, userEmail: string): Promise<ScoreResult[] | ScoreErrorResult> {
    try {
        const result = await UserService.subtractScore(userEmail, value);
        
        if (typeof result === 'object' && 'error' in result) {
            return result;
        }
        
        return [result];
    } catch (e) {
        console.error('扣减积分失败:', e);
        throw new Error(`扣减积分失败: ${e}`);
    }
}

// 获取积分余额
export async function getScore(userEmail: string): Promise<ScoreResult[]> {
    try {
        const result = await UserService.getUserScore(userEmail);
        if (!result) {
            throw new Error('用户不存在');
        }
        return [result];
    } catch (e) {
        console.error('获取积分失败:', e);
        throw new Error(`获取积分失败: ${e}`);
    }
}

// 获取任务详情（包含收藏状态）
export async function getTaskDetail(taskId: string, userEmail?: string): Promise<any[]> {
    try {
        const { TaskService } = await import('./ormService');
        const task = await TaskService.getTaskDetail(taskId);
        
        if (!task) {
            return [];
        }

        let result: any = { ...task };
        
        // 如果提供了用户邮箱，检查收藏状态
        if (userEmail) {
            const favourite = await TaskService.checkTaskFavourite(taskId, userEmail);
            result = {
                ...result,
                favId: favourite?.favId || null,
                isFavorite: !!favourite
            };
        }

        return [result];
    } catch (e) {
        console.error('获取任务详情失败:', e);
        throw new Error(`获取任务详情失败: ${e}`);
    }
}

// 查询礼物分数
export async function getGiftScore(giftId: string): Promise<any[]> {
    try {
        const { GiftService } = await import('./ormService');
        const gift = await GiftService.getGiftDetail(giftId);
        
        if (!gift) {
            return [];
        }

        return [gift];
    } catch (e) {
        console.error('查询礼物分数失败:', e);
        throw new Error(`查询礼物分数失败: ${e}`);
    }
}

// 获取留言列表
export async function getWhisper(eMail: string, searchWords: string = ''): Promise<any[]> {
    console.log('获取留言列表', eMail);
    try {
        const { WhisperService } = await import('./ormService');
        const whispers = await WhisperService.getMyWhispers(eMail, searchWords);
        
        // 为每个留言添加收藏状态
        const result = [];
        for (const whisper of whispers) {
            const favourite = await WhisperService.checkWhisperFavourite(whisper.whisperId, eMail);
            result.push({
                ...whisper,
                userName: whisper.publisher.username,
                favId: favourite?.favId || null
            });
        }
        
        return result;
    } catch (e) {
        console.error('获取留言列表失败:', e);
        throw new Error(`获取留言列表失败: ${e}`);
    }
}
