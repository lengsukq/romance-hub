import React from "react";

export const metadata = {
    title: '收藏礼物 | love-trick',
    description: 'love-trick',
}

interface GiftListLayoutProps {
    children: React.ReactNode;
}

export default function GiftListLayout({children}: GiftListLayoutProps) {
    return <>{children}</>
}
