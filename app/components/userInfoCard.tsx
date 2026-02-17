import {Avatar, Button, Card, CardBody, CardFooter, CardHeader,} from "@heroui/react";
import React from "react";

interface UserInfo {
    avatar: string;
    username: string;
    score: number;
    userEmail: string;
    describeBySelf?: string;
    registrationTime: string;
}

interface UserInfoCardProps {
    userInfo?: UserInfo;
    onAction?: () => void;
    isLover?: boolean;
    avatarBtn?: () => void;
    actionLabel?: string;
    hideAction?: boolean;
}

export default function UserInfoCard ({
    userInfo, 
    onAction = () => {},
    isLover = false,
    avatarBtn = () => {},
    actionLabel = '编辑',
    hideAction = false
}: UserInfoCardProps) {
    if (userInfo) {
        return (
            <>
                <Card className="mb-5">
                    <CardHeader className="justify-between">
                        <div className="flex gap-5">
                            <Avatar isBordered radius="full" size="md" src={userInfo.avatar} onClick={avatarBtn}/>
                            <div className="flex flex-col gap-1 items-start justify-center">
                                <h4 className="text-small font-semibold leading-none text-default-600">{userInfo.username}
                                    <span className={"text-default-400"}>❤️{userInfo.score}</span></h4>

                                <h5 className="text-small tracking-tight text-default-400">{userInfo.userEmail}</h5>
                            </div>
                        </div>
                        <Button
                            className={(isLover || hideAction) ? "hidden" : "bg-transparent text-foreground border-default-200"}
                            color="primary"
                            radius="full"
                            size="sm"
                            variant={"bordered"}
                            onClick={onAction}
                        >
                            {actionLabel}
                        </Button>
                    </CardHeader>
                    <CardBody className="px-3 py-0">
                        <div className="text-small">
                            <p className="text-default-500 font-medium mb-1">一言</p>
                            <p className="text-default-600">
                                {userInfo.describeBySelf?.trim() ? userInfo.describeBySelf : '未设置'}
                            </p>
                        </div>
                    </CardBody>
                    <CardFooter className="gap-3">
                        <div className="flex gap-1">
                            <p className=" text-default-400 text-small">初遇：</p>
                        </div>
                        <div className="flex gap-1">
                            <p className="text-default-400 text-small">{userInfo.registrationTime}</p>
                        </div>
                    </CardFooter>
                </Card>
            </>
        )
    }
    return null;
};
