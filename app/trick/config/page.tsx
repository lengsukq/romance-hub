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
    Tabs,
    Tab
} from "@heroui/react";
import { Notify } from "@/utils/client/notificationUtils";
import { post } from "@/utils/client/fetchUtil";

interface ImageBedConfig {
    id: string;
    bedName: string;
    bedType: string;
    apiUrl: string;
    apiKey?: string;
    authHeader?: string;
    isActive: boolean;
    isDefault: boolean;
    priority: number;
    description?: string;
}

interface NotificationConfig {
    id: string;
    notifyType: string;
    notifyName: string;
    webhookUrl?: string;
    apiKey?: string;
    isActive: boolean;
    description?: string;
}

interface SystemConfig {
    WEB_URL?: string;
}

export default function ConfigPage() {
    const [imageBeds, setImageBeds] = useState<ImageBedConfig[]>([]);
    const [notifications, setNotifications] = useState<NotificationConfig[]>([]);
    const [systemConfigs, setSystemConfigs] = useState<SystemConfig>({});
    const [loading, setLoading] = useState(false);
    
    // 图床配置编辑
    const { isOpen: isImageBedOpen, onOpen: onImageBedOpen, onClose: onImageBedClose } = useDisclosure();
    const [editingImageBed, setEditingImageBed] = useState<Partial<ImageBedConfig>>({});
    
    // 通知配置编辑
    const { isOpen: isNotificationOpen, onOpen: onNotificationOpen, onClose: onNotificationClose } = useDisclosure();
    const [editingNotification, setEditingNotification] = useState<Partial<NotificationConfig>>({});

    useEffect(() => {
        loadConfigs();
    }, []);

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

    const handleEditImageBed = (bed: ImageBedConfig) => {
        setEditingImageBed(bed);
        onImageBedOpen();
    };

    const handleSaveImageBed = async () => {
        try {
            const res = await post('/api/v1/config', {
                action: 'update_image_bed',
                data: editingImageBed
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
            const res = await post('/api/v1/config', {
                action: 'update_notification',
                data: editingNotification
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

    return (
        <div className="p-5 space-y-6">
            <div className="flex justify-between items-center">
                <h1 className="text-2xl font-bold">系统配置管理</h1>
                <Button color="primary" onClick={handleInitializeConfigs}>
                    初始化默认配置
                </Button>
            </div>

            <Tabs aria-label="配置管理">
                <Tab key="image-beds" title="图床配置">
                    <Card>
                        <CardHeader>
                            <h3 className="text-lg font-semibold">图床配置</h3>
                        </CardHeader>
                        <CardBody>
                            <div className="space-y-4">
                                {imageBeds.map((bed) => (
                                    <div key={bed.id} className="border rounded-lg p-4">
                                        <div className="flex justify-between items-start">
                                            <div className="flex-1">
                                                <div className="flex items-center gap-2 mb-2">
                                                    <h4 className="font-semibold">{bed.bedName}</h4>
                                                    {bed.isDefault && <Chip color="primary" size="sm">默认</Chip>}
                                                    <Chip color={bed.isActive ? "success" : "default"} size="sm">
                                                        {bed.isActive ? "启用" : "禁用"}
                                                    </Chip>
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
                </Tab>

                <Tab key="notifications" title="通知配置">
                    <Card>
                        <CardHeader>
                            <h3 className="text-lg font-semibold">通知配置</h3>
                        </CardHeader>
                        <CardBody>
                            <div className="space-y-4">
                                {notifications.map((notification) => (
                                    <div key={notification.id} className="border rounded-lg p-4">
                                        <div className="flex justify-between items-start">
                                            <div className="flex-1">
                                                <div className="flex items-center gap-2 mb-2">
                                                    <h4 className="font-semibold">{notification.notifyName}</h4>
                                                    <Chip color={notification.isActive ? "success" : "default"} size="sm">
                                                        {notification.isActive ? "启用" : "禁用"}
                                                    </Chip>
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
                </Tab>

                <Tab key="system" title="系统配置">
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
                                value={editingImageBed.priority || 0}
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
                                    isSelected={editingImageBed.isActive}
                                    onValueChange={(value) => setEditingImageBed(prev => ({ ...prev, isActive: value }))}
                                >
                                    启用
                                </Switch>
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
                            <Switch
                                isSelected={editingNotification.isActive}
                                onValueChange={(value) => setEditingNotification(prev => ({ ...prev, isActive: value }))}
                            >
                                启用
                            </Switch>
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
