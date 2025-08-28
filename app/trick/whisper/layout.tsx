import React from "react";

export const metadata = {
    title: '发布留言 | love-trick',
    description: 'love-trick',
}

interface WhisperLayoutProps {
    children: React.ReactNode;
}

export default function WhisperLayout({children}: WhisperLayoutProps) {
    return <>{children}</>
}
