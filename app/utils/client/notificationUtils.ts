'use client'
import { toast } from 'sonner'

// 通知类型接口
interface NotificationOptions {
  type?: 'success' | 'error' | 'warning' | 'info'
  message: string
  duration?: number
  description?: string
}

// 统一的通知方法
export const showNotification = ({ type = 'info', message, duration = 4000, description }: NotificationOptions) => {
  const options = {
    duration,
    description,
  }

  switch (type) {
    case 'success':
      return toast.success(message, options)
    case 'error':
      return toast.error(message, options)
    case 'warning':
      return toast.warning(message, options)
    case 'info':
    default:
      return toast.info(message, options)
  }
}

// 兼容原有 react-vant Notify.show 的接口
export const Notify = {
  show: ({ type = 'info', message }: { type?: 'success' | 'error' | 'warning' | 'info', message: string }) => {
    showNotification({ type, message })
  }
}

// 导出常用方法
export const notify = {
  success: (message: string, description?: string) => showNotification({ type: 'success', message, description }),
  error: (message: string, description?: string) => showNotification({ type: 'error', message, description }),
  warning: (message: string, description?: string) => showNotification({ type: 'warning', message, description }),
  info: (message: string, description?: string) => showNotification({ type: 'info', message, description }),
}

// Promise 支持
export const notifyPromise = <T>(
  promise: Promise<T>,
  {
    loading = '加载中...',
    success = '操作成功',
    error = '操作失败',
  }: {
    loading?: string
    success?: string | ((data: T) => string)
    error?: string | ((error: any) => string)
  }
) => {
  return toast.promise(promise, {
    loading,
    success,
    error,
  })
}
