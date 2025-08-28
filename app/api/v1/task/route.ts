'use server'
import BizResult from '@/utils/BizResult';
import executeQuery from "@/utils/db";
import { cookieTools } from "@/utils/cookieTools";
import { NextRequest, NextResponse } from 'next/server';
import { TaskItem, PaginationParams, BaseResponse } from '@/types';
import dayjs from "dayjs";

// 请求体接口
interface TaskRequest {
    action: 'list' | 'detail' | 'create' | 'update' | 'delete';
    data?: any;
}

// 任务列表查询参数
interface TaskListData extends PaginationParams {
    taskStatus?: string;
    searchWords?: string;
}

// 创建任务数据
interface CreateTaskData {
    taskName: string;
    taskDesc: string;
    taskImage: string[];
    taskScore: number;
    receiverEmail?: string;
}

// 更新任务数据
interface UpdateTaskData {
    taskId: string;
    taskStatus?: number;
    taskName?: string;
    taskDesc?: string;
    taskImage?: string[];
    taskScore?: number;
}

// 任务详情参数
interface TaskDetailData {
    taskId: string;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        const body: TaskRequest = await req.json();
        const { action, data } = body;

        switch (action) {
            case 'list':
                return await handleGetTaskList(req, data as TaskListData);
            
            case 'detail':
                return await handleGetTaskDetail(req, data as TaskDetailData);
            
            case 'create':
                return await handleCreateTask(req, data as CreateTaskData);
            
            case 'update':
                return await handleUpdateTask(req, data as UpdateTaskData);
            
            case 'delete':
                return await handleDeleteTask(req, data as TaskDetailData);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('任务API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 获取任务列表
async function handleGetTaskList(req: NextRequest, data: TaskListData): Promise<NextResponse> {
    try {
        const { userEmail, lover } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const {
            taskStatus = null,
            searchWords = '',
            current = 1,
            pageSize = 10
        } = data || {};

        const offset = (current - 1) * pageSize;

        // 查询任务列表
        const result = await executeQuery({
            query: `SELECT * FROM tasklist WHERE
                   (publisherEmail = ? OR publisherEmail = ? OR receiverEmail = ?)
                   AND (taskStatus = ? OR ? IS NULL)
                   AND taskName LIKE ?
                   ORDER BY taskId DESC LIMIT ?, ?`,
            values: [userEmail, lover, userEmail, taskStatus, taskStatus, `%${searchWords}%`, offset, pageSize]
        });

        // 计算总条目数
        const totalCountResult = await executeQuery({
            query: `SELECT COUNT(*) AS totalCount FROM tasklist 
                   WHERE (publisherEmail = ? OR publisherEmail = ? OR receiverEmail = ?) 
                   AND (taskStatus = ? OR ? IS NULL)
                   AND taskName LIKE ?`,
            values: [userEmail, lover, userEmail, taskStatus, taskStatus, `%${searchWords}%`]
        });

        const totalCount = totalCountResult[0].totalCount;
        const totalPages = Math.ceil(totalCount / pageSize);

        // 处理任务图片数组
        result.forEach((item: any) => {
            if (item.taskImage) {
                item.taskImage = item.taskImage.split(',');
            }
            item.isApprove = item.isApprove !== 0;
        });

        return NextResponse.json(BizResult.success({
            record: result,
            total: totalCount,
            pageSize: pageSize,
            totalPages: totalPages,
            current: current
        }, '获取任务列表成功'));

    } catch (error) {
        console.error('获取任务列表失败:', error);
        return NextResponse.json(BizResult.fail('', '获取任务列表失败'));
    }
}

// 获取任务详情
async function handleGetTaskDetail(req: NextRequest, data: TaskDetailData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { taskId } = data;

        if (!taskId) {
            return NextResponse.json(BizResult.fail('', '任务ID不能为空'));
        }

        const result = await executeQuery({
            query: `SELECT tasklist.*, favourite_list.favId FROM tasklist 
                   LEFT JOIN favourite_list ON collectionId = taskId AND collectionType = 'task' AND favourite_list.userEmail = ?
                   WHERE taskId = ?`,
            values: [userEmail, taskId]
        });

        if (result.length > 0) {
            const task = result[0];
            if (task.taskImage) {
                task.taskImage = task.taskImage.split(',');
            }
            task.isApprove = task.isApprove !== 0;
            task.isFavorite = !!task.favId;

            return NextResponse.json(BizResult.success(task, '获取任务详情成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '任务不存在'));
        }

    } catch (error) {
        console.error('获取任务详情失败:', error);
        return NextResponse.json(BizResult.fail('', '获取任务详情失败'));
    }
}

// 创建任务
async function handleCreateTask(req: NextRequest, data: CreateTaskData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { taskName, taskDesc, taskImage, taskScore, receiverEmail } = data;

        // 参数验证
        if (!taskName || !taskDesc || !taskImage || taskImage.length === 0) {
            return NextResponse.json(BizResult.fail('', '请填写完整的任务信息'));
        }

        if (taskScore < 0) {
            return NextResponse.json(BizResult.fail('', '任务积分不能小于0'));
        }

        const creationTime = dayjs().format('YYYY-MM-DD HH:mm:ss');
        const taskImageStr = taskImage.join(',');

        const result = await executeQuery({
            query: `INSERT INTO tasklist (publisherEmail, taskName, taskDesc, taskImage, taskScore, receiverEmail, creationTime, taskStatus) 
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
            values: [userEmail, taskName, taskDesc, taskImageStr, taskScore, receiverEmail || null, creationTime, '未开始']
        });

        return NextResponse.json(BizResult.success({ taskId: (result as any).insertId }, '创建任务成功'));

    } catch (error) {
        console.error('创建任务失败:', error);
        return NextResponse.json(BizResult.fail('', '创建任务失败'));
    }
}

// 更新任务
async function handleUpdateTask(req: NextRequest, data: UpdateTaskData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { taskId, taskStatus, taskName, taskDesc, taskImage, taskScore } = data;

        if (!taskId) {
            return NextResponse.json(BizResult.fail('', '任务ID不能为空'));
        }

        // 检查任务是否存在且有权限修改
        const taskCheck = await executeQuery({
            query: 'SELECT publisherEmail, receiverEmail FROM tasklist WHERE taskId = ?',
            values: [taskId]
        });

        if (taskCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '任务不存在'));
        }

        const task = taskCheck[0];
        const hasPermission = task.publisherEmail === userEmail || task.receiverEmail === userEmail;

        if (!hasPermission) {
            return NextResponse.json(BizResult.fail('', '没有权限修改此任务'));
        }

        const updateFields: string[] = [];
        const updateValues: any[] = [];

        // 动态构建更新字段
        if (taskStatus !== undefined) {
            updateFields.push('taskStatus = ?');
            updateValues.push(taskStatus);
        }
        if (taskName) {
            updateFields.push('taskName = ?');
            updateValues.push(taskName);
        }
        if (taskDesc) {
            updateFields.push('taskDesc = ?');
            updateValues.push(taskDesc);
        }
        if (taskImage && taskImage.length > 0) {
            updateFields.push('taskImage = ?');
            updateValues.push(taskImage.join(','));
        }
        if (taskScore !== undefined) {
            updateFields.push('taskScore = ?');
            updateValues.push(taskScore);
        }

        if (updateFields.length === 0) {
            return NextResponse.json(BizResult.fail('', '没有要更新的字段'));
        }

        updateValues.push(taskId);

        await executeQuery({
            query: `UPDATE tasklist SET ${updateFields.join(', ')} WHERE taskId = ?`,
            values: updateValues
        });

        return NextResponse.json(BizResult.success('', '更新任务成功'));

    } catch (error) {
        console.error('更新任务失败:', error);
        return NextResponse.json(BizResult.fail('', '更新任务失败'));
    }
}

// 删除任务
async function handleDeleteTask(req: NextRequest, data: TaskDetailData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const { taskId } = data;

        if (!taskId) {
            return NextResponse.json(BizResult.fail('', '任务ID不能为空'));
        }

        // 检查任务是否存在且有权限删除
        const taskCheck = await executeQuery({
            query: 'SELECT publisherEmail FROM tasklist WHERE taskId = ?',
            values: [taskId]
        });

        if (taskCheck.length === 0) {
            return NextResponse.json(BizResult.fail('', '任务不存在'));
        }

        if (taskCheck[0].publisherEmail !== userEmail) {
            return NextResponse.json(BizResult.fail('', '只有任务发布者可以删除任务'));
        }

        await executeQuery({
            query: 'DELETE FROM tasklist WHERE taskId = ?',
            values: [taskId]
        });

        return NextResponse.json(BizResult.success('', '删除任务成功'));

    } catch (error) {
        console.error('删除任务失败:', error);
        return NextResponse.json(BizResult.fail('', '删除任务失败'));
    }
}
