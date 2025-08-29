import { NextRequest, NextResponse } from 'next/server';
import BizResult from '@/utils/BizResult';
import { ConfigService } from '@/utils/configService';
import { cookieTools } from '@/utils/cookieTools';

// 请求体接口
interface ConfigRequest {
    action: 'get_image_beds' | 'get_notifications' | 'get_system_configs' | 
            'update_image_bed' | 'update_notification' | 'update_system_config' |
            'initialize_configs';
    data?: any;
}

export async function POST(req: NextRequest): Promise<NextResponse> {
    try {
        const body: ConfigRequest = await req.json();
        const { action, data } = body;
        
        // 获取当前用户邮箱
        const { userEmail } = cookieTools(req);

        switch (action) {
            case 'get_image_beds':
                return await handleGetImageBeds(userEmail);
            
            case 'get_notifications':
                return await handleGetNotifications(userEmail);
            
            case 'get_system_configs':
                return await handleGetSystemConfigs(userEmail);
            
            case 'update_image_bed':
                return await handleUpdateImageBed(data, userEmail);
            
            case 'update_notification':
                return await handleUpdateNotification(data, userEmail);
            
            case 'update_system_config':
                return await handleUpdateSystemConfig(data, userEmail);
            
            case 'initialize_configs':
                return await handleInitializeConfigs(userEmail);
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('配置API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 获取所有图床配置
async function handleGetImageBeds(userEmail: string): Promise<NextResponse> {
    try {
        const configs = await ConfigService.getAllImageBedConfigs(userEmail);
        return NextResponse.json(BizResult.success(configs, '获取图床配置成功'));
    } catch (error) {
        console.error('获取图床配置失败:', error);
        return NextResponse.json(BizResult.fail('', '获取图床配置失败'));
    }
}

// 获取所有通知配置
async function handleGetNotifications(userEmail: string): Promise<NextResponse> {
    try {
        const configs = await ConfigService.getAllNotificationConfigs(userEmail);
        return NextResponse.json(BizResult.success(configs, '获取通知配置成功'));
    } catch (error) {
        console.error('获取通知配置失败:', error);
        return NextResponse.json(BizResult.fail('', '获取通知配置失败'));
    }
}

// 获取系统配置
async function handleGetSystemConfigs(userEmail: string): Promise<NextResponse> {
    try {
        // 这里可以返回一些常用的系统配置
        const webUrl = await ConfigService.getSystemConfig('WEB_URL', userEmail);
        const configs = {
            WEB_URL: webUrl
        };
        return NextResponse.json(BizResult.success(configs, '获取系统配置成功'));
    } catch (error) {
        console.error('获取系统配置失败:', error);
        return NextResponse.json(BizResult.fail('', '获取系统配置失败'));
    }
}

// 更新图床配置
async function handleUpdateImageBed(data: any, userEmail: string): Promise<NextResponse> {
    try {
        const { bedName, bedType, apiUrl, apiKey, authHeader, isActive, isDefault, priority, description } = data;
        
        if (!bedName || !bedType || !apiUrl) {
            return NextResponse.json(BizResult.fail('', '请填写完整的图床配置信息'));
        }

        const success = await ConfigService.setImageBedConfig(
            bedName,
            bedType,
            apiUrl,
            apiKey || '',
            authHeader || '',
            isDefault ?? false,
            priority ?? 0,
            description || '',
            userEmail
        );

        if (success) {
            return NextResponse.json(BizResult.success('', '图床配置更新成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '图床配置更新失败'));
        }
    } catch (error) {
        console.error('更新图床配置失败:', error);
        return NextResponse.json(BizResult.fail('', '更新图床配置失败'));
    }
}

// 更新通知配置
async function handleUpdateNotification(data: any, userEmail: string): Promise<NextResponse> {
    try {
        const { notifyType, notifyName, webhookUrl, apiKey, isActive, description } = data;
        
        if (!notifyType || !notifyName) {
            return NextResponse.json(BizResult.fail('', '请填写完整的通知配置信息'));
        }

        const success = await ConfigService.setNotificationConfig(
            notifyType,
            notifyName,
            webhookUrl || '',
            apiKey || '',
            description || '',
            userEmail
        );

        if (success) {
            return NextResponse.json(BizResult.success('', '通知配置更新成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '通知配置更新失败'));
        }
    } catch (error) {
        console.error('更新通知配置失败:', error);
        return NextResponse.json(BizResult.fail('', '更新通知配置失败'));
    }
}

// 更新系统配置
async function handleUpdateSystemConfig(data: any, userEmail: string): Promise<NextResponse> {
    try {
        const { configKey, configValue, configType, description } = data;
        
        if (!configKey || !configValue || !configType) {
            return NextResponse.json(BizResult.fail('', '请填写完整的系统配置信息'));
        }

        const success = await ConfigService.setSystemConfig(configKey, configValue, configType, description || '', userEmail);

        if (success) {
            return NextResponse.json(BizResult.success('', '系统配置更新成功'));
        } else {
            return NextResponse.json(BizResult.fail('', '系统配置更新失败'));
        }
    } catch (error) {
        console.error('更新系统配置失败:', error);
        return NextResponse.json(BizResult.fail('', '更新系统配置失败'));
    }
}

// 初始化默认配置
async function handleInitializeConfigs(userEmail: string): Promise<NextResponse> {
    try {
        await ConfigService.initializeDefaultConfigs(userEmail);
        return NextResponse.json(BizResult.success('', '默认配置初始化成功'));
    } catch (error) {
        console.error('初始化默认配置失败:', error);
        return NextResponse.json(BizResult.fail('', '初始化默认配置失败'));
    }
}
