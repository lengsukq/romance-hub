import React from "react";
import {TrickProviders} from "./trickProviders";

export const metadata = {
    title: '首页 | love-trick',
    description: 'love-trick',
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
