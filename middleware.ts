'use server'
import {NextResponse, NextRequest} from 'next/server'
import {cookies} from 'next/headers'
import dayjs from "dayjs";
import BizResult from "@/utils/BizResult";
import { decryptData } from "@/utils/cookieTools";

interface ClientCookie {
    name: string;
    value: string;
    expires?: string;
}

export async function middleware(request: NextRequest) {
    try {
        const reqCookie = request.cookies.get('cookie');
        if (!reqCookie?.value) {
            console.log('中间件: 未找到 cookie');
            return Response.json(BizResult.fail('', '请登录后使用'));
        }

        let clientCookie: ClientCookie;
        try {
            let raw = reqCookie.value;
            try {
                clientCookie = JSON.parse(raw);
            } catch {
                raw = decodeURIComponent(raw);
                clientCookie = JSON.parse(raw);
            }
        } catch (parseError) {
            console.log('中间件: cookie 解析失败', parseError);
            return Response.json(BizResult.fail('', '请重新登录'));
        }

        if (!clientCookie.value) {
            console.log('中间件: cookie 缺少 value');
            return Response.json(BizResult.fail('', '请重新登录'));
        }

        const payload = decryptData(clientCookie.value);
        if (!payload?.userEmail) {
            console.log('中间件: JWT 无效或已过期');
            return Response.json(BizResult.fail('', '请重新登录'));
        }

        if (clientCookie.expires) {
            const cookieDate = dayjs(clientCookie.expires);
            if (cookieDate.isBefore(dayjs())) {
                console.log('中间件: cookie 已过期');
                const pastDate = new Date(Date.now() - 86400000).toUTCString();
                return Response.json(BizResult.fail('', '登录过期'), {
                    status: 200,
                    headers: {'Set-Cookie': `cookie=;Expires=${pastDate};`},
                });
            }
        }

        const serverCookie = (await cookies()).get(clientCookie.name);
        if (serverCookie && clientCookie.value !== serverCookie.value) {
            console.log('中间件: cookie 值不匹配');
            const pastDate = new Date(Date.now() - 86400000).toUTCString();
            return Response.json(BizResult.fail('', '身份验证失败，请重新登录'), {
                status: 200,
                headers: {'Set-Cookie': `cookie=;Expires=${pastDate};`},
            });
        }

        console.log('中间件: 验证通过');
        return NextResponse.next();
    } catch (e) {
        console.log('中间件报错:', e);
        return Response.json(BizResult.fail('', '服务器错误，请重试'));
    }
}

// See "Matching Paths" below to learn more
export const config = {
    matcher: [
        /*
         * 明确指定需要中间件保护的 API 路径
         * 排除 /api/v1/user (用户认证相关 API)
         */
        '/api/v1/gift/:path*',
        '/api/v1/task/:path*',
        '/api/v1/whisper/:path*',
        '/api/v1/favourite/:path*',
        '/api/v1/common/:path*',
    ],
}
