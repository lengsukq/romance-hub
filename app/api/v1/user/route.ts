'use server'
import BizResult from '@/utils/BizResult';
import { UserService } from '@/utils/ormService';
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
        const result = await UserService.login(username, password);

        if (result) {
            const { userId, userEmail, lover, score } = result;
            const oneDay = 60 * 1000 * 60 * 24 * 365;
            const cookie = encryptData({
                userEmail: userEmail, 
                userId: userId, 
                userName: username, 
                lover: lover
            });
            
            (await cookies()).set({
                name: userEmail,
                value: cookie,
                httpOnly: false,
                path: '/',
                expires: Date.now() + oneDay
            });
            
            return NextResponse.json(BizResult.success(result, '登录成功'), {
                status: 200,
                headers: {'Set-Cookie': `cookie=${JSON.stringify((await cookies()).get(userEmail))}`},
            });
        } else {
            return NextResponse.json(BizResult.fail('', '用户名或密码错误'));
        }
    } catch (error) {
        console.error('登录失败:', error);
        return NextResponse.json(BizResult.fail('', '登录失败'));
    }
}

// 处理注册（双账号注册）
async function handleRegister(data: RegisterData): Promise<NextResponse> {
    const { 
        userEmail, username, password, describeBySelf, lover, avatar: imgURL,
        loverUsername, loverAvatar: loverImgURL, loverDescribeBySelf 
    } = data;
    
    // 验证基本字段
    if (!userEmail || !username || !password || !describeBySelf || !lover) {
        return NextResponse.json(BizResult.fail('', '请检查注册信息是否填写正确'));
    }
    
    // 验证关联者信息
    if (!loverUsername || !loverDescribeBySelf) {
        return NextResponse.json(BizResult.fail('', '请填写完整的关联者信息'));
    }
    
    if (userEmail === lover) {
        return NextResponse.json(BizResult.fail('', '用户邮箱与关联者邮箱不可相同'));
    }
    
    try {
        // 检查主账号用户是否已存在
        const existingUser = await UserService.checkUserExists(userEmail, username);
        if (existingUser) {
            return NextResponse.json(BizResult.fail('', '主账号用户已存在'));
        }
        
        // 检查关联者账号是否已存在
        const existingLover = await UserService.checkUserExists(lover, loverUsername);
        if (existingLover) {
            return NextResponse.json(BizResult.fail('', '关联者账号已存在'));
        }
        
        // 生成默认头像
        const avatar = imgURL ? imgURL : await randomImages();
        const loverAvatar = loverImgURL ? loverImgURL : await randomImages();
        
        // 同时创建两个账号
        await Promise.all([
            // 创建主账号
            UserService.createUser({
                userEmail,
                username,
                password,
                avatar,
                describeBySelf,
                lover
            }),
            // 创建关联者账号
            UserService.createUser({
                userEmail: lover,
                username: loverUsername,
                password, // 使用相同密码
                avatar: loverAvatar,
                describeBySelf: loverDescribeBySelf,
                lover: userEmail // 互相关联
            })
        ]);

        return NextResponse.json(BizResult.success('', '双账号注册成功'));
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
            (await cookies()).delete(userEmail);
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
        
        const result = await UserService.getUserByEmail(userEmail);
        
        if (result) {
            return NextResponse.json(BizResult.success(result, '获取用户信息成功'));
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
        
        const updateData: {
            username?: string;
            lover?: string;
            avatar?: string;
            describeBySelf?: string;
        } = {};
        
        // 动态构建更新字段
        if (data.username) {
            updateData.username = data.username;
        }
        if (data.lover) {
            updateData.lover = data.lover;
        }
        if (data.avatar) {
            updateData.avatar = data.avatar;
        }
        if (data.describeBySelf) {
            updateData.describeBySelf = data.describeBySelf;
        }
        
        if (Object.keys(updateData).length === 0) {
            return NextResponse.json(BizResult.fail('', '没有要更新的字段'));
        }
        
        await UserService.updateUser(userEmail, updateData);
        
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
        
        const result = await UserService.getUserScore(userEmail);
        
        if (result) {
            return NextResponse.json(BizResult.success(result, '获取积分成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '用户不存在'));
        }
    } catch (error) {
        console.error('获取积分失败:', error);
        return NextResponse.json(BizResult.fail('', '获取积分失败'));
    }
}
