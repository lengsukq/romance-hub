// 上传图片
import React from "react";
import { uploadImages } from "@/utils/client/apihttp";
import { BaseResponse } from "@/types";

// 上传响应数据接口
interface UploadResponseData {
    url: string;
}

// 图片上传函数
export async function imgUpload(event: Event | React.ChangeEvent<HTMLInputElement>): Promise<string> {
    const target = event.target as HTMLInputElement;
    const file = target.files?.[0];
    
    if (!file) {
        throw new Error('未选择文件');
    }
    
    try {
        const formData = new FormData();
        formData.append('file', file);
        formData.append('base64', '');
        
        const res: BaseResponse<UploadResponseData> = await uploadImages(formData);
        console.log('uploadImages', res);

        if (res.code === 200 && res.data) {
            return res.data.url;
        } else {
            throw new Error("图片上传失败: " + res.msg);
        }
    } catch (error) {
        console.error('图片上传失败:', error);
        throw new Error(`图片上传失败: ${error}`);
    }
}
