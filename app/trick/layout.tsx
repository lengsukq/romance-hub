import React from "react";
import {TrickProviders} from "./trickProviders";

export const metadata = {
    title: '首页 | RomanceHub 2026',
    description: 'RomanceHub 2026 - 情侣任务管理系统',
}

interface RootLayoutProps {
    children: React.ReactNode;
}

export default function RootLayout({children}: RootLayoutProps) {
    return (
        <TrickProviders>
            {children}
        </TrickProviders>
    )
}
