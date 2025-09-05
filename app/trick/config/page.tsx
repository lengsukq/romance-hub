'use client'
import React, { useEffect, useState } from 'react';
import {
    Card,
    CardBody,
    CardHeader,
    Button,
    Input,
    Textarea,
    Switch,
    Chip,
    Divider,
    Modal,
    ModalContent,
    ModalHeader,
    ModalBody,
    ModalFooter,
    useDisclosure,
    Avatar,
    Tabs,
    Tab
} from "@heroui/react";
import { Notify } from "@/utils/client/notificationUtils";
import { post } from "@/utils/client/fetchUtil";
import { getUserInfo, updateUserInfo } from "@/utils/client/apihttp";
import { imgUpload } from "@/utils/client/fileTools";

interface ImageBedConfig {
    id: string;
    bedName: string;
    bedType: string;
    apiUrl: string;
    apiKey?: string;
    authHeader?: string;
    isDefault: boolean;
    priority: number;
    description?: string;
    userEmail?: string; // 新增：用于标识是否是用户级别的配置
}

interface NotificationConfig {
    id: string;
    notifyType: string;
    notifyName: string;
    webhookUrl?: string;
    apiKey?: string;
    description?: string;
    userEmail?: string; // 新增：用于标识是否是用户级别的配置
}

interface SystemConfig {
    WEB_URL?: string;
}

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

