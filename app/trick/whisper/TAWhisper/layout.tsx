import React from "react";

export const metadata = {
    title: 'TA的留言 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface TAWhisperLayoutProps {
    children: React.ReactNode;
}

export default function TAWhisperLayout({children}: TAWhisperLayoutProps) {
    return <>{children}</>
}
