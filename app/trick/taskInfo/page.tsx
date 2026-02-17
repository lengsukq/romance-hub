'use client'
import React, { useEffect, useState } from "react";
import { getTaskInfo, deleteTask, addFav, upDateTaskState, getUserInfo } from "@/utils/client/apihttp";
import TaskInfoCom from "@/components/taskInfo";
import { Notify } from "@/utils/client/notificationUtils";
import { useRouter, useSearchParams } from "next/navigation";
import ConfirmBox from "@/components/confirmBox";
import { Modal, ModalContent, ModalBody, ModalHeader, Button } from "@heroui/react";

interface TaskDetail {
    taskId: number;
    taskName: string;
    taskDetail: string;
    taskReward: string;
    taskScore: number;
    taskStatus: string;
    taskImg: string;
    taskImage: string[];
    publisherId?: string | null;
    recipientId?: string | null;
    favId?: number | null;
}

const TASK_STATUS_PENDING = 'pending';
const TASK_STATUS_ACCEPTED = 'accepted';

export default function App() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const taskIdParam = searchParams.get('taskId') || '';
    const taskId = taskIdParam ? parseInt(taskIdParam, 10) : 0;

    const [userEmail, setUserEmail] = useState<string | null>(null);
    const [taskDetail, setTaskDetail] = useState<TaskDetail>({
        taskId: 0,
        taskName: '',
        taskDetail: '',
        taskReward: '',
        taskScore: 0,
        taskStatus: '',
        taskImg: '',
        taskImage: [],
        publisherId: null,
        recipientId: null,
        favId: null
    });
    const [isOpen, setIsOpen] = useState(false);
    const [imageViewerOpen, setImageViewerOpen] = useState(false);
    const [imageViewerIndex, setImageViewerIndex] = useState(0);
    const [stateLoading, setStateLoading] = useState(false);

    useEffect(() => {
        getUserInfo().then(res => {
            if (res.code === 200 && res.data?.userEmail) setUserEmail(res.data.userEmail);
        });
    }, []);

    useEffect(() => {
        if (taskId) getTaskInfoAct();
    }, [taskId]);

    const getTaskInfoAct = async () => {
        await getTaskInfo({ taskId }).then(res => {
            if (res.code === 200 && res.data) {
                const d = res.data;
                const imgs = Array.isArray(d.taskImage) ? d.taskImage : (d.taskImage ? [d.taskImage] : []);
                setTaskDetail({
                    taskId: d.taskId,
                    taskName: d.taskName ?? '',
                    taskDetail: d.taskDesc ?? d.taskDetail ?? '',
                    taskReward: d.taskReward ?? '',
                    taskScore: d.taskScore ?? 0,
                    taskStatus: d.taskStatus ?? '',
                    taskImg: imgs[0] ?? '',
                    taskImage: imgs,
                    publisherId: d.publisherId ?? null,
                    recipientId: d.recipientId ?? null,
                    favId: d.favId ?? null
                });
            }
        });
    };

    const deleteButton = () => {
        setIsOpen(true);
    }

    const deleteAct = async () => {
        await deleteTask({taskId}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                router.back();
            }
            setIsOpen(false);
        })
    }

    const addFavAct = async () => {
        await addFav({ collectionId: taskId, collectionType: 'task' }).then(res => {
            Notify.show({ type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}` });
            if (res.code === 200) getTaskInfoAct();
        });
    };

    const handleAccept = async () => {
        setStateLoading(true);
        const res = await upDateTaskState({ taskId, taskStatus: TASK_STATUS_ACCEPTED });
        setStateLoading(false);
        Notify.show({ type: res.code === 200 ? 'success' : 'warning', message: res.msg || '' });
        if (res.code === 200) getTaskInfoAct();
    };

    const handleComplete = async () => {
        setStateLoading(true);
        const res = await upDateTaskState({ taskId, taskStatus: 'completed' });
        setStateLoading(false);
        Notify.show({ type: res.code === 200 ? 'success' : 'warning', message: res.msg || '' });
        if (res.code === 200) getTaskInfoAct();
    };

    const showAccept = Boolean(
        userEmail &&
        taskDetail.taskStatus === TASK_STATUS_PENDING &&
        taskDetail.recipientId === userEmail
    );
    const showComplete = Boolean(
        userEmail &&
        taskDetail.taskStatus === TASK_STATUS_ACCEPTED &&
        (taskDetail.recipientId === userEmail || taskDetail.publisherId === userEmail)
    );

    const defaultValue = (taskDetail.taskImage?.length ? taskDetail.taskImage : [taskDetail.taskImg].filter(Boolean)).map(url => ({ url }));
    const displayDefaultValue = defaultValue.length ? defaultValue : [{ url: '' }];

    const openImageViewer = (index: number) => {
        setImageViewerIndex(index);
        setImageViewerOpen(true);
    };

    const taskImages = taskDetail.taskImage?.length ? taskDetail.taskImage : (taskDetail.taskImg ? [taskDetail.taskImg] : []);

    return (
        <>
            <div className="p-5">
                <TaskInfoCom
                    favId={taskDetail.favId}
                    taskDetail={taskDetail.taskDetail}
                    taskName={taskDetail.taskName}
                    taskReward={taskDetail.taskReward}
                    taskScore={taskDetail.taskScore}
                    taskStatus={taskDetail.taskStatus}
                    defaultValue={displayDefaultValue}
                    deleteButton={deleteButton}
                    addFavAct={addFavAct}
                    showAccept={showAccept}
                    showComplete={showComplete}
                    onAccept={handleAccept}
                    onComplete={handleComplete}
                    onImageClick={taskImages.length > 0 ? openImageViewer : undefined}
                    isStateLoading={stateLoading}
                />
            </div>
            <ConfirmBox
                isOpen={isOpen}
                onClose={() => setIsOpen(false)}
                cancelAct={() => setIsOpen(false)}
                confirmAct={deleteAct}
                modalText="确定要删除这个任务吗？"
            />
            <Modal isOpen={imageViewerOpen} onClose={() => setImageViewerOpen(false)} size="full" scrollBehavior="inside">
                <ModalContent>
                    <ModalHeader className="flex justify-between items-center">
                        <span>图片 {imageViewerIndex + 1} / {taskImages.length}</span>
                        <Button size="sm" variant="light" onPress={() => setImageViewerOpen(false)}>关闭</Button>
                    </ModalHeader>
                    <ModalBody className="flex flex-col items-center gap-4 pb-8">
                        <img
                            src={taskImages[imageViewerIndex]}
                            alt=""
                            className="max-w-full max-h-[70vh] object-contain"
                        />
                        {taskImages.length > 1 && (
                            <div className="flex gap-2">
                                <Button size="sm" isDisabled={imageViewerIndex === 0} onPress={() => setImageViewerIndex(i => Math.max(0, i - 1))}>上一张</Button>
                                <Button size="sm" isDisabled={imageViewerIndex >= taskImages.length - 1} onPress={() => setImageViewerIndex(i => Math.min(taskImages.length - 1, i + 1))}>下一张</Button>
                            </div>
                        )}
                    </ModalBody>
                </ModalContent>
            </Modal>
        </>
    );
}
