import React from "react";

export const metadata = {
    title: '添加礼物 | love-trick',
    description: 'love-trick',
}

interface AddGiftLayoutProps {
    children: React.ReactNode;
}

export default function AddGiftLayout({children}: AddGiftLayoutProps) {
    return <>{children}</>
}
