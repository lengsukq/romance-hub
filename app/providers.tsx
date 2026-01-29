'use client'

import {HeroUIProvider} from "@heroui/react";
import {Provider} from 'react-redux';
import {useRouter} from 'next/navigation';
import { store } from '@/store/store'
import { Toaster } from 'sonner'
import type { ReactNode } from 'react'

interface ProvidersProps {
  children: ReactNode
}

export function Providers({children}: ProvidersProps) {
    const router = useRouter();
    return (
        <Provider store={store}>
            <HeroUIProvider 
                navigate={router.push}
                locale="zh-CN"
            >
                {children}
                <Toaster 
                    position="top-center"
                    richColors
                    closeButton
                    expand={false}
                    duration={4000}
                />
            </HeroUIProvider>
        </Provider>
    )
}
