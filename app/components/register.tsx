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
import {Notify} from "react-vant";

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

    const upAvatar = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const img = await imgUpload(event);
        setAvatar(img);
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
                                    isInvalid={isInvalidFn(username)}
                                    color={isInvalidFn(username) ? "danger" : "success"}
                                    errorMessage={isInvalidFn(username) && "请输入昵称"}
                                    value={username}
                                    onChange={(e) => setUsername(e.target.value)}
                                    autoFocus
                                    label="昵称"
                                    placeholder="请输入昵称"
                                    variant="bordered"
                                />
                                <Input
                                    isInvalid={eMailInvalidFn(userEmail)}
                                    color={eMailInvalidFn(userEmail) ? "danger" : "success"}
                                    errorMessage={eMailInvalidFn(userEmail) && "请输入正确的邮箱"}
                                    value={userEmail}
                                    onChange={(e) => setUserEmail(e.target.value)}
                                    label="邮箱"
                                    placeholder="请输入邮箱"
                                    variant="bordered"
                                />
                                <Input
                                    isInvalid={eMailInvalidFn(lover)}
                                    color={eMailInvalidFn(lover) ? "danger" : "success"}
                                    errorMessage={eMailInvalidFn(lover) && "请输入正确的邮箱"}
                                    value={lover}
                                    onChange={(e) => setLover(e.target.value)}
                                    label="关联者邮箱"
                                    placeholder="请输入关联者邮箱"
                                    variant="bordered"
                                />
                                <Input
                                    isInvalid={isInvalidFn(describeBySelf)}
                                    color={isInvalidFn(describeBySelf) ? "danger" : "success"}
                                    errorMessage={isInvalidFn(describeBySelf) && "请输入一言"}
                                    value={describeBySelf}
                                    onChange={(e) => setDescribeBySelf(e.target.value)}
                                    label="一言"
                                    placeholder="请输入一言"
                                    variant="bordered"
                                />
                                <Input
                                    isInvalid={isInvalidFn(password)}
                                    color={isInvalidFn(password) ? "danger" : "success"}
                                    errorMessage={isInvalidFn(password) && "请输入密码"}
                                    value={password}
                                    onChange={(e) => setPassword(e.target.value)}
                                    label="密码"
                                    placeholder="请输入密码"
                                    variant="bordered"
                                    type="password"
                                />
                                <Input
                                    isInvalid={sameInvalidFn(password2, password)}
                                    color={sameInvalidFn(password2, password) ? "danger" : "success"}
                                    errorMessage={sameInvalidFn(password2, password) && "请再次输入一致的密码"}
                                    value={password2}
                                    onChange={(e) => setPassword2(e.target.value)}
                                    label="密码"
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
