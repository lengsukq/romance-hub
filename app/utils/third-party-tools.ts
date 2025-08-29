// 随机图片API响应接口
interface RandomImageResponse {
    imgurl: string;
}

// 企业微信消息体接口
interface WXMessage {
    msgtype: string;
    text: {
        content: string;
    };
}

// 发送文本消息
export async function sendMsg(msg: string): Promise<void> {
    try {
        // 从数据库获取微信机器人配置
        const wxConfig = await ConfigService.getNotificationConfig('wx_robot');
        if (!wxConfig || !wxConfig.webhookUrl) {
            console.error('微信机器人配置未找到或未配置webhook地址');
            return;
        }

        // 获取网站URL配置
        const webUrl = await ConfigService.getSystemConfig('WEB_URL') || '';

        const messageBody: WXMessage = {
            msgtype: "text", 
            text: {
                content: `${msg} 👉${webUrl}`
            }
        };

        // 发送 POST 请求到企业微信机器人的 API
        const response = await fetch(wxConfig.webhookUrl, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(messageBody),
        });

        if (response.ok) {
            const data = await response.json();
            console.log('微信通知发送成功：', data);
        } else {
            console.error('微信通知发送失败：', response.status);
        }
    } catch (error) {
        console.error('微信通知发送失败：', error);
    }
}

// 获取随机图片
export async function randomImages(): Promise<string> {
    const defaultImage = 'https://www.freeimg.cn/i/2023/12/31/659105191c747.png';
    
    try {
        const response = await fetch('https://www.dmoe.cc/random.php?return=json');

        if (!response.ok) {
            return defaultImage;
        }

        const data: RandomImageResponse = await response.json();
        console.log('随机图片', data);
        return data.imgurl || defaultImage;
    } catch (error) {
        console.error('There was a problem with the fetch operation:', error);
        return defaultImage;
    }
}
