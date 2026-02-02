'use server'
import BizResult from '@/utils/BizResult';
import { NextRequest, NextResponse } from 'next/server';
import { upImgMain } from "@/utils/imageTools";
import { cookieTools } from '@/utils/cookieTools';

// 请求体接口
interface CommonRequest {
    action: 'upload' | 'health';
    data?: any;
}

// 上传文件数据
interface UploadData {
    file: File;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        // 对于文件上传，需要特殊处理
        const contentType = req.headers.get('content-type');
        
        if (contentType?.includes('multipart/form-data')) {
            return await handleFileUpload(req);
        } else {
            const body: CommonRequest = await req.json();
            const { action, data } = body;

            switch (action) {
                case 'health':
                    return await handleHealthCheck();
                
                default:
                    return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
            }
        }
    } catch (error) {
        console.error('通用API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 处理文件上传
async function handleFileUpload(req: NextRequest): Promise<NextResponse> {
    try {
        const formData = await req.formData();
        const file = formData.get('file') as File;

        if (!file) {
            return NextResponse.json(BizResult.fail('', '请选择要上传的文件'));
        }

        // 获取用户邮箱
        const { userEmail } = cookieTools(req);
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }

        const uploadData: UploadData = { file };

        const result = await upImgMain(uploadData, userEmail);

        if (result.url) {
            return NextResponse.json(BizResult.success({ url: result.url }, result.msg));
        } else {
            return NextResponse.json(BizResult.fail('', result.msg));
        }

    } catch (error) {
        console.error('文件上传失败:', error);
        const message = error instanceof Error ? error.message : '文件上传失败';
        return NextResponse.json(BizResult.fail('', message));
    }
}

// 健康检查
async function handleHealthCheck(): Promise<NextResponse> {
    try {
        return NextResponse.json(BizResult.success({
            status: 'healthy',
            timestamp: new Date().toISOString(),
            version: '1.0.0'
        }, 'API运行正常'));
    } catch (error) {
        console.error('健康检查失败:', error);
        return NextResponse.json(BizResult.fail('', '健康检查失败'));
    }
}

// 支持GET请求的健康检查
export async function GET(): Promise<NextResponse> {
    return handleHealthCheck();
}
