import React from "react";

export const metadata = {
    title: '任务详情 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface TaskInfoLayoutProps {
    children: React.ReactNode;
}

export default function TaskInfoLayout({children}: TaskInfoLayoutProps) {
    return <section>{children}</section>
}
