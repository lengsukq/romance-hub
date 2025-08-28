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
type UploadFunction = (fileData: any) => Promise<UploadResponse>;

export async function upImgMain(fileData: UploadFileData): Promise<UploadResponse> {
    const upImgObj: Record<string, UploadFunction> = {
        "SM": (fileData: any) => upImgBySM(fileData), // SM图床
        "IMGBB": (fileData: any) => upImgByImgBB(fileData), // IMGBB图床
    };
    const uploadBed = process.env.DRAWING_BED || "SM";
    if (!upImgObj[uploadBed]) {
        throw new Error(`不支持的图床类型: ${uploadBed}，请使用 SM 或 IMGBB`);
    }
    return await upImgObj[uploadBed](fileData);
}

// 上传图片到SM图床
export async function upImgBySM(fileData: UploadFileData): Promise<UploadResponse> {
    const { file } = fileData;
    const formData = new FormData();
    formData.append('smfile', file);
    formData.append('format', 'json');
    try {
        const response = await fetch('https://sm.ms/api/v2/upload', {
            method: 'POST',
            body: formData,
            headers: {
                "Authorization": process.env.SM_TOKEN || ""
            }
        });
        // return response.json();
        if (!response.ok) {
            console.log('response', response)

            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
        }

        const data = await response.json();
        console.log('sm', data);
        return {msg: '上传成功', url: data.data.url}; // 返回获取到的图片链接
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
    }
}

// 上传到imgBB图床
export async function upImgByImgBB(fileData: UploadFileData): Promise<UploadResponse> {
    const { file } = fileData;
    const formData = new FormData();
    formData.append('image', file);
    formData.append('key', process.env.IMGBB_API || '');
    try {
        const response = await fetch('https://api.imgbb.com/1/upload', {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) {
            console.log('response', response)

            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
        }

        const data = await response.json();
        console.log('sm', data);
        return {msg: '上传成功', url: data.data.url}; // 返回获取到的图片链接
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
    }
}

