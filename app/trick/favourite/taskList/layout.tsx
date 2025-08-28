import React from "react";

export const metadata = {
    title: '收藏任务 | love-trick',
    description: 'love-trick',
}

interface TaskListLayoutProps {
    children: React.ReactNode;
}

export default function TaskListLayout({children}: TaskListLayoutProps) {
    return <>{children}</>
}
