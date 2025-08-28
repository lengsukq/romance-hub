import jwt from 'jsonwebtoken';
import { CookieData } from '@/types';
import { NextRequest } from 'next/server';

const secretKey = process.env.JWT_SECRET_KEY as string;

export function cookieTools(request: NextRequest): CookieData {
    const cookieValue = request.cookies.get('cookie');
    
    if (cookieValue && cookieValue.value) {
        try {
            const cookie = JSON.parse(cookieValue.value);
            // 获取cookie基本信息
            // console.log('cookie基本信息', cookie)
            // 解密cookie的value
            console.log('解密cookie的value', decryptData(cookie.value));
            const decryptedData = decryptData(cookie.value);
            return decryptedData || { userEmail: '', userId: '', userName: '', lover: '' };
        } catch (error) {
            console.error('解析cookie失败：', error);
            return { userEmail: '', userId: '', userName: '', lover: '' };
        }
    } else {
        return { userEmail: '', userId: '', userName: '', lover: '' };
    }
}

// 加密函数
export function encryptData(data: CookieData): string {
    return jwt.sign(data, secretKey);
}

// 解密函数
export function decryptData(cookie: string): CookieData | null {
    try {
        return jwt.verify(cookie, secretKey) as CookieData;
    } catch (err) {
        console.error('解密失败：', err);
        return null;
    }
}
