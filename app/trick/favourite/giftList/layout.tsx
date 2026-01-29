import React from "react";

export const metadata = {
    title: '收藏礼物 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface GiftListLayoutProps {
    children: React.ReactNode;
}

export default function GiftListLayout({children}: GiftListLayoutProps) {
    return <>{children}</>
}
