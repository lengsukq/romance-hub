import React from "react";

export const metadata = {
    title: '我的信息 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface MyInfoLayoutProps {
    children: React.ReactNode;
}

export default function MyInfoLayout({children}: MyInfoLayoutProps) {
    return <>{children}</>
}
