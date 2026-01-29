'use client'
import React from 'react';
import { Button, Card, CardBody, CardHeader } from "@heroui/react";
import { notify, showNotification, notifyPromise } from '@/utils/client/notificationUtils';

// 演示新通知系统的组件
export default function NotificationDemo() {
  const handleBasicNotifications = () => {
    notify.success('操作成功！');
    setTimeout(() => notify.error('这是一个错误消息'), 1000);
    setTimeout(() => notify.warning('这是一个警告消息'), 2000);
    setTimeout(() => notify.info('这是一个信息提示'), 3000);
  };

  const handleCustomNotification = () => {
    showNotification({
      type: 'success',
      message: '自定义通知',
      description: '这是一个带描述的通知消息',
      duration: 6000
    });
  };

  const handlePromiseNotification = () => {
    const fakeApiCall = new Promise((resolve, reject) => {
      setTimeout(() => {
        Math.random() > 0.5 ? resolve('成功数据') : reject('网络错误');
      }, 2000);
    });

    notifyPromise(fakeApiCall, {
      loading: '正在处理请求...',
      success: '请求处理成功！',
      error: '请求处理失败'
    });
  };

  return (
    <Card className="max-w-md mx-auto">
      <CardHeader>
        <h3 className="text-lg font-semibold">通知系统演示</h3>
      </CardHeader>
      <CardBody className="space-y-3">
        <Button 
          onClick={handleBasicNotifications}
          color="primary"
          className="w-full"
        >
          基础通知类型
        </Button>
        
        <Button 
          onClick={handleCustomNotification}
          color="secondary"
          className="w-full"
        >
          自定义通知
        </Button>
        
        <Button 
          onClick={handlePromiseNotification}
          color="success"
          className="w-full"
        >
          Promise 通知
        </Button>
      </CardBody>
    </Card>
  );
}
