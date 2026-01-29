import {
    Avatar,
    Button,
    Input,
    Modal,
    ModalBody,
    ModalContent,
    ModalFooter,
    ModalHeader,
    useDisclosure
} from "@heroui/react";
import {useEffect, useState} from "react";
import {imgUpload} from "@/utils/client/fileTools";
import {eMailInvalidFn, isInvalidFn, sameInvalidFn} from "@/utils/client/dataTools";
import {userRegister} from "@/utils/client/apihttp";
import {Notify} from "@/utils/client/notificationUtils";

interface RegisterProps {
    openKey: boolean;
    keyToFalse: () => void;
    onKeyDown?: () => void;
}

export default function Register ({openKey, keyToFalse, onKeyDown = () => ''}: RegisterProps) {
    const {isOpen, onOpen, onClose, onOpenChange} = useDisclosure();
    const [avatar, setAvatar] = useState('')
    const [userEmail, setUserEmail] = useState('')
    const [username, setUsername] = useState('')
    const [password, setPassword] = useState('')
    const [password2, setPassword2] = useState('')
    const [describeBySelf, setDescribeBySelf] = useState('')
    const [lover, setLover] = useState('')
    
    // 关联者信息
    const [loverAvatar, setLoverAvatar] = useState('')
    const [loverUsername, setLoverUsername] = useState('')
    const [loverDescribeBySelf, setLoverDescribeBySelf] = useState('')

    // 添加touched状态追踪用户是否与字段交互过
    const [touched, setTouched] = useState({
        username: false,
        userEmail: false,
        lover: false,
        describeBySelf: false,
        password: false,
        password2: false,
        loverUsername: false,
        loverDescribeBySelf: false
    })

    const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const img = await imgUpload(event);
        setAvatar(img);
    }

    const upLoverAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const img = await imgUpload(event);
        setLoverAvatar(img);
    }

    // 处理字段的blur事件（失去焦点时标记为touched）
    const handleBlur = (fieldName: keyof typeof touched) => {
        setTouched(prev => ({
            ...prev,
            [fieldName]: true
        }));
    }

    // 检查是否应该显示验证错误（只有在touched后才显示）
    const shouldShowError = (fieldName: keyof typeof touched, isInvalid: boolean) => {
        return touched[fieldName] && isInvalid;
    }

    useEffect(() => {
        if (openKey) {
            onOpen();
        } else {
            onClose();
        }
    }, [openKey])
    
    const [isLoading, setLoading] = useState(false)
    const userRegisterAct = async () => {
        // 验证所有必填字段
        if (isInvalidFn(username) || isInvalidFn(password) || isInvalidFn(describeBySelf) || 
            eMailInvalidFn(userEmail) || eMailInvalidFn(lover) || sameInvalidFn(password, password2) ||
            isInvalidFn(loverUsername) || isInvalidFn(loverDescribeBySelf)){
            Notify.show({type: 'warning', message: '请填写完整的注册信息'})
            return
        }
        setLoading(true)
        // 构建双账号注册数据
        const registerData = {
            // 主账号信息
            avatar,
            userEmail,
            username,
            password,
            describeBySelf,
            // 关联者信息  
            lover,
            loverAvatar,
            loverUsername,
            loverDescribeBySelf
        }
        await userRegister(registerData).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                onClose();
            }
            setLoading(false)
        })
    }

    return (
        <>
            <Modal
                classNames={{
                    body: "pb-0 overflow-y-auto max-h-[70vh] sm:max-h-[80vh]",
                    base: "max-h-[85vh] sm:max-h-[90vh] w-[95vw] sm:w-auto",
                    wrapper: "items-start pt-5 sm:pt-10"
                }}
                size="2xl"
                hideCloseButton={true}
                placement={"center"}
                isOpen={isOpen}
                onClose={onClose}
                onOpenChange={keyToFalse}>
                <ModalContent>
                    {(onClose) => (
                        <>
                            <ModalHeader className="flex flex-col gap-1">
                                <h3>双账号注册</h3>
                                <p className="text-sm text-gray-500 font-normal">
                                    将同时为您和关联者创建账号，两个账号使用相同密码，便于情侣间互动使用
                                </p>
                            </ModalHeader>
                            <ModalBody className="overflow-y-auto px-4">
                                {/* 主账号信息 */}
                                <div className="space-y-4">
                                    <h4 className="text-md font-semibold text-primary">主账号信息</h4>
                                    <div className={"w-full flex justify-center"}>
                                        <input type="file" name="file" className={"hidden"} id="upload"
                                               onChange={upAvatar}/>
                                        <label htmlFor="upload">
                                            <Avatar isBordered src={avatar} className="w-20 h-20 text-large cursor-pointer"/>
                                        </label>
                                    </div>
                                    <Input
                                        isInvalid={shouldShowError('username', isInvalidFn(username))}
                                        color={shouldShowError('username', isInvalidFn(username)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('username', isInvalidFn(username)) && "请输入昵称"}
                                        value={username}
                                        onChange={(e) => setUsername(e.target.value)}
                                        onBlur={() => handleBlur('username')}
                                        autoFocus
                                        label="昵称"
                                        placeholder="请输入昵称"
                                        variant="bordered"
                                    />
                                    <Input
                                        isInvalid={shouldShowError('userEmail', eMailInvalidFn(userEmail))}
                                        color={shouldShowError('userEmail', eMailInvalidFn(userEmail)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('userEmail', eMailInvalidFn(userEmail)) && "请输入正确的邮箱"}
                                        value={userEmail}
                                        onChange={(e) => setUserEmail(e.target.value)}
                                        onBlur={() => handleBlur('userEmail')}
                                        label="邮箱"
                                        placeholder="请输入邮箱"
                                        variant="bordered"
                                    />
                                    <Input
                                        isInvalid={shouldShowError('describeBySelf', isInvalidFn(describeBySelf))}
                                        color={shouldShowError('describeBySelf', isInvalidFn(describeBySelf)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('describeBySelf', isInvalidFn(describeBySelf)) && "请输入一言"}
                                        value={describeBySelf}
                                        onChange={(e) => setDescribeBySelf(e.target.value)}
                                        onBlur={() => handleBlur('describeBySelf')}
                                        label="一言"
                                        placeholder="请输入一言"
                                        variant="bordered"
                                    />
                                </div>

                                {/* 关联者账号信息 */}
                                <div className="space-y-4">
                                    <h4 className="text-md font-semibold text-secondary">关联者账号信息</h4>
                                    <div className={"w-full flex justify-center"}>
                                        <input type="file" name="file" className={"hidden"} id="loverUpload"
                                               onChange={upLoverAvatar}/>
                                        <label htmlFor="loverUpload">
                                            <Avatar isBordered src={loverAvatar} className="w-20 h-20 text-large cursor-pointer"/>
                                        </label>
                                    </div>
                                    <Input
                                        isInvalid={shouldShowError('lover', eMailInvalidFn(lover))}
                                        color={shouldShowError('lover', eMailInvalidFn(lover)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('lover', eMailInvalidFn(lover)) && "请输入正确的邮箱"}
                                        value={lover}
                                        onChange={(e) => setLover(e.target.value)}
                                        onBlur={() => handleBlur('lover')}
                                        label="关联者邮箱"
                                        placeholder="请输入关联者邮箱"
                                        variant="bordered"
                                    />
                                    <Input
                                        isInvalid={shouldShowError('loverUsername', isInvalidFn(loverUsername))}
                                        color={shouldShowError('loverUsername', isInvalidFn(loverUsername)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('loverUsername', isInvalidFn(loverUsername)) && "请输入关联者昵称"}
                                        value={loverUsername}
                                        onChange={(e) => setLoverUsername(e.target.value)}
                                        onBlur={() => handleBlur('loverUsername')}
                                        label="关联者昵称"
                                        placeholder="请输入关联者昵称"
                                        variant="bordered"
                                    />
                                    <Input
                                        isInvalid={shouldShowError('loverDescribeBySelf', isInvalidFn(loverDescribeBySelf))}
                                        color={shouldShowError('loverDescribeBySelf', isInvalidFn(loverDescribeBySelf)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('loverDescribeBySelf', isInvalidFn(loverDescribeBySelf)) && "请输入关联者一言"}
                                        value={loverDescribeBySelf}
                                        onChange={(e) => setLoverDescribeBySelf(e.target.value)}
                                        onBlur={() => handleBlur('loverDescribeBySelf')}
                                        label="关联者一言"
                                        placeholder="请输入关联者一言"
                                        variant="bordered"
                                    />
                                </div>

                                {/* 密码信息（共享） */}
                                <div className="space-y-4">
                                    <h4 className="text-md font-semibold text-warning">共享密码</h4>
                                    <p className="text-sm text-gray-500">两个账号将使用相同的登录密码</p>
                                    <Input
                                        isInvalid={shouldShowError('password', isInvalidFn(password))}
                                        color={shouldShowError('password', isInvalidFn(password)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('password', isInvalidFn(password)) && "请输入密码"}
                                        value={password}
                                        onChange={(e) => setPassword(e.target.value)}
                                        onBlur={() => handleBlur('password')}
                                        label="密码"
                                        placeholder="请输入密码"
                                        variant="bordered"
                                        type="password"
                                    />
                                    <Input
                                        isInvalid={shouldShowError('password2', sameInvalidFn(password2, password))}
                                        color={shouldShowError('password2', sameInvalidFn(password2, password)) ? "danger" : "default"}
                                        errorMessage={shouldShowError('password2', sameInvalidFn(password2, password)) && "请再次输入一致的密码"}
                                        value={password2}
                                        onChange={(e) => setPassword2(e.target.value)}
                                        onBlur={() => handleBlur('password2')}
                                        label="确认密码"
                                        placeholder="请再次输入一致的密码"
                                        variant="bordered"
                                        type="password"
                                    />
                                </div>
                            </ModalBody>
                            <ModalFooter>
                                <Button color="danger" variant="flat" onClick={onClose}>
                                    取消
                                </Button>
                                <Button color="primary" onClick={userRegisterAct} isLoading={isLoading}>
                                    注册双账号
                                </Button>
                            </ModalFooter>
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    )
};
