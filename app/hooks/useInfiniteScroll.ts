import { useEffect, useRef } from 'react';

// 滚动触发回调函数类型
type ScrollCallback = () => void;

// useScrollTrigger Hook的参数类型
interface UseScrollTriggerOptions {
    callback: ScrollCallback;
    triggerPixels?: number;
}

const useScrollTrigger = (callback: ScrollCallback, triggerPixels: number = 100): void => {
    const timeoutIdRef = useRef<NodeJS.Timeout | null>(null); // 用于存储setTimeout的ID

    useEffect(() => {
        const handleScroll = (): void => {
            // 清除上一次的setTimeout
            if (timeoutIdRef.current) {
                clearTimeout(timeoutIdRef.current);
            }

            // 设置新的setTimeout
            timeoutIdRef.current = setTimeout(() => {
                // 检查是否滚动到距离底部triggerPixels的位置
                const scrollHeight = document.documentElement.scrollHeight;
                const currentHeight = window.innerHeight + window.pageYOffset;
                if (scrollHeight - currentHeight <= triggerPixels) {
                    callback();
                }
            }, 500); // 500毫秒的节流间隔
        };

        // 添加滚动事件监听
        window.addEventListener('scroll', handleScroll);

        // 组件卸载时清除事件监听
        return () => {
            window.removeEventListener('scroll', handleScroll);
            // 清除可能仍在等待的setTimeout
            if (timeoutIdRef.current) {
                clearTimeout(timeoutIdRef.current);
            }
        };
    }, [callback, triggerPixels]);
};

export default useScrollTrigger;