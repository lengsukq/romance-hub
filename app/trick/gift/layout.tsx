import React from "react";

export const metadata = {
    title: '我的礼物 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface GiftLayoutProps {
    children: React.ReactNode;
}

export default function GiftLayout({children}: GiftLayoutProps) {
    return <>{children}</>
}
