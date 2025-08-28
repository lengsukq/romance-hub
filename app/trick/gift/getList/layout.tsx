import React from "react";

export const metadata = {
    title: '礼物兑换 | love-trick',
    description: 'love-trick',
}

interface GetListLayoutProps {
    children: React.ReactNode;
}

export default function GetListLayout({children}: GetListLayoutProps) {
    return <>{children}</>
}
