import executeQuery from "@/utils/db";
import { DBResult } from "@/types";

// 积分操作结果接口
interface ScoreResult {
    score: number;
}

// 积分操作错误结果接口
interface ScoreErrorResult {
    error: string;
}

// 添加积分
export async function addScore(value: number, userEmail: string): Promise<DBResult[]> {
    try {
        await executeQuery({
            query: 'UPDATE userinfo SET score = score + ? WHERE userEmail = ?',
            values: [value, userEmail]
        });
        return await getScore(userEmail);
    } catch (e) {
        console.error('添加积分失败:', e);
        throw new Error(`添加积分失败: ${e}`);
    }
}

// 扣减积分
export async function subtractScore(value: number, userEmail: string): Promise<DBResult[] | ScoreErrorResult> {
    try {
        const scoreResult = await getScore(userEmail);
        const score = (scoreResult[0] as ScoreResult).score;
        
        if (score < value) {
            return { error: '积分不足，兑换失败' };
        }
        
        await executeQuery({
            query: 'UPDATE userinfo SET score = score - ? WHERE userEmail = ?',
            values: [value, userEmail]
        });

        return await getScore(userEmail);
    } catch (e) {
        console.error('扣减积分失败:', e);
        throw new Error(`扣减积分失败: ${e}`);
    }
}

// 获取积分余额
export async function getScore(userEmail: string): Promise<DBResult[]> {
    try {
        return await executeQuery({
            query: "SELECT score FROM userinfo WHERE userEmail = ?",
            values: [userEmail]
        });
    } catch (e) {
        console.error('获取积分失败:', e);
        throw new Error(`获取积分失败: ${e}`);
    }
}

// 获取任务详情
export async function getTaskDetail(taskId: string): Promise<DBResult[]> {
    try {
        return await executeQuery({
            query: `SELECT tasklist.*,favourite_list.* FROM tasklist LEFT JOIN favourite_list ON collectionId = taskId AND collectionType = 'task' WHERE taskId = ?`,
            values: [taskId]
        });
    } catch (e) {
        console.error('获取任务详情失败:', e);
        throw new Error(`获取任务详情失败: ${e}`);
    }
}

// 查询礼物分数
export async function getGiftScore(giftId: string): Promise<DBResult[]> {
    try {
        return await executeQuery({
            query: 'SELECT * FROM gift_list WHERE giftId = ?',
            values: [giftId]
        });
    } catch (e) {
        console.error('查询礼物分数失败:', e);
        throw new Error(`查询礼物分数失败: ${e}`);
    }
}

// 获取留言列表
export async function getWhisper(eMail: string, searchWords: string = ''): Promise<DBResult[]> {
    console.log('获取留言列表', eMail);
    try {
        return await executeQuery({
            query: `SELECT whisper_list.*,userinfo.userName,favourite_list.favId
                    FROM whisper_list LEFT JOIN userinfo ON whisper_list.publisherEmail = userinfo.userEmail 
                    LEFT JOIN favourite_list ON favourite_list.collectionId = whisper_list.whisperId AND collectionType = 'whisper'
                    WHERE publisherEmail = ? AND title LIKE ? ORDER BY whisperId DESC`,
            values: [eMail, `%${searchWords}%`]
        });
    } catch (e) {
        console.error('获取留言列表失败:', e);
        throw new Error(`获取留言列表失败: ${e}`);
    }
}
