import React from "react";

export const metadata = {
    title: '我的礼物 | love-trick',
    description: 'love-trick',
}

interface GiftLayoutProps {
    children: React.ReactNode;
}

export default function GiftLayout({children}: GiftLayoutProps) {
    return <>{children}</>
}
