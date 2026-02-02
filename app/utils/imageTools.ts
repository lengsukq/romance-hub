import { ConfigService } from './configService';

// 上传文件数据接口
interface UploadFileData {
    file: File;
}

// 上传响应接口
interface UploadResponse {
    msg: string;
    url: string;
}

// 上传函数类型
type UploadFunction = (fileData: any, config: any) => Promise<UploadResponse>;

/** 从 .env 读取图床配置作为兜底（数据库无配置时使用） */
function getEnvImageBedConfig(): { bedType: string; apiUrl: string; apiKey: string } | null {
    const drawingBed = (process.env.DRAWING_BED || '').toUpperCase();
    if (drawingBed === 'IMGBB') {
        const apiKey = process.env.IMGBB_API?.trim();
        if (apiKey) {
            return { bedType: 'imgbb', apiUrl: 'https://api.imgbb.com/1/upload', apiKey };
        }
    }
    return null;
}

export async function upImgMain(fileData: UploadFileData, userEmail: string): Promise<UploadResponse> {
    try {
        // 优先从数据库获取默认图床配置（应用内图床设置，与关联者共用）
        let config = await ConfigService.getDefaultImageBed(userEmail);
        if (!config) {
            // 数据库无配置时，使用 .env 兜底（DRAWING_BED=IMGBB + IMGBB_API）
            const envConfig = getEnvImageBedConfig();
            if (envConfig) {
                config = envConfig as any;
            } else {
                throw new Error('未设置图床，请先在「设置」中配置图床（与良人共用），或在服务端 .env 中配置 DRAWING_BED 与 IMGBB_API 作为兜底');
            }
        }

        const effectiveConfig = config;
        if (!effectiveConfig) {
            throw new Error('未设置图床，请先在「设置」中配置图床');
        }

        const upImgObj: Record<string, UploadFunction> = {
            "smms": (fileData: any, config: any) => upImgBySM(fileData, config),
            "imgbb": (fileData: any, config: any) => upImgByImgBB(fileData, config),
        };

        const bedType = (effectiveConfig.bedType || '').toLowerCase();
        if (!upImgObj[bedType]) {
            throw new Error(`不支持的图床类型: ${effectiveConfig.bedType}`);
        }

        return await upImgObj[bedType](fileData, effectiveConfig);
    } catch (error) {
        console.error('图片上传失败:', error);
        const message = error instanceof Error ? error.message : '图床上传失败，请检查图床配置或网络';
        throw new Error(message);
    }
}

// 上传图片到SM图床
export async function upImgBySM(fileData: UploadFileData, config: any): Promise<UploadResponse> {
    const { file } = fileData;
    const formData = new FormData();
    formData.append('smfile', file);
    formData.append('format', 'json');
    
    const headers: Record<string, string> = {};
    if (config.authHeader && config.apiKey) {
        headers[config.authHeader] = config.apiKey;
    }
    
    try {
        const response = await fetch(config.apiUrl, {
            method: 'POST',
            body: formData,
            headers
        });
        
        if (!response.ok) {
            const text = await response.text();
            console.error('SM 图床上传失败', response.status, text);
            throw new Error('SM 图床上传失败，请检查图床配置或 API 额度');
        }

        const data = await response.json();
        const url = data?.data?.url;
        if (!url) {
            console.error('SM 返回数据异常', data);
            throw new Error('图床返回格式异常，未拿到图片地址');
        }
        return { msg: '上传成功', url };
    } catch (error) {
        if (error instanceof Error) throw error;
        console.error('There was a problem with the fetch operation:', error);
        throw new Error('图床上传失败，请检查网络或图床配置');
    }
}

// 上传到imgBB图床
export async function upImgByImgBB(fileData: UploadFileData, config: any): Promise<UploadResponse> {
    const { file } = fileData;
    const formData = new FormData();
    formData.append('image', file);
    if (config.apiKey) {
        formData.append('key', config.apiKey);
    }
    
    try {
        const response = await fetch(config.apiUrl, {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) {
            const text = await response.text();
            console.error('imgBB 图床上传失败', response.status, text);
            throw new Error('imgBB 图床上传失败，请检查图床配置或 API 额度');
        }

        const data = await response.json();
        const url = data?.data?.url;
        if (!url) {
            console.error('imgBB 返回数据异常', data);
            throw new Error('图床返回格式异常，未拿到图片地址');
        }
        return { msg: '上传成功', url };
    } catch (error) {
        if (error instanceof Error) throw error;
        console.error('There was a problem with the fetch operation:', error);
        throw new Error('图床上传失败，请检查网络或图床配置');
    }
}

