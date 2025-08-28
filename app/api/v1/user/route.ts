'use server'
import BizResult from '@/utils/BizResult';
import executeQuery from "@/utils/db";
import { cookies } from 'next/headers';
import { cookieTools, encryptData } from "@/utils/cookieTools";
import dayjs from "dayjs";
import { randomImages } from "@/utils/third-party-tools";
import { NextRequest, NextResponse } from 'next/server';
import { UserInfo, LoginParams, RegisterParams, BaseResponse } from '@/types';

// 请求体接口
interface UserRequest {
    action: 'login' | 'register' | 'logout' | 'info' | 'update' | 'score';
    data?: any;
}

// 登录数据接口
interface LoginData {
    username: string;
    password: string;
}

// 注册数据接口
interface RegisterData extends RegisterParams {}

// 更新用户信息数据接口
interface UpdateUserData {
    username?: string;
    userEmail?: string;
    lover?: string;
    avatar?: string;
    describeBySelf?: string;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        const body: UserRequest = await req.json();
        const { action, data } = body;

        switch (action) {
            case 'login':
                return await handleLogin(data as LoginData);
            
            case 'register':
                return await handleRegister(data as RegisterData);
            
            case 'logout':
                return await handleLogout(req);
            
            case 'info':
                return await handleGetUserInfo(req);
            
            case 'update':
                return await handleUpdateUserInfo(req, data as UpdateUserData);
            
            case 'score':
                return await handleGetScore(req);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('用户API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 处理登录
async function handleLogin(data: LoginData): Promise<NextResponse> {
    const { username, password } = data;
    
    if (!username || !password) {
        return NextResponse.json(BizResult.fail('', '用户名或密码不能为空'));
    }

    try {
        const result = await executeQuery({
            query: 'SELECT userId, userEmail, lover, score FROM userinfo WHERE username = ? AND password = ?',
            values: [username, password]
        });

        if (result.length > 0) {
            const { userId, userEmail, lover, score } = result[0] as UserInfo;
            const oneDay = 60 * 1000 * 60 * 24 * 365;
            const cookie = encryptData({
                userEmail: userEmail, 
                userId: userId, 
                userName: username, 
                lover: lover
            });
            
            cookies().set({
                name: userEmail,
                value: cookie,
                httpOnly: false,
                path: '/',
                expires: Date.now() + oneDay
            });
            
            return NextResponse.json(BizResult.success(result[0], '登录成功'), {
                status: 200,
                headers: {'Set-Cookie': `cookie=${JSON.stringify(cookies().get(userEmail))}`},
            });
        } else {
            return NextResponse.json(BizResult.fail('', '用户名或密码错误'));
        }
    } catch (error) {
        console.error('登录失败:', error);
        return NextResponse.json(BizResult.fail('', '登录失败'));
    }
}

// 处理注册
async function handleRegister(data: RegisterData): Promise<NextResponse> {
    const { userEmail, username, password, describeBySelf, lover, avatar: imgURL } = data;
    
    if (!userEmail || !username || !password || !describeBySelf || !lover) {
        return NextResponse.json(BizResult.fail('', '请检查注册信息是否填写正确'));
    }
    
    if (userEmail === lover) {
        return NextResponse.json(BizResult.fail('', '用户邮箱与关联者邮箱不可相同'));
    }
    
    try {
        // 检查用户是否已存在
        const existingUser = await executeQuery({
            query: 'SELECT userId FROM userinfo WHERE userEmail = ? OR username = ?',
            values: [userEmail, username]
        });
        
        if (existingUser.length > 0) {
            return NextResponse.json(BizResult.fail('', '用户已存在'));
        }
        
        const creationTime = dayjs().format('YYYY-MM-DD HH:mm:ss');
        const avatar = imgURL ? imgURL : await randomImages();
        
        await executeQuery({
            query: 'INSERT INTO userinfo (userEmail, username, password, avatar, describeBySelf, registrationTime, lover) VALUES (?, ?, ?, ?, ?, ?, ?)',
            values: [userEmail, username, password, avatar, describeBySelf, creationTime, lover]
        });

        return NextResponse.json(BizResult.success('', '注册成功'));
    } catch (error) {
        console.error('注册失败:', error);
        return NextResponse.json(BizResult.fail('', '注册失败'));
    }
}

// 处理退出登录
async function handleLogout(req: NextRequest): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (userEmail) {
            // 清除cookie
            cookies().delete(userEmail);
        }
        
        return NextResponse.json(BizResult.success('', '退出成功'));
    } catch (error) {
        console.error('退出失败:', error);
        return NextResponse.json(BizResult.fail('', '退出失败'));
    }
}

// 获取用户信息
async function handleGetUserInfo(req: NextRequest): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }
        
        const result = await executeQuery({
            query: 'SELECT userId, userEmail, username, avatar, describeBySelf, lover, score, registrationTime FROM userinfo WHERE userEmail = ?',
            values: [userEmail]
        });
        
        if (result.length > 0) {
            return NextResponse.json(BizResult.success(result[0], '获取用户信息成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '用户不存在'));
        }
    } catch (error) {
        console.error('获取用户信息失败:', error);
        return NextResponse.json(BizResult.fail('', '获取用户信息失败'));
    }
}

// 更新用户信息
async function handleUpdateUserInfo(req: NextRequest, data: UpdateUserData): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }
        
        const updateFields: string[] = [];
        const updateValues: any[] = [];
        
        // 动态构建更新字段
        if (data.username) {
            updateFields.push('username = ?');
            updateValues.push(data.username);
        }
        if (data.lover) {
            updateFields.push('lover = ?');
            updateValues.push(data.lover);
        }
        if (data.avatar) {
            updateFields.push('avatar = ?');
            updateValues.push(data.avatar);
        }
        if (data.describeBySelf) {
            updateFields.push('describeBySelf = ?');
            updateValues.push(data.describeBySelf);
        }
        
        if (updateFields.length === 0) {
            return NextResponse.json(BizResult.fail('', '没有要更新的字段'));
        }
        
        updateValues.push(userEmail);
        
        await executeQuery({
            query: `UPDATE userinfo SET ${updateFields.join(', ')} WHERE userEmail = ?`,
            values: updateValues
        });
        
        return NextResponse.json(BizResult.success('', '更新成功'));
    } catch (error) {
        console.error('更新用户信息失败:', error);
        return NextResponse.json(BizResult.fail('', '更新失败'));
    }
}

// 获取积分
async function handleGetScore(req: NextRequest): Promise<NextResponse> {
    try {
        const { userEmail } = cookieTools(req);
        
        if (!userEmail) {
            return NextResponse.json(BizResult.fail('', '请先登录'));
        }
        
        const result = await executeQuery({
            query: 'SELECT score FROM userinfo WHERE userEmail = ?',
            values: [userEmail]
        });
        
        if (result.length > 0) {
            return NextResponse.json(BizResult.success(result[0], '获取积分成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '用户不存在'));
        }
    } catch (error) {
        console.error('获取积分失败:', error);
        return NextResponse.json(BizResult.fail('', '获取积分失败'));
    }
}
