import React from "react";

export const metadata = {
    title: '我的留言 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface MyWhisperLayoutProps {
    children: React.ReactNode;
}

export default function MyWhisperLayout({children}: MyWhisperLayoutProps) {
    return <>{children}</>
}
