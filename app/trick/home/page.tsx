'use client'

import React from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardBody, CardHeader } from '@heroui/react';

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

export default function HomePage() {
  return (
    <div className="home-2026 min-h-screen">
      <header className="home-2026__header px-5 pt-5 pb-3">
        <div className="home-2026__badge">
          <span className="home-2026__year">锦书</span>
        </div>
        <p className="home-2026__title">首页</p>
        <p className="home-2026__subtitle">两心相知，一事一诺</p>
      </header>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 px-5 pt-4">
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

