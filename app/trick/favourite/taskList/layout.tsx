import React from "react";

export const metadata = {
    title: '收藏任务 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface TaskListLayoutProps {
    children: React.ReactNode;
}

export default function TaskListLayout({children}: TaskListLayoutProps) {
    return <>{children}</>
}
