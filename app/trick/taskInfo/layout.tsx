import React from "react";

export const metadata = {
    title: '任务详情 | love-trick',
    description: 'love-trick',
}

interface TaskInfoLayoutProps {
    children: React.ReactNode;
}

export default function TaskInfoLayout({children}: TaskInfoLayoutProps) {
    return <section>{children}</section>
}
