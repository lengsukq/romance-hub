'use client'

import React, { useCallback, useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Button, Card, CardBody, CardHeader } from '@heroui/react';
import { post } from '@/utils/client/fetchUtil';

const COUPLE_COUNTER_STORAGE_KEY = 'coupleCounterDisplayMode';
type CounterDisplayMode = 'full' | 'seconds';

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

function parseCoupleSince(dateStr: string): number | null {
  if (!dateStr || !/^\d{4}-\d{2}-\d{2}$/.test(dateStr)) return null;
  const t = new Date(dateStr + 'T00:00:00').getTime();
  return isNaN(t) ? null : t;
}

function formatElapsed(ms: number): { days: number; hours: number; minutes: number; seconds: number; totalSeconds: number } {
  const totalSeconds = Math.floor(ms / 1000);
  const days = Math.floor(totalSeconds / 86400);
  const rest = totalSeconds % 86400;
  const hours = Math.floor(rest / 3600);
  const rest2 = rest % 3600;
  const minutes = Math.floor(rest2 / 60);
  const seconds = rest2 % 60;
  return { days, hours, minutes, seconds, totalSeconds };
}

export default function HomePage() {
  const [sweetTalk, setSweetTalk] = useState<string | null>(null);
  const [sweetTalkLoading, setSweetTalkLoading] = useState(true);
  const router = useRouter();
  const [coupleSince, setCoupleSince] = useState<string | null>(null);
  const [coupleConfigFetched, setCoupleConfigFetched] = useState(false);
  const [counterMode, setCounterMode] = useState<CounterDisplayMode>('full');
  const [now, setNow] = useState(() => Date.now());

  useEffect(() => {
    try {
      const saved = localStorage.getItem(COUPLE_COUNTER_STORAGE_KEY) as CounterDisplayMode | null;
      if (saved === 'full' || saved === 'seconds') setCounterMode(saved);
    } catch (_) {}
  }, []);

  useEffect(() => {
    post('/api/v1/config', { action: 'get_system_configs' })
      .then((res: { code: number; data?: { COUPLE_SINCE?: string } }) => {
        setCoupleConfigFetched(true);
        if (res.code === 200 && res.data?.COUPLE_SINCE?.trim()) setCoupleSince(res.data.COUPLE_SINCE.trim());
      })
      .catch(() => setCoupleConfigFetched(true));
  }, []);

  useEffect(() => {
    if (!coupleSince) return;
    const id = setInterval(() => setNow(Date.now()), 1000);
    return () => clearInterval(id);
  }, [coupleSince]);

  const toggleCounterMode = useCallback(() => {
    setCounterMode((prev) => {
      const next = prev === 'full' ? 'seconds' : 'full';
      try { localStorage.setItem(COUPLE_COUNTER_STORAGE_KEY, next); } catch (_) {}
      return next;
    });
  }, []);

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
    if (typeof document !== 'undefined' && document.body) {
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

      {/* 与君相守 · 实时计时 或 未设置时跳转配置 */}
      {coupleConfigFetched && (
        <div className="px-5 pt-2 pb-4">
          {coupleSince ? (() => {
            const start = parseCoupleSince(coupleSince);
            if (start == null || now < start) return null;
            const { days, hours, minutes, seconds, totalSeconds } = formatElapsed(now - start);
            const label = counterMode === 'full'
              ? `与君相守 已 ${days} 天 ${hours} 时 ${seconds} 秒`
              : `共度 ${totalSeconds.toLocaleString()} 秒`;
            return (
              <button
                type="button"
                onClick={toggleCounterMode}
                className="w-full rounded-2xl border border-default-200 bg-primary-50/30 dark:bg-primary-900/15 px-4 py-3 text-left transition hover:opacity-90 active:opacity-95"
              >
                <span className="text-default-500 text-xs font-medium">相守至今</span>
                <p className="text-default-700 font-medium mt-1 tabular-nums">{label}</p>
                <p className="text-default-400 text-xs mt-1">轻触切换 天时秒 / 仅秒</p>
              </button>
            );
          })() : (
            <button
              type="button"
              onClick={() => router.push('/trick/config')}
              className="w-full rounded-2xl border border-dashed border-default-300 bg-default-50/50 dark:bg-default-100/10 px-4 py-3 text-left transition hover:opacity-90 active:opacity-95"
            >
              <span className="text-default-500 text-xs font-medium">相守至今</span>
              <p className="text-default-600 font-medium mt-1">轻触设置相守之日</p>
              <p className="text-default-400 text-xs mt-1">在设置中填写「在一起的日子」后，此处将显示相守时长</p>
            </button>
          )}
        </div>
      )}

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
        <EntryCard title="我的赠礼" subtitle="吾架 · 已上架/待使用/已用完" to="/trick/gift" />
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

