import React from "react";

export const metadata = {
    title: '我的信息 | love-trick',
    description: 'love-trick',
}

interface MyInfoLayoutProps {
    children: React.ReactNode;
}

export default function MyInfoLayout({children}: MyInfoLayoutProps) {
    return <>{children}</>
}
