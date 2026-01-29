'use client'
import React, {useEffect, useState} from "react";
import {getUserInfo, logoutApi, updateUserInfo} from "@/utils/client/apihttp";
import {
    Avatar,
    Button,
    Card,
    CardBody,
    CardFooter,
    CardHeader,
    Chip,
    Divider,
    Input,
    Modal,
    ModalBody,
    ModalContent,
    ModalFooter,
    ModalHeader,
    useDisclosure
} from "@heroui/react";
import {Notify} from "@/utils/client/notificationUtils";
import {useRouter} from "next/navigation";
import {imgUpload} from "@/utils/client/fileTools";
import UserInfoCard from "@/components/userInfoCard";
import {post} from "@/utils/client/fetchUtil";

interface UserInfo {
    userId: number;
    userEmail: string;
    username: string;
    avatar: string;
    lover: string;
    describeBySelf: string;
    score: number;
    registrationTime: string;
}

interface LoverInfo {
    username: string;
    avatar: string;
    userEmail: string;
    describeBySelf: string;
    score: number;
    registrationTime: string;
}

export default function App() {
    const router = useRouter();
    const {isOpen, onOpen, onClose} = useDisclosure();
    
    const handleConfigClick = () => {
        router.push('/trick/config');
    };
    
    const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
    const [loverInfo, setLoverInfo] = useState<LoverInfo | null>(null);
    const [editUserInfo, setEditUserInfo] = useState({
        username: '',
        avatar: '',
        describeBySelf: ''
    });

    useEffect(() => {
        getUserInfoAct();
    }, [])

    const getUserInfoAct = async () => {
        await getUserInfo().then(res => {
            if (res.code === 200 && res.data) {
                setUserInfo(res.data);
                setEditUserInfo({
                    username: res.data.username || '',
                    avatar: res.data.avatar || '',
                    describeBySelf: res.data.describeBySelf || ''
                });
                
                // 获取关联者信息
                getLoverInfoAct();
            } else {
                console.error('获取用户信息失败:', res);
                Notify.show({type: 'warning', message: '获取用户信息失败'});
            }
        }).catch(error => {
            console.error('API调用失败:', error);
            Notify.show({type: 'warning', message: '网络请求失败'});
        })
    }

    const getLoverInfoAct = async () => {
        try {
            const res = await post('/api/v1/user', {
                action: 'lover'
            });
            if (res.code === 200 && res.data) {
                setLoverInfo(res.data);
            } else {
                console.log('未找到关联者信息或关联者未注册');
                setLoverInfo(null);
            }
        } catch (error) {
            console.error('获取关联者信息失败:', error);
            setLoverInfo(null);
        }
    }

    const logoutAct = async () => {
        await logoutApi().then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                router.push('/');
            }
        })
    }

    const updateUserInfoAct = async () => {
        await updateUserInfo(editUserInfo).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getUserInfoAct();
                onClose();
            }
        })
    }

    const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        try {
            const img = await imgUpload(event);
            setEditUserInfo(prev => ({...prev, avatar: img}));
        } catch (error) {
            console.error('Avatar upload failed:', error);
        }
    }

    if (!userInfo) {
        return <div className="p-5">Loading...</div>;
    }

    return (
        <div className={"p-5"}>
            <UserInfoCard userInfo={userInfo} onOpen={handleConfigClick} />
            
            <Divider className="my-4" />
            
            {loverInfo ? (
                <UserInfoCard 
                    userInfo={loverInfo} 
                    onOpen={() => {}} 
                    isLover={true} 
                />
            ) : (
                <Card className="mb-5">
                    <CardHeader>
                        <h4 className="font-bold text-large">关联者信息</h4>
                    </CardHeader>
                    <CardBody>
                        <div className="text-center text-gray-500">
                            <p>关联者账号尚未注册或信息不可用</p>
                            <p className="text-sm mt-2">关联邮箱: {userInfo.lover}</p>
                        </div>
                    </CardBody>
                </Card>
            )}

            <Card className="mt-5">
                <CardHeader>
                    <h4 className="font-bold text-large">操作</h4>
                </CardHeader>
                <CardBody>
                    <Button 
                        color="danger" 
                        variant="flat" 
                        onClick={logoutAct}
                        className="w-full"
                    >
                        退出登录
                    </Button>
                </CardBody>
            </Card>

            {/* Edit Modal */}
            <Modal isOpen={isOpen} onClose={onClose} size="lg">
                <ModalContent>
                    <ModalHeader>编辑个人信息</ModalHeader>
                    <ModalBody>
                        <div className={"w-full flex justify-center mb-4"}>
                            <input 
                                type="file" 
                                name="file" 
                                className={"hidden"} 
                                id="editUpload"
                                onChange={upAvatar}
                            />
                            <label htmlFor="editUpload">
                                <Avatar 
                                    isBordered 
                                    src={editUserInfo.avatar} 
                                    className="w-20 h-20 text-large cursor-pointer"
                                />
                            </label>
                        </div>
                        
                        <Input
                            value={editUserInfo.username}
                            onChange={(e) => setEditUserInfo(prev => ({...prev, username: e.target.value}))}
                            label="昵称"
                            placeholder="请输入昵称"
                            className="mb-3"
                        />
                        
                        <Input
                            value={editUserInfo.describeBySelf}
                            onChange={(e) => setEditUserInfo(prev => ({...prev, describeBySelf: e.target.value}))}
                            label="个人描述"
                            placeholder="请输入个人描述"
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
