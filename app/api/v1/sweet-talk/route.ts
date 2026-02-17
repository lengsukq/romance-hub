import BizResult from '@/utils/BizResult';
import { NextResponse } from 'next/server';

/** 情话 API：与 App 端一致，用于首页「今日一言」 */
const SWEET_TALK_API_URL = 'https://api.zxki.cn/api/twqh';

export async function GET(): Promise<NextResponse> {
  try {
    const res = await fetch(SWEET_TALK_API_URL, { next: { revalidate: 0 } });
    if (!res.ok) {
      return NextResponse.json(BizResult.fail('', '获取一言失败'));
    }
    const body = (await res.text()).trim();
    if (!body) {
      return NextResponse.json(BizResult.fail('', '一言为空'));
    }
    if (body.startsWith('{')) {
      const map = JSON.parse(body) as Record<string, unknown>;
      const text =
        (map['data'] ?? map['content'] ?? map['msg'] ?? map['text']) as string | undefined;
      return NextResponse.json(BizResult.success(text ?? body, ''));
    }
    return NextResponse.json(BizResult.success(body, ''));
  } catch {
    return NextResponse.json(BizResult.fail('', '获取一言失败'));
  }
}
