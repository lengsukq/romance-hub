'use client'

import { useCallback, useEffect, useState } from 'react';
import { getUserInfo } from '@/utils/client/apihttp';
import { post } from '@/utils/client/fetchUtil';
import type { EditUserInfo, LoverInfo, UserInfo } from '../types';

interface UseUserAndLoverInfoResult {
  isLoading: boolean;
  userInfo: UserInfo | null;
  loverInfo: LoverInfo | null;
  editUserInfo: EditUserInfo;
  setEditUserInfo: (next: EditUserInfo) => void;
  reload: () => Promise<void>;
}

const EMPTY_EDIT: EditUserInfo = {
  username: '',
  avatar: '',
  describeBySelf: '',
};

export function useUserAndLoverInfo(): UseUserAndLoverInfoResult {
  const [isLoading, setIsLoading] = useState(true);
  const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
  const [loverInfo, setLoverInfo] = useState<LoverInfo | null>(null);
  const [editUserInfo, setEditUserInfo] = useState<EditUserInfo>(EMPTY_EDIT);

  const reload = useCallback(async () => {
    setIsLoading(true);
    try {
      const res = await getUserInfo();
      if (res.code === 200 && res.data) {
        const u = res.data as UserInfo;
        setUserInfo(u);
        setEditUserInfo({
          username: u.username || '',
          avatar: u.avatar || '',
          describeBySelf: u.describeBySelf || '',
        });

        // 获取良人信息
        const loverRes = await post('/api/v1/user', { action: 'lover' });
        if (loverRes.code === 200 && loverRes.data) {
          setLoverInfo(loverRes.data as LoverInfo);
        } else {
          setLoverInfo(null);
        }
      } else {
        setUserInfo(null);
        setLoverInfo(null);
      }
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    void reload();
  }, [reload]);

  return {
    isLoading,
    userInfo,
    loverInfo,
    editUserInfo,
    setEditUserInfo,
    reload,
  };
}

