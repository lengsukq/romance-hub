'use client'

import React, { useState, ChangeEvent } from 'react';
import { useRouter } from 'next/navigation';
import { Input, Button, Avatar } from '@heroui/react';
import { loginApi } from '@/utils/client/apihttp';
import { Notify } from '@/utils/client/notificationUtils';
import Register from '@/components/register';

interface LoginResponse {
  code: number;
  msg: string;
  data: {
    userId: number;
    userEmail: string;
    lover: string;
    score: number;
  };
}

interface UserInfo {
  username: string;
  userId: number;
  userEmail: string;
  lover: string;
  score: number;
}

interface LoginParams {
  username: string;
  password: string;
}

export default function Home() {
  const [username, setUsername] = useState<string>('');
  const [password, setPassword] = useState<string>('');
  const router = useRouter();
  const [isLoading, setLoading] = useState<boolean>(false);
  const [isOpen, setIsOpen] = useState<boolean>(false);

  const handleUsernameChange = (e: ChangeEvent<HTMLInputElement>) => {
    setUsername(e.target.value);
  };

  const handlePasswordChange = (e: ChangeEvent<HTMLInputElement>) => {
    setPassword(e.target.value);
  };

  const login = async () => {
    if (!username || !password) {
      Notify.show({ type: 'warning', message: '请输入用户名和密码' });
      return;
    }

    setLoading(true);
    try {
      const params: LoginParams = { username, password };
      const res = await loginApi(params);

      Notify.show({
        type: res.code === 200 ? 'success' : 'warning',
        message: res.msg || '登录失败',
      });

      if (res.code === 200) {
        const userInfo: UserInfo = {
          username,
          userId: res.data.userId,
          userEmail: res.data.userEmail,
          lover: res.data.lover,
          score: res.data.score,
        };

        localStorage.setItem('myUserInfo', JSON.stringify(userInfo));
        router.replace('/trick');
      }
    } catch {
      Notify.show({ type: 'warning', message: '登录失败，请重试' });
    } finally {
      setLoading(false);
    }
  };

  const handleAvatarClick = () => {
    setIsOpen(true);
  };

  const handleCloseRegister = () => {
    setIsOpen(false);
  };

  return (
    <>
      <Register openKey={isOpen} keyToFalse={handleCloseRegister} />
      <div className="login-2026 min-h-screen flex flex-col justify-center items-center px-4">
        {/* 2026 专属标识 */}
        <div className="login-2026__badge mb-2">
          <span className="login-2026__year">2026</span>
        </div>
        <p className="text-sm text-[var(--text-secondary)] mb-6">
          RomanceHub · 新岁共赴
        </p>

        <Avatar
          onClick={handleAvatarClick}
          isBordered
          color="primary"
          radius="full"
          src="/defaultAvatar.jpg"
          className="w-40 h-40 text-large cursor-pointer shrink-0"
        />
        <p className="text-xs text-[var(--text-muted)] mt-2 mb-1">
          点击头像注册新账号
        </p>

        <div className="flex w-full max-w-md flex-col gap-4 mt-6 mb-6">
          <Input
            type="text"
            label="昵称"
            placeholder="请输入昵称"
            value={username}
            onChange={handleUsernameChange}
            isRequired
            variant="bordered"
            classNames={{
              input: 'text-[var(--text-primary)]',
              inputWrapper: 'border-[var(--border-color)] hover:border-[var(--primary-color)]',
            }}
          />
          <Input
            type="password"
            label="密码"
            placeholder="请输入密码"
            value={password}
            onChange={handlePasswordChange}
            isRequired
            variant="bordered"
            classNames={{
              input: 'text-[var(--text-primary)]',
              inputWrapper: 'border-[var(--border-color)] hover:border-[var(--primary-color)]',
            }}
          />
        </div>
        <Button
          color="primary"
          size="lg"
          className="w-full max-w-md rounded-[var(--radius-lg)] font-medium shadow-[var(--shadow-md)]"
          onClick={login}
          isLoading={isLoading}
          isDisabled={!username || !password}
        >
          登录
        </Button>
      </div>
    </>
  );
}
