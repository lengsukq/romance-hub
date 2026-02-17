import {Button, Card, CardBody, CardFooter, CardHeader, Input, Textarea,} from "@heroui/react";
import React, {useEffect, useState} from "react";
import { formatDateTime } from "@/utils/dateFormat";
import {isInvalidFn} from "@/utils/client/dataTools";
import {addWhisper} from "@/utils/client/apihttp";
import {Notify} from "@/utils/client/notificationUtils";
import FavButton from "@/components/buttonCom/FavButton";
import { WhisperItem } from "@/types";


interface WhisperFormProps {
    item?: WhisperItem | null;
    addFavAct?: (item: WhisperItem) => void;
    addLoading?: boolean;
}

export default function WhisperForm({
    item = null,
    addFavAct = () => "",
    addLoading = false
}: WhisperFormProps) {
    const [title, setTitle] = useState("");
    const [content, setContent] = useState("");
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        if (item) {
            setTitle(item.title || '')
            setContent(item.content)
        }
    }, [item])
    
    const addWhisperAct = async () => {
        let params = {title, content};
        if (isInvalidFn(params)) {
            return;
        }
        setIsLoading(true);
        await addWhisper(params).then(res => {
            setIsLoading(false);
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code===200){
                setTitle('');
                setContent('');
            }
        })
    }
    
    const FooterLeftCom = () => {
        if (item) {
            const publisherName = item.userName ?? item.publisherName ?? '—';
            const formattedTime = formatDateTime(item.creationTime);
            return (
                <>
                    <div className="flex flex-col gap-0.5 pl-1 pb-0">
                        <p className="text-default-500 text-small">
                            <span className="font-medium text-default-600">{publisherName}</span>
                            <span className="text-default-400"> 发布于 </span>
                            <span className="text-default-500">{formattedTime}</span>
                        </p>
                    </div>
                    <FavButton isFav={!!item.favId} btnSize={'sm'} iconSize={18} buttonAct={()=>addFavAct && addFavAct(item)} isLoading={addLoading}/>
                </>
            )
        } else {
            return (<Button color="primary" onClick={addWhisperAct} isLoading={isLoading}>发布</Button>)
        }
    }
    
    return (
        <Card className="py-4 mb-5">
            <CardHeader className="pb-0 pt-2 px-4 flex-col items-start">
                <Input
                    isInvalid={isInvalidFn(title)}
                    color={item ? "default" : (isInvalidFn(title) ? "danger" : "success")}
                    errorMessage={isInvalidFn(title) && "请输入留言标题"}
                    disabled={!!item}
                    value={title}
                    onChange={(e) => setTitle(e.target.value)}
                    type="text" label="留言标题"/>
            </CardHeader>
            <CardBody className="overflow-visible py-2">
                <Textarea
                    isInvalid={isInvalidFn(content)}
                    color={item ? "default" : (isInvalidFn(content) ? "danger" : "success")}
                    errorMessage={isInvalidFn(content) && "请输入留言内容"}
                    disabled={!!item}
                    value={content}
                    onChange={(e) => setContent(e.target.value)}
                    label="留言内容"
                    className="pl-1 pr-1"
                />
            </CardBody>
            <CardFooter className={item ? "gap-3 flex justify-between" : "flex justify-center"}>
            <FooterLeftCom/>
            </CardFooter>
        </Card>
    )
};