export default function ConfigPage() {
    const [imageBeds, setImageBeds] = useState<ImageBedConfig[]>([]);
    const [notifications, setNotifications] = useState<NotificationConfig[]>([]);
    const [systemConfigs, setSystemConfigs] = useState<SystemConfig>({});
    const [loading, setLoading] = useState(false);
    
    // 用户信息
    const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
    const [editUserInfo, setEditUserInfo] = useState({
        username: '',
        avatar: '',
        describeBySelf: ''
    });
    
    // 图床配置编辑
    const { isOpen: isImageBedOpen, onOpen: onImageBedOpen, onClose: onImageBedClose } = useDisclosure();
    const [editingImageBed, setEditingImageBed] = useState<Partial<ImageBedConfig>>({});
    
    // 通知配置编辑
    const { isOpen: isNotificationOpen, onOpen: onNotificationOpen, onClose: onNotificationClose } = useDisclosure();
    const [editingNotification, setEditingNotification] = useState<Partial<NotificationConfig>>({});
    
    // 新增配置状态
    const [isAddingImageBed, setIsAddingImageBed] = useState(false);
    const [isAddingNotification, setIsAddingNotification] = useState(false);
    const [newImageBed, setNewImageBed] = useState<Partial<ImageBedConfig>>({});
    const [newNotification, setNewNotification] = useState<Partial<NotificationConfig>>({});
    


    useEffect(() => {
        loadConfigs();
        loadUserInfo();
    }, []);

    const loadUserInfo = async () => {
        try {
            const res = await getUserInfo();
            if (res.code === 200 && res.data) {
                setUserInfo(res.data);
                setEditUserInfo({
                    username: res.data.username || '',
                    avatar: res.data.avatar || '',
                    describeBySelf: res.data.describeBySelf || ''
                });
            }
        } catch (error) {
            console.error('获取用户信息失败:', error);
        }
    };

    const handleSaveUserInfo = async () => {
        try {
            const res = await updateUserInfo(editUserInfo);
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                loadUserInfo();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('更新用户信息失败:', error);
            Notify.show({ type: 'warning', message: '更新用户信息失败' });
        }
    };

    const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        try {
            const img = await imgUpload(event);
            setEditUserInfo(prev => ({...prev, avatar: img}));
        } catch (error) {
            console.error('Avatar upload failed:', error);
        }
    };

    const loadConfigs = async () => {
        setLoading(true);
        try {
            // 加载图床配置
            const imageBedRes = await post('/api/v1/config', {
                action: 'get_image_beds'
            });
            if (imageBedRes.code === 200) {
                setImageBeds(imageBedRes.data);
            }

            // 加载通知配置
            const notificationRes = await post('/api/v1/config', {
                action: 'get_notifications'
            });
            if (notificationRes.code === 200) {
                setNotifications(notificationRes.data);
            }

            // 加载系统配置
            const systemRes = await post('/api/v1/config', {
                action: 'get_system_configs'
            });
            if (systemRes.code === 200) {
                setSystemConfigs(systemRes.data);
            }
        } catch (error) {
            console.error('加载配置失败:', error);
            Notify.show({ type: 'warning', message: '加载配置失败' });
        } finally {
            setLoading(false);
        }
    };

    const handleInitializeConfigs = async () => {
        try {
            const res = await post('/api/v1/config', {
                action: 'initialize_configs'
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('初始化配置失败:', error);
            Notify.show({ type: 'warning', message: '初始化配置失败' });
        }
    };

    // 移除手动同步功能，因为现在是自动同步的
    // const handleSyncToLover = async () => { ... }

    const handleEditImageBed = (bed: ImageBedConfig) => {
        setEditingImageBed(bed);
        onImageBedOpen();
    };

    const handleSaveImageBed = async () => {
        try {
            if (!editingImageBed.bedName || !editingImageBed.bedType || !editingImageBed.apiUrl) {
                Notify.show({ type: 'warning', message: '请填写完整的图床配置信息' });
                return;
            }
            
            const res = await post('/api/v1/config', {
                action: 'update_image_bed',
                data: {
                    bedName: editingImageBed.bedName,
                    bedType: editingImageBed.bedType,
                    apiUrl: editingImageBed.apiUrl,
                    apiKey: editingImageBed.apiKey || '',
                    authHeader: editingImageBed.authHeader || '',
                    isDefault: editingImageBed.isDefault || false,
                    priority: editingImageBed.priority || 0,
                    description: editingImageBed.description || ''
                }
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                onImageBedClose();
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('保存图床配置失败:', error);
            Notify.show({ type: 'warning', message: '保存图床配置失败' });
        }
    };

    const handleEditNotification = (notification: NotificationConfig) => {
        setEditingNotification(notification);
        onNotificationOpen();
    };

    const handleSaveNotification = async () => {
        try {
            if (!editingNotification.notifyType || !editingNotification.notifyName) {
                Notify.show({ type: 'warning', message: '请填写完整的通知配置信息' });
                return;
            }
            
            const res = await post('/api/v1/config', {
                action: 'update_notification',
                data: {
                    notifyType: editingNotification.notifyType,
                    notifyName: editingNotification.notifyName,
                    webhookUrl: editingNotification.webhookUrl || '',
                    apiKey: editingNotification.apiKey || '',
                    description: editingNotification.description || ''
                }
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                onNotificationClose();
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('保存通知配置失败:', error);
            Notify.show({ type: 'warning', message: '保存通知配置失败' });
        }
    };

    const handleUpdateSystemConfig = async (key: string, value: string) => {
        try {
            const res = await post('/api/v1/config', {
                action: 'update_system_config',
                data: {
                    configKey: key,
                    configValue: value,
                    configType: 'other'
                }
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('更新系统配置失败:', error);
            Notify.show({ type: 'warning', message: '更新系统配置失败' });
        }
    };

    const handleAddImageBed = async () => {
        try {
            if (!newImageBed.bedName || !newImageBed.bedType || !newImageBed.apiUrl) {
                Notify.show({ type: 'warning', message: '请填写完整的图床配置信息' });
                return;
            }
            
            const res = await post('/api/v1/config', {
                action: 'update_image_bed',
                data: {
                    bedName: newImageBed.bedName,
                    bedType: newImageBed.bedType,
                    apiUrl: newImageBed.apiUrl,
                    apiKey: newImageBed.apiKey || '',
                    authHeader: newImageBed.authHeader || '',
                    isDefault: newImageBed.isDefault || false,
                    priority: newImageBed.priority || 0,
                    description: newImageBed.description || ''
                }
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                setIsAddingImageBed(false);
                setNewImageBed({});
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('添加图床配置失败:', error);
            Notify.show({ type: 'warning', message: '添加图床配置失败' });
        }
    };

    const handleAddNotification = async () => {
        try {
            if (!newNotification.notifyType || !newNotification.notifyName) {
                Notify.show({ type: 'warning', message: '请填写完整的通知配置信息' });
                return;
            }
            
            const res = await post('/api/v1/config', {
                action: 'update_notification',
                data: {
                    notifyType: newNotification.notifyType,
                    notifyName: newNotification.notifyName,
                    webhookUrl: newNotification.webhookUrl || '',
                    apiKey: newNotification.apiKey || '',
                    description: newNotification.description || ''
                }
            });
            if (res.code === 200) {
                Notify.show({ type: 'success', message: res.msg });
                setIsAddingNotification(false);
                setNewNotification({});
                loadConfigs();
            } else {
                Notify.show({ type: 'warning', message: res.msg });
            }
        } catch (error) {
            console.error('添加通知配置失败:', error);
            Notify.show({ type: 'warning', message: '添加通知配置失败' });
        }
    };

    return (
        <div className="p-5 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold">系统配置管理</h1>
                <Button color="primary" onClick={handleInitializeConfigs}>
                    初始化默认配置
                </Button>
            </div>

            <div className="bg-blue-50 border border-blue-200 rounded-lg p-4 mb-6">
                <h3 className="text-lg font-semibold text-blue-800 mb-2">配置说明</h3>
                <p className="text-blue-700 text-sm">
                    • 配置会自动与关联者保持一致<br/>
                    • 当您修改配置时，关联者的配置会自动同步更新<br/>
                    • 确保情侣双方始终使用相同的配置
                </p>
            </div>

            <Tabs aria-label="配置管理">
                <Tab key="user-info" title="信息编辑">
                    <div className="space-y-6">
                        {/* 个人信息编辑 */}
                        <Card>
                            <CardHeader>
                                <h3 className="text-lg font-semibold">个人信息编辑</h3>
                            </CardHeader>
                            <CardBody>
                                {userInfo && (
                                    <div className="space-y-4">
                                        {/* 头像上传 */}
                                        <div className="flex justify-center">
                                            <div className="text-center">
                                                <input 
                                                    type="file" 
                                                    name="file" 
                                                    className="hidden" 
                                                    id="editUpload"
                                                    onChange={upAvatar}
                                                />
                                                <label htmlFor="editUpload" className="cursor-pointer">
                                                    <Avatar 
                                                        isBordered 
                                                        src={editUserInfo.avatar} 
                                                        className="w-24 h-24 text-large"
                                                    />
                                                </label>
                                                <p className="text-sm text-gray-500 mt-2">点击头像更换</p>
                                            </div>
                                        </div>
                                        
                                        {/* 用户信息表单 */}
                                        <div className="space-y-4">
                                            <Input
                                                value={editUserInfo.username}
                                                onChange={(e) => setEditUserInfo(prev => ({...prev, username: e.target.value}))}
                                                label="昵称"
                                                placeholder="请输入昵称"
                                            />
                                            
                                            <Input
                                                value={editUserInfo.describeBySelf}
                                                onChange={(e) => setEditUserInfo(prev => ({...prev, describeBySelf: e.target.value}))}
                                                label="个人描述"
                                                placeholder="请输入个人描述"
                                            />
                                            
                                            <div className="flex items-center gap-4 text-sm text-gray-500">
                                                <span>❤️ {userInfo.score}</span>
                                                <span>注册时间: {userInfo.registrationTime}</span>
                                            </div>
                                            
                                            <Button 
                                                color="primary" 
                                                onClick={handleSaveUserInfo}
                                                className="w-full"
                                            >
                                                保存修改
                                            </Button>
                                        </div>
                                    </div>
                                )}
                            </CardBody>
                        </Card>
                    </div>
                </Tab>

                <Tab key="system-config" title="配置编辑">
                    <div className="space-y-6">
                        {/* 图床配置 */}
                        <Card>
                            <CardHeader className="flex justify-between items-center">
                                <h3 className="text-lg font-semibold">图床配置</h3>
                                <Button 
                                    size="sm" 
                                    color="primary" 
                                    onClick={() => setIsAddingImageBed(!isAddingImageBed)}
                                >
                                    {isAddingImageBed ? '取消' : '添加图床'}
                                </Button>
                            </CardHeader>
                            <CardBody>
                                <div className="space-y-4">
                                    {/* 新增图床配置表单 */}
                                    {isAddingImageBed && (
                                        <div className="border-2 border-dashed border-blue-200 rounded-lg p-4 bg-blue-50">
                                            <h4 className="font-semibold text-blue-800 mb-3">新增图床配置</h4>
                                            <div className="space-y-3">
                                                <Input
                                                    label="图床名称"
                                                    value={newImageBed.bedName || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, bedName: e.target.value }))}
                                                    placeholder="如: SM, IMGBB"
                                                />
                                                <Input
                                                    label="图床类型"
                                                    value={newImageBed.bedType || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, bedType: e.target.value }))}
                                                    placeholder="如: smms, imgbb"
                                                />
                                                <Input
                                                    label="API地址"
                                                    value={newImageBed.apiUrl || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, apiUrl: e.target.value }))}
                                                    placeholder="图床API地址"
                                                />
                                                <Input
                                                    label="API密钥"
                                                    value={newImageBed.apiKey || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, apiKey: e.target.value }))}
                                                    placeholder="API密钥（可选）"
                                                />
                                                <Input
                                                    label="认证头"
                                                    value={newImageBed.authHeader || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, authHeader: e.target.value }))}
                                                    placeholder="认证头名称（可选）"
                                                />
                                                <Input
                                                    label="优先级"
                                                    type="number"
                                                    value={(newImageBed.priority || 0).toString()}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, priority: parseInt(e.target.value) }))}
                                                />
                                                <Textarea
                                                    label="描述"
                                                    value={newImageBed.description || ''}
                                                    onChange={(e) => setNewImageBed(prev => ({ ...prev, description: e.target.value }))}
                                                    placeholder="图床描述"
                                                />
                                                                                                 <div className="flex gap-4">
                                                     <Switch
                                                         isSelected={newImageBed.isDefault}
                                                         onValueChange={(value) => setNewImageBed(prev => ({ ...prev, isDefault: value }))}
                                                     >
                                                         设为默认
                                                     </Switch>
                                                 </div>
                                                <div className="flex gap-2">
                                                    <Button 
                                                        color="primary" 
                                                        onClick={handleAddImageBed}
                                                        className="flex-1"
                                                    >
                                                        添加图床
                                                    </Button>
                                                    <Button 
                                                        variant="flat" 
                                                        onClick={() => {
                                                            setIsAddingImageBed(false);
                                                            setNewImageBed({});
                                                        }}
                                                        className="flex-1"
                                                    >
                                                        取消
                                                    </Button>
                                                </div>
                                            </div>
                                        </div>
                                    )}
                                    
                                    {/* 现有图床配置列表 */}
                                    {imageBeds.map((bed) => (
                                        <div key={bed.id} className="border rounded-lg p-4">
                                            <div className="flex justify-between items-start">
                                                <div className="flex-1">
                                                                                                     <div className="flex items-center gap-2 mb-2">
                                                     <h4 className="font-semibold">{bed.bedName}</h4>
                                                     {bed.isDefault && <Chip color="primary" size="sm">默认</Chip>}
                                                 </div>
                                                    <p className="text-sm text-gray-600 mb-2">{bed.description}</p>
                                                    <p className="text-sm text-gray-500">API: {bed.apiUrl}</p>
                                                    <p className="text-sm text-gray-500">类型: {bed.bedType}</p>
                                                    <p className="text-sm text-gray-500">优先级: {bed.priority}</p>
                                                </div>
                                                <Button size="sm" onClick={() => handleEditImageBed(bed)}>
                                                    编辑
                                                </Button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </CardBody>
                        </Card>

                        {/* 通知配置 */}
                        <Card>
                            <CardHeader className="flex justify-between items-center">
                                <h3 className="text-lg font-semibold">通知配置</h3>
                                <Button 
                                    size="sm" 
                                    color="primary" 
                                    onClick={() => setIsAddingNotification(!isAddingNotification)}
                                >
                                    {isAddingNotification ? '取消' : '添加通知'}
                                </Button>
                            </CardHeader>
                            <CardBody>
                                <div className="space-y-4">
                                    {/* 新增通知配置表单 */}
                                    {isAddingNotification && (
                                        <div className="border-2 border-dashed border-green-200 rounded-lg p-4 bg-green-50">
                                            <h4 className="font-semibold text-green-800 mb-3">新增通知配置</h4>
                                            <div className="space-y-3">
                                                <Input
                                                    label="通知类型"
                                                    value={newNotification.notifyType || ''}
                                                    onChange={(e) => setNewNotification(prev => ({ ...prev, notifyType: e.target.value }))}
                                                    placeholder="如: wx_robot, email"
                                                />
                                                <Input
                                                    label="通知名称"
                                                    value={newNotification.notifyName || ''}
                                                    onChange={(e) => setNewNotification(prev => ({ ...prev, notifyName: e.target.value }))}
                                                    placeholder="通知名称"
                                                />
                                                <Input
                                                    label="Webhook地址"
                                                    value={newNotification.webhookUrl || ''}
                                                    onChange={(e) => setNewNotification(prev => ({ ...prev, webhookUrl: e.target.value }))}
                                                    placeholder="Webhook地址（可选）"
                                                />
                                                <Input
                                                    label="API密钥"
                                                    value={newNotification.apiKey || ''}
                                                    onChange={(e) => setNewNotification(prev => ({ ...prev, apiKey: e.target.value }))}
                                                    placeholder="API密钥（可选）"
                                                />
                                                <Textarea
                                                    label="描述"
                                                    value={newNotification.description || ''}
                                                    onChange={(e) => setNewNotification(prev => ({ ...prev, description: e.target.value }))}
                                                    placeholder="通知描述"
                                                />
                                                
                                                <div className="flex gap-2">
                                                    <Button 
                                                        color="primary" 
                                                        onClick={handleAddNotification}
                                                        className="flex-1"
                                                    >
                                                        添加通知
                                                    </Button>
                                                    <Button 
                                                        variant="flat" 
                                                        onClick={() => {
                                                            setIsAddingNotification(false);
                                                            setNewNotification({});
                                                        }}
                                                        className="flex-1"
                                                    >
                                                        取消
                                                    </Button>
                                                </div>
                                            </div>
                                        </div>
                                    )}
                                    
                                    {/* 现有通知配置列表 */}
                                    {notifications.map((notification) => (
                                        <div key={notification.id} className="border rounded-lg p-4">
                                            <div className="flex justify-between items-start">
                                                <div className="flex-1">
                                                                                                     <div className="flex items-center gap-2 mb-2">
                                                     <h4 className="font-semibold">{notification.notifyName}</h4>
                                                 </div>
                                                    <p className="text-sm text-gray-600 mb-2">{notification.description}</p>
                                                    <p className="text-sm text-gray-500">类型: {notification.notifyType}</p>
                                                    {notification.webhookUrl && (
                                                        <p className="text-sm text-gray-500">Webhook: {notification.webhookUrl}</p>
                                                    )}
                                                </div>
                                                <Button size="sm" onClick={() => handleEditNotification(notification)}>
                                                    编辑
                                                </Button>
                                            </div>
                                        </div>
                                    ))}
                                </div>
                            </CardBody>
                        </Card>

                        {/* 系统配置 */}
                        <Card>
                            <CardHeader>
                                <h3 className="text-lg font-semibold">系统配置</h3>
                            </CardHeader>
                            <CardBody>
                                <div className="space-y-4">
                                    <div>
                                        <label className="block text-sm font-medium mb-2">网站URL</label>
                                        <div className="flex gap-2">
                                            <Input
                                                value={systemConfigs.WEB_URL || ''}
                                                onChange={(e) => setSystemConfigs(prev => ({ ...prev, WEB_URL: e.target.value }))}
                                                placeholder="请输入网站URL"
                                            />
                                            <Button 
                                                size="sm" 
                                                onClick={() => handleUpdateSystemConfig('WEB_URL', systemConfigs.WEB_URL || '')}
                                            >
                                                保存
                                            </Button>
                                        </div>
                                    </div>
                                </div>
                            </CardBody>
                        </Card>
                    </div>
                </Tab>
            </Tabs>

            {/* 图床配置编辑模态框 */}
            <Modal isOpen={isImageBedOpen} onClose={onImageBedClose} size="lg">
                <ModalContent>
                    <ModalHeader>编辑图床配置</ModalHeader>
                    <ModalBody>
                        <div className="space-y-4">
                            <Input
                                label="图床名称"
                                value={editingImageBed.bedName || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, bedName: e.target.value }))}
                                placeholder="如: SM, IMGBB"
                            />
                            <Input
                                label="图床类型"
                                value={editingImageBed.bedType || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, bedType: e.target.value }))}
                                placeholder="如: smms, imgbb"
                            />
                            <Input
                                label="API地址"
                                value={editingImageBed.apiUrl || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, apiUrl: e.target.value }))}
                                placeholder="图床API地址"
                            />
                            <Input
                                label="API密钥"
                                value={editingImageBed.apiKey || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, apiKey: e.target.value }))}
                                placeholder="API密钥（可选）"
                            />
                            <Input
                                label="认证头"
                                value={editingImageBed.authHeader || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, authHeader: e.target.value }))}
                                placeholder="认证头名称（可选）"
                            />
                            <Input
                                label="优先级"
                                type="number"
                                value={(editingImageBed.priority || 0).toString()}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, priority: parseInt(e.target.value) }))}
                            />
                            <Textarea
                                label="描述"
                                value={editingImageBed.description || ''}
                                onChange={(e) => setEditingImageBed(prev => ({ ...prev, description: e.target.value }))}
                                placeholder="图床描述"
                            />
                                                         <div className="flex gap-4">
                                 <Switch
                                     isSelected={editingImageBed.isDefault}
                                     onValueChange={(value) => setEditingImageBed(prev => ({ ...prev, isDefault: value }))}
                                 >
                                     设为默认
                                 </Switch>
                             </div>
                        </div>
                    </ModalBody>
                    <ModalFooter>
                        <Button variant="flat" onPress={onImageBedClose}>
                            取消
                        </Button>
                        <Button color="primary" onPress={handleSaveImageBed}>
                            保存
                        </Button>
                    </ModalFooter>
                </ModalContent>
            </Modal>

            {/* 通知配置编辑模态框 */}
            <Modal isOpen={isNotificationOpen} onClose={onNotificationClose} size="lg">
                <ModalContent>
                    <ModalHeader>编辑通知配置</ModalHeader>
                    <ModalBody>
                        <div className="space-y-4">
                            <Input
                                label="通知类型"
                                value={editingNotification.notifyType || ''}
                                onChange={(e) => setEditingNotification(prev => ({ ...prev, notifyType: e.target.value }))}
                                placeholder="如: wx_robot, email"
                            />
                            <Input
                                label="通知名称"
                                value={editingNotification.notifyName || ''}
                                onChange={(e) => setEditingNotification(prev => ({ ...prev, notifyName: e.target.value }))}
                                placeholder="通知名称"
                            />
                            <Input
                                label="Webhook地址"
                                value={editingNotification.webhookUrl || ''}
                                onChange={(e) => setEditingNotification(prev => ({ ...prev, webhookUrl: e.target.value }))}
                                placeholder="Webhook地址（可选）"
                            />
                            <Input
                                label="API密钥"
                                value={editingNotification.apiKey || ''}
                                onChange={(e) => setEditingNotification(prev => ({ ...prev, apiKey: e.target.value }))}
                                placeholder="API密钥（可选）"
                            />
                            <Textarea
                                label="描述"
                                value={editingNotification.description || ''}
                                onChange={(e) => setEditingNotification(prev => ({ ...prev, description: e.target.value }))}
                                placeholder="通知描述"
                            />
                            
                        </div>
                    </ModalBody>
                    <ModalFooter>
                        <Button variant="flat" onPress={onNotificationClose}>
                            取消
                        </Button>
                        <Button color="primary" onPress={handleSaveNotification}>
                            保存
                        </Button>
                    </ModalFooter>
                                 </ModalContent>
             </Modal>


         </div>
     );
 }
