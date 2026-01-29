import React from "react";

export const metadata = {
    title: '添加礼物 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface AddGiftLayoutProps {
    children: React.ReactNode;
}

export default function AddGiftLayout({children}: AddGiftLayoutProps) {
    return <>{children}</>
}
