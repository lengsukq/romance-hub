import React from "react";

export const metadata = {
    title: '礼物兑换 | RomanceHub',
    description: 'RomanceHub - 情侣任务管理系统',
}

interface GetListLayoutProps {
    children: React.ReactNode;
}

export default function GetListLayout({children}: GetListLayoutProps) {
    return <>{children}</>
}
