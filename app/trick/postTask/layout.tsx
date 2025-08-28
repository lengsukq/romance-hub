import React from "react";

export const metadata = {
    title: '发布任务 | love-trick',
    description: 'love-trick',
}

interface PostTaskLayoutProps {
    children: React.ReactNode;
}

export default function PostTaskLayout({children}: PostTaskLayoutProps) {
    return <>{children}</>
}
