import { NextRequest, NextResponse } from 'next/server';
import { BizResult } from '@/utils/BizResult';
import { ConfigService } from '@/utils/configService';

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

        switch (action) {
            case 'get_image_beds':
                return await handleGetImageBeds();
            
            case 'get_notifications':
                return await handleGetNotifications();
            
            case 'get_system_configs':
                return await handleGetSystemConfigs();
            
            case 'update_image_bed':
                return await handleUpdateImageBed(data);
            
            case 'update_notification':
                return await handleUpdateNotification(data);
            
            case 'update_system_config':
                return await handleUpdateSystemConfig(data);
            
            case 'initialize_configs':
                return await handleInitializeConfigs();
            
            default:
                return NextResponse.json(BizResult.fail('', '不支持的操作类型'));
        }
    } catch (error) {
        console.error('配置API错误:', error);
        return NextResponse.json(BizResult.fail('', '系统异常'));
    }
}

// 获取所有图床配置
async function handleGetImageBeds(): Promise<NextResponse> {
    try {
        const configs = await ConfigService.getAllImageBedConfigs();
        return NextResponse.json(BizResult.success(configs, '获取图床配置成功'));
    } catch (error) {
        console.error('获取图床配置失败:', error);
        return NextResponse.json(BizResult.fail('', '获取图床配置失败'));
    }
}

// 获取所有通知配置
async function handleGetNotifications(): Promise<NextResponse> {
    try {
        const configs = await ConfigService.getAllNotificationConfigs();
        return NextResponse.json(BizResult.success(configs, '获取通知配置成功'));
    } catch (error) {
        console.error('获取通知配置失败:', error);
        return NextResponse.json(BizResult.fail('', '获取通知配置失败'));
    }
}

// 获取系统配置
async function handleGetSystemConfigs(): Promise<NextResponse> {
    try {
        // 这里可以返回一些常用的系统配置
        const webUrl = await ConfigService.getSystemConfig('WEB_URL');
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
async function handleUpdateImageBed(data: any): Promise<NextResponse> {
    try {
        const { bedName, bedType, apiUrl, apiKey, authHeader, isActive, isDefault, priority, description } = data;
        
        if (!bedName || !bedType || !apiUrl) {
            return NextResponse.json(BizResult.fail('', '请填写完整的图床配置信息'));
        }

        const success = await ConfigService.setImageBedConfig({
            bedName,
            bedType,
            apiUrl,
            apiKey,
            authHeader,
            isActive: isActive ?? true,
            isDefault: isDefault ?? false,
            priority: priority ?? 0,
            description
        });

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
async function handleUpdateNotification(data: any): Promise<NextResponse> {
    try {
        const { notifyType, notifyName, webhookUrl, apiKey, isActive, description } = data;
        
        if (!notifyType || !notifyName) {
            return NextResponse.json(BizResult.fail('', '请填写完整的通知配置信息'));
        }

        const success = await ConfigService.setNotificationConfig({
            notifyType,
            notifyName,
            webhookUrl,
            apiKey,
            isActive: isActive ?? true,
            description
        });

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
async function handleUpdateSystemConfig(data: any): Promise<NextResponse> {
    try {
        const { configKey, configValue, configType, description } = data;
        
        if (!configKey || !configValue || !configType) {
            return NextResponse.json(BizResult.fail('', '请填写完整的系统配置信息'));
        }

        const success = await ConfigService.setSystemConfig(configKey, configValue, configType, description);

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
async function handleInitializeConfigs(): Promise<NextResponse> {
    try {
        await ConfigService.initializeDefaultConfigs();
        return NextResponse.json(BizResult.success('', '默认配置初始化成功'));
    } catch (error) {
        console.error('初始化默认配置失败:', error);
        return NextResponse.json(BizResult.fail('', '初始化默认配置失败'));
    }
}
