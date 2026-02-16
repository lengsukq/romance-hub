import {Providers} from "./providers";
import './globals.css'
import type { Metadata } from 'next'
import type { ReactNode } from 'react'

export const metadata: Metadata = {
    title: '登录 | RomanceHub 2026',
    description: 'RomanceHub 2026 - 情侣任务管理系统',
};

interface RootLayoutProps {
  children: ReactNode
}

export default function RootLayout({children}: RootLayoutProps) {
    return (
        <html lang="en" className='light'>
        <head>
          <meta name="referrer" content="no-referrer"/>
          <link rel="icon" href="/defaultAvatar.jpg" sizes="any" />
        </head>
        <body>
        <Providers>
            {children}
        </Providers>
        </body>
        </html>
    );
}
