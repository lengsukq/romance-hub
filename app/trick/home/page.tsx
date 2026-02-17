'use client'

import React, { useCallback, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button, Card, CardBody, CardHeader } from '@heroui/react';

interface EntryCardProps {
  title: string;
  subtitle: string;
  to: string;
}

function EntryCard({ title, subtitle, to }: EntryCardProps) {
  const router = useRouter();
  return (
    <Card isPressable onPress={() => router.push(to)} className="hover:opacity-95">
      <CardHeader className="pb-0">
        <div className="flex flex-col">
          <p className="text-base font-semibold text-default-700">{title}</p>
          <p className="text-xs text-default-400">{subtitle}</p>
        </div>
      </CardHeader>
      <CardBody />
    </Card>
  );
}

async function fetchSweetTalk(): Promise<string | null> {
  try {
    const res = await fetch('/api/v1/sweet-talk');
    const json = await res.json();
    if (json?.code === 200 && json?.data) return String(json.data).trim();
    return null;
  } catch {
    return null;
  }
}

export default function HomePage() {
  const [sweetTalk, setSweetTalk] = useState<string | null>(null);
  const [sweetTalkLoading, setSweetTalkLoading] = useState(true);

  const loadSweetTalk = useCallback(async () => {
    setSweetTalkLoading(true);
    const text = await fetchSweetTalk();
    setSweetTalk(text);
    setSweetTalkLoading(false);
  }, []);

  useEffect(() => {
    void loadSweetTalk();
  }, [loadSweetTalk]);

  const copySweetTalk = useCallback(() => {
    if (!sweetTalk) return;
    navigator.clipboard.writeText(sweetTalk);
    // 简单提示可后续接入 Notify
    if (typeof window !== 'undefined' && window.getSelection) {
      const toast = document.createElement('div');
      toast.textContent = '已复制到剪贴板';
      toast.className = 'fixed bottom-20 left-1/2 -translate-x-1/2 px-4 py-2 rounded-lg bg-default-800 text-white text-sm z-50';
      document.body.appendChild(toast);
      setTimeout(() => toast.remove(), 1500);
    }
  }, [sweetTalk]);

  return (
    <div className="home-2026 min-h-screen">
      <header className="home-2026__header px-5 pt-5 pb-3">
        <div className="home-2026__badge">
          <span className="home-2026__year">锦书</span>
        </div>
        <p className="home-2026__title">首页</p>
        <p className="home-2026__subtitle">两心相知，一事一诺</p>
      </header>

      {/* 今日一言：与 App 一致 */}
      <div className="px-5 pt-2 pb-4">
        <div className="rounded-3xl border border-default-200 bg-primary-50/40 dark:bg-primary-900/20 px-4 py-3.5 min-h-[72px] flex flex-col justify-center">
          {sweetTalkLoading ? (
            <div className="flex items-center justify-center gap-2 text-default-500 text-sm">
              <span className="inline-block w-4 h-4 border-2 border-primary border-t-transparent rounded-full animate-spin" />
              一言一语…
            </div>
          ) : sweetTalk ? (
            <>
              <div className="flex items-center gap-2 mb-2">
                <span className="w-0.5 h-3.5 rounded-full bg-primary" />
                <span className="text-primary text-xs font-medium">今日一言</span>
              </div>
              <p className="text-default-700 text-sm leading-relaxed mb-3">{sweetTalk}</p>
              <div className="flex justify-end gap-2">
                <Button size="sm" variant="light" color="primary" onPress={copySweetTalk}>
                  复制
                </Button>
                <Button size="sm" variant="light" color="primary" onPress={loadSweetTalk}>
                  更新
                </Button>
              </div>
            </>
          ) : null}
        </div>
      </div>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 px-5 pt-2">
        <EntryCard title="心诺" subtitle="立一诺，择一事" to="/trick" />
        <EntryCard title="赠礼" subtitle="以心意，换欢喜" to="/trick/gift/getList" />
        <EntryCard title="私语" subtitle="锦书寄语，念念相闻" to="/trick/whisper/TAWhisper" />
        <EntryCard title="藏心" subtitle="所爱所念，尽收于此" to="/trick/favourite/taskList" />
        <EntryCard title="设置" subtitle="通知与图床等配置" to="/trick/config" />
        <EntryCard title="吾心" subtitle="吾之信息 · 良人信息" to="/trick/myInfo" />
      </div>

      <div className="px-5 pt-4 pb-8 text-xs text-default-400">
        小提示：若你曾遇见 Web 底部栏“消失”，多半是窗口高度过小触发了隐藏规则；现已收敛该规则，底部入口应常驻。
      </div>
    </div>
  );
}

