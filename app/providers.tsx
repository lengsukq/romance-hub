'use client'

import {HeroUIProvider} from "@heroui/react";
import {Provider} from 'react-redux';
import {useRouter} from 'next/navigation';
import { store } from '@/store/store'
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
            </HeroUIProvider>
        </Provider>
    )
}
