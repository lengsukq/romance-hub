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

export async function upImgMain(fileData: UploadFileData, userEmail: string): Promise<UploadResponse> {
    try {
        // 从数据库获取默认图床配置
        const defaultBed = await ConfigService.getDefaultImageBed(userEmail);
        if (!defaultBed) {
            throw new Error('未找到可用的图床配置');
        }

        const upImgObj: Record<string, UploadFunction> = {
            "smms": (fileData: any, config: any) => upImgBySM(fileData, config),
            "imgbb": (fileData: any, config: any) => upImgByImgBB(fileData, config),
        };

        if (!upImgObj[defaultBed.bedType]) {
            throw new Error(`不支持的图床类型: ${defaultBed.bedType}`);
        }

        return await upImgObj[defaultBed.bedType](fileData, defaultBed);
    } catch (error) {
        console.error('图片上传失败:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'};
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
            console.log('response', response)
            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'}
        }

        const data = await response.json();
        console.log('sm', data);
        return {msg: '上传成功', url: data.data.url};
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'}
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
            console.log('response', response)
            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'}
        }

        const data = await response.json();
        console.log('imgbb', data);
        return {msg: '上传成功', url: data.data.url};
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'}
    }
}

