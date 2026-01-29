import React from "react";

export const metadata = {
    title: '发布留言 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface WhisperLayoutProps {
    children: React.ReactNode;
}

export default function WhisperLayout({children}: WhisperLayoutProps) {
    return <>{children}</>
}
