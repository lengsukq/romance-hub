import React from "react";

export const metadata = {
    title: '发布任务 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface PostTaskLayoutProps {
    children: React.ReactNode;
}

export default function PostTaskLayout({children}: PostTaskLayoutProps) {
    return <>{children}</>
}
