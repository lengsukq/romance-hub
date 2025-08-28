import React from "react";

export const metadata = {
    title: '我的留言 | love-trick',
    description: 'love-trick',
}

interface MyWhisperLayoutProps {
    children: React.ReactNode;
}

export default function MyWhisperLayout({children}: MyWhisperLayoutProps) {
    return <>{children}</>
}
