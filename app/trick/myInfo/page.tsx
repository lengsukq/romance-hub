'use client'
import React from "react";
import { useRouter } from "next/navigation";
import {
  Avatar,
  Button,
  Card,
  CardBody,
  CardHeader,
  Divider,
  Input,
  Modal,
  ModalBody,
  ModalContent,
  ModalFooter,
  ModalHeader,
  useDisclosure,
} from "@heroui/react";
import { logoutApi, updateUserInfo } from "@/utils/client/apihttp";
import { Notify } from "@/utils/client/notificationUtils";
import { imgUpload } from "@/utils/client/fileTools";
import UserInfoCard from "@/components/userInfoCard";
import { useUserAndLoverInfo } from "./hooks/useUserAndLoverInfo";

export default function App() {
  const router = useRouter();
  const { isOpen, onOpen, onClose } = useDisclosure();
  const { isLoading, userInfo, loverInfo, editUserInfo, setEditUserInfo, reload } = useUserAndLoverInfo();

  const logoutAct = async () => {
    const res = await logoutApi();
    Notify.show({ type: res.code === 200 ? "success" : "warning", message: `${res.msg}` });
    if (res.code === 200) router.push("/");
  };

  const updateUserInfoAct = async () => {
    const res = await updateUserInfo(editUserInfo);
    Notify.show({ type: res.code === 200 ? "success" : "warning", message: `${res.msg}` });
    if (res.code === 200) {
      await reload();
      onClose();
    }
  };

  const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
    try {
      const img = await imgUpload(event);
      setEditUserInfo({ ...editUserInfo, avatar: img });
    } catch (error) {
      console.error("Avatar upload failed:", error);
    }
  };

  if (isLoading || !userInfo) {
    return <div className="p-5">Loading...</div>;
  }

  return (
    <div className="p-5">
      <div className="mb-4">
        <p className="text-2xl font-semibold text-default-700">吾心</p>
        <p className="text-xs text-default-400">与良人共用 · 通知与图床等设置皆在此处</p>
      </div>

      <Card isPressable onPress={() => router.push("/trick/config")} className="mb-5">
        <CardHeader className="justify-between">
          <div className="flex flex-col">
            <p className="text-base font-semibold text-default-700">设置</p>
            <p className="text-xs text-default-400">通知 / 图床等配置</p>
          </div>
          <Button size="sm" variant="bordered" onPress={() => router.push("/trick/config")}>
            前往
          </Button>
        </CardHeader>
      </Card>

      <Divider className="my-4" />

      <div className="mb-2 flex items-center justify-between">
        <p className="text-sm font-semibold text-default-700">吾之信息</p>
        <Button size="sm" variant="light" onPress={onOpen}>
          编辑
        </Button>
      </div>
      <UserInfoCard userInfo={userInfo} hideAction={true} />

      <Divider className="my-4" />

      <p className="mb-2 text-sm font-semibold text-default-700">良人信息</p>
      {loverInfo ? (
        <UserInfoCard userInfo={loverInfo} isLover={true} />
      ) : (
        <Card className="mb-5">
          <CardHeader>
            <p className="text-base font-semibold text-default-700">未见良人</p>
          </CardHeader>
          <CardBody>
            <div className="text-center text-default-500">
              <p>良人尚未入阁，或其信息暂不可得。</p>
              <p className="text-sm mt-2">良人邮箱：{userInfo.lover}</p>
            </div>
          </CardBody>
        </Card>
      )}

      <Card className="mt-5">
        <CardHeader>
          <p className="text-base font-semibold text-default-700">离阁</p>
        </CardHeader>
        <CardBody>
          <Button color="danger" variant="flat" onClick={logoutAct} className="w-full">
            退出
          </Button>
        </CardBody>
      </Card>

      <Modal isOpen={isOpen} onClose={onClose} size="lg">
        <ModalContent>
          <ModalHeader>编辑吾之信息</ModalHeader>
          <ModalBody>
            <div className="w-full flex justify-center mb-4">
              <input type="file" name="file" className="hidden" id="editUpload" onChange={upAvatar} />
              <label htmlFor="editUpload">
                <Avatar isBordered src={editUserInfo.avatar} className="w-20 h-20 text-large cursor-pointer" />
              </label>
            </div>

            <Input
              value={editUserInfo.username}
              onChange={(e) => setEditUserInfo({ ...editUserInfo, username: e.target.value })}
              label="用户名"
              placeholder="请输入用户名"
              className="mb-3"
            />

            <Input
              value={editUserInfo.describeBySelf}
              onChange={(e) => setEditUserInfo({ ...editUserInfo, describeBySelf: e.target.value })}
              label="一言"
              placeholder="写一句，寄此心"
            />
          </ModalBody>
          <ModalFooter>
            <Button variant="flat" onPress={onClose}>
              取消
            </Button>
            <Button color="primary" onPress={updateUserInfoAct}>
              保存
            </Button>
          </ModalFooter>
        </ModalContent>
      </Modal>
    </div>
  );
}
