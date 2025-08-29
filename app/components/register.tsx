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
    
    // 添加touched状态追踪用户是否与字段交互过
    const [touched, setTouched] = useState({
        username: false,
        userEmail: false,
        lover: false,
        describeBySelf: false,
        password: false,
        password2: false
    })

    const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const img = await imgUpload(event);
        setAvatar(img);
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
        if (isInvalidFn(username) || isInvalidFn(password) || isInvalidFn(describeBySelf) || eMailInvalidFn(userEmail) || eMailInvalidFn(lover) || sameInvalidFn(password, password2)){
            return
        }
        setLoading(true)
        await userRegister({avatar,userEmail,username,password,lover,describeBySelf}).then(res => {
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
                    body: "pb-0",
                }}
                size="full"
                hideCloseButton={true}
                placement={"center"}
                isOpen={isOpen}
                onClose={onClose}
                onOpenChange={keyToFalse}>
                <ModalContent>
                    {(onClose) => (
                        <>
                            <ModalHeader className="flex flex-col gap-1">注册用户</ModalHeader>
                            <ModalBody>
                                <div className={"w-full flex justify-center"}>
                                    <input type="file" name="file" className={"hidden"} id="upload"
                                           onChange={upAvatar}/>
                                    <label htmlFor="upload">
                                        <Avatar isBordered src={avatar} className="w-20 h-20 text-large"/>
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
                            </ModalBody>
                            <ModalFooter>
                                <Button color="danger" variant="flat" onClick={onClose}>
                                    取消
                                </Button>
                                <Button color="primary" onClick={userRegisterAct} isLoading={isLoading}>
                                    提交
                                </Button>
                            </ModalFooter>
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    )
};
