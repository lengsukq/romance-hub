// 上传文件数据接口
interface UploadFileData {
    file?: File;
    base64?: string;
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
        "SM": (fileData: any) => upImgBySM(fileData), // sm图床
        "BilibiliDaily": (fileData: any) => upImgByBilibiliDaily(fileData), // 哔哩哔哩动态/专栏
        "BilibiliCover": (fileData: any) => upImgByBilibiliCover(fileData), // 哔哩哔哩视频封面
        "IMGBB": (fileData: any) => upImgByImgBB(fileData), // IMGBB 图床
        "TG": (fileData: any) => upImgByTG(fileData), // TG图床
    };
    const uploadBed = process.env.DRAWING_BED || "TG";
    return await upImgObj[uploadBed](fileData);
}

// 上传图片到SM图床
export async function upImgBySM({file}: {file: File}): Promise<UploadResponse> {
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

// 上传图片到哔哩哔哩动态/专栏
export async function upImgByBilibiliDaily({file}: {file: File}): Promise<UploadResponse> {
    console.log('upImgByBilibiliDaily')
    const formData = new FormData();
    formData.append('file_up', file);
    // 使用专栏图片上传
    formData.append('biz', 'article');
    // 使用动态图片上传，改版过之后只有45分钟有效期
    // formData.append('biz', 'new_dyn');
    // formData.append('category', 'daily');
            formData.append('csrf', process.env.BILIBILI_CSRF || '');

    try {
        const response = await fetch('https://api.bilibili.com/x/dynamic/feed/draw/upload_bfs', {
            method: 'POST',
            body: formData,
            headers: {
                "cookie": `SESSDATA=${process.env.BILIBILI_SESSDATA}`
            }
        });
        // return response.json();
        if (!response.ok) {
            console.log('response', response)
            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
        }

        const data = await response.json();
        console.log('bilibili动态图片', data);
        return {msg: '上传成功', url: data.data.image_url}; // 返回获取到的图片链接
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接

    }
}

// 上传图片到哔哩哔哩视频封面，目前图片过大时会请求报错，需要使用json获取客户端的数据，然后在使用form请求b站接口
export async function upImgByBilibiliCover({base64}: {base64: string}): Promise<UploadResponse> {
    try {
        const formData = new FormData();
        formData.append('cover', base64);
        formData.append('csrf', process.env.BILIBILI_CSRF || '');
        // console.log('formData',formData)
        const response = await fetch('https://member.bilibili.com/x/vu/web/cover/up', {
            method: 'POST',
            body: formData,
            headers: {
                "cookie": `SESSDATA=${process.env.BILIBILI_SESSDATA}`
            }
        });
        // return response.json();
        if (!response.ok) {
            console.log('response', response)
            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
        }

        const data = await response.json();
        console.log('bilibili封面图片', data);
        return {msg: '上传成功', url: data.data.url}; // 返回获取到的图片链接
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接

    }
}

// 上传到imgBB图床
export async function upImgByImgBB({file}: {file: File}): Promise<UploadResponse> {
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

// 传入file，上传到TG_URL
export async function upImgByTG({file}: {file: File}): Promise<UploadResponse> {
    const formData = new FormData();
    formData.append('file', file);
    try {
        const  TG_URL = process.env.TG_URL || 'https://telegra.ph';
        const response = await fetch(`${TG_URL}/upload`, {
            method: 'POST',
            body: formData,
        });
        if (!response.ok) {
            console.log('response', response)
            return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
        }
        const data = await response.json();
        console.log('TG', data);
        return {msg: '上传成功', url: `${TG_URL}${data[0].src}`}; // 返回获取到的图片链接
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return {msg: '上传失败，使用默认图片', url: 'https://s2.loli.net/2024/01/08/ek3fUIuh6gPR47G.jpg'} // 返回默认图片链接
    }
}