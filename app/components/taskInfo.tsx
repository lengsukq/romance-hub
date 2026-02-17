'use client'
import React, {useEffect, useState} from "react";
import {Button, Card, CardBody, Input, Slider, Textarea} from "@heroui/react";
import {isInvalidFn} from "../utils/client/dataTools";
import {TrashCan} from "@/components/icon/trashCan";
import {getScore} from "@/utils/client/apihttp";
import FavButton from "@/components/buttonCom/FavButton";
import CustomUploader from "@/components/CustomUploader";

interface TaskInfoProps {
    favId?: number | null;
    isPost?: boolean;
    taskDetail?: string;
    taskName?: string;
    taskReward?: string;
    taskScore?: number;
    taskStatus?: string;
    defaultValue?: Array<{url: string}>;
    vantUpload?: (file: File) => Promise<any>;
    imgUploadDelete?: () => void;
    setTaskName?: (value: string) => void;
    setTaskReward?: (value: string) => void;
    setTaskDetail?: (value: string) => void;
    deleteButton?: () => void;
    onChangeEnd?: (value: number | number[]) => void;
    addFavAct?: () => void;
    showAccept?: boolean;
    showComplete?: boolean;
    onAccept?: () => void;
    onComplete?: () => void;
    onImageClick?: (index: number) => void;
    isStateLoading?: boolean;
}

export default function TaskInfoCom({
    favId = null,
    isPost = false,
    taskDetail = "",
    taskName = "",
    taskReward = "",
    taskScore = 0,
    taskStatus = "未开始",
    defaultValue = [{url: ""}],
    vantUpload = async () => ({}),
    imgUploadDelete = () => "",
    setTaskName = () => "",
    setTaskReward = () => "",
    setTaskDetail = () => "",
    deleteButton = () => "",
    onChangeEnd = () => "",
    addFavAct = () => "",
    showAccept = false,
    showComplete = false,
    onAccept = () => "",
    onComplete = () => "",
    onImageClick,
    isStateLoading = false,
}: TaskInfoProps) {
    const getScoreAct = async () => {
        await getScore().then(res => {
            setSliderMax(res.data.score)
        })
    }
    const [sliderMax, setSliderMax] = useState(1000)
    const [sliderValue, setSliderValue] = useState(0)

    const statusText: Record<string, string> = {
        pending: '待接受',
        accepted: '进行中',
        completed: '已完成',
    };
    const displayStatus = statusText[taskStatus] ?? taskStatus;

    useEffect(() => {
        if (isPost) {
            // 获取积分
            getScoreAct().then(r =>{})
        } else {
            setSliderMax(taskScore)
        }
        console.log('useEffect')
        setSliderValue(taskScore)
    }, [taskScore])

    return (
        <>
            <Card className={isPost ? "hidden" : "mb-5"}>
                <CardBody className="flex justify-between flex-row items-center flex-wrap gap-2">
                    <div className="flex items-center gap-2 flex-wrap">
                        <p>{displayStatus}</p>
                        {showAccept && (
                            <Button size="sm" color="primary" variant="flat" onPress={onAccept} isLoading={isStateLoading}>接受</Button>
                        )}
                        {showComplete && (
                            <Button size="sm" color="success" variant="flat" onPress={onComplete} isLoading={isStateLoading}>完成任务</Button>
                        )}
                    </div>
                    <div className={"flex"}>
                        <FavButton buttonAct={addFavAct} isFav={!!favId}/>
                        <Button isIconOnly variant="faded" onClick={() => deleteButton()} className={"ml-1"}>
                            <TrashCan></TrashCan>
                        </Button>
                    </div>
                </CardBody>
            </Card>
            <Card className="mb-5">
                <CardBody className="flex justify-center">
                    {isPost ? <CustomUploader
                            upload={vantUpload}
                            resultType={'dataUrl'}
                            onDelete={imgUploadDelete}/>
                        : <CustomUploader
                            value={defaultValue}
                            deletable={false}
                            showUpload={false}
                            onImageClick={defaultValue?.length && defaultValue[0]?.url ? onImageClick : undefined}
                        />}
                </CardBody>
            </Card>
            <Card className="mb-5">
                <CardBody>
                    <Input isReadOnly={!isPost}
                           isInvalid={isPost ? isInvalidFn(taskName) : false}
                           color={isPost ? (isInvalidFn(taskName) ? "danger" : "success") : "default"}
                           errorMessage={isPost ? isInvalidFn(taskName) && "请输入任务名称" : ""}
                           type="text" label="任务名称" placeholder="请输入任务名称"
                           value={taskName} className="mb-5"
                           onChange={(e) => setTaskName(e.target.value)}/>
                    <Textarea isReadOnly={!isPost}
                              isInvalid={isPost ? isInvalidFn(taskDetail) : false}
                              color={isPost ? (isInvalidFn(taskDetail) ? "danger" : "success") : "default"}
                              errorMessage={isPost ? isInvalidFn(taskDetail) && "请输入任务描述" : ""}
                              value={taskDetail}
                              onChange={(e) => setTaskDetail(e.target.value)}
                              label="任务描述"
                              placeholder="请输入任务描述"
                              className="mb-5"
                    />
                    <Textarea isReadOnly={!isPost}
                              isInvalid={isPost ? isInvalidFn(taskReward) : false}
                              color={isPost ? (isInvalidFn(taskReward) ? "danger" : "success") : "default"}
                              errorMessage={isPost ? isInvalidFn(taskReward) && "请输入任务奖励" : ""}
                              value={taskReward}
                              onChange={(e) => setTaskReward(e.target.value)}
                              label="任务奖励"
                              placeholder="请输入任务奖励"
                              className="mb-5"
                    />
                    <Slider
                        isDisabled={!isPost}
                        label="悬赏积分"
                        step={5}
                        maxValue={sliderMax}
                        minValue={0}
                        getValue={(donuts: number | number[]) => `❤️${Array.isArray(donuts) ? donuts[0] : donuts}`}
                        value={sliderValue}
                        className=""
                        onChange={(value: number | number[]) => setSliderValue(Array.isArray(value) ? value[0] : value)}
                        onChangeEnd={onChangeEnd}
                    />
                </CardBody>
            </Card>
        </>
    );
}
