import React from "react";

export const metadata = {
    title: 'TA的留言 | love-trick',
    description: 'love-trick',
}

interface TAWhisperLayoutProps {
    children: React.ReactNode;
}

export default function TAWhisperLayout({children}: TAWhisperLayoutProps) {
    return <>{children}</>
}
