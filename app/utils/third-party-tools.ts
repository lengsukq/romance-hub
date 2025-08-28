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
export function sendMsg(msg: string): void {
    const wxRobotUrl = process.env.WX_ROBOT_URL;
    const webUrl = process.env.WEB_URL;
    
    if (!wxRobotUrl) {
        console.error('WX_ROBOT_URL 未配置');
        return;
    }

    const messageBody: WXMessage = {
        msgtype: "text", 
        text: {
            content: `${msg} 👉${webUrl}`
        }
    };

    // 发送 POST 请求到企业微信机器人的 API
    fetch(wxRobotUrl, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(messageBody),
    })
        .then(response => response.json())
        .then(data => console.log('POST 请求成功：', data))
        .catch(error => console.error('POST 请求失败：', error));
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
