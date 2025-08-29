import React from "react";

export const metadata = {
    title: '收藏留言 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface WhisperListLayoutProps {
    children: React.ReactNode;
}

export default function WhisperListLayout({children}: WhisperListLayoutProps) {
    return <>{children}</>
}
