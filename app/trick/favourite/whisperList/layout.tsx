import React from "react";

export const metadata = {
    title: '收藏留言 | love-trick',
    description: 'love-trick',
}

interface WhisperListLayoutProps {
    children: React.ReactNode;
}

export default function WhisperListLayout({children}: WhisperListLayoutProps) {
    return <>{children}</>
}
