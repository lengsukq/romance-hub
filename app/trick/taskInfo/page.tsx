'use client'
import React, {useEffect, useState} from "react";
import {getTaskInfo, deleteTask, addFav} from "@/utils/client/apihttp";
import TaskInfoCom from "@/components/taskInfo";
import {Notify} from "@/utils/client/notificationUtils";
import {useRouter, useSearchParams} from "next/navigation";
import ConfirmBox from "@/components/confirmBox";

interface TaskDetail {
    taskId: number;
    taskName: string;
    taskDetail: string;
    taskReward: string;
    taskScore: number;
    taskStatus: string;
    taskImg: string;
    favId?: number | null;
}

export default function App() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const taskIdParam = searchParams.get('taskId') || '';
    const taskId = taskIdParam ? parseInt(taskIdParam, 10) : 0;
    
    const [taskDetail, setTaskDetail] = useState<TaskDetail>({
        taskId: 0,
        taskName: '',
        taskDetail: '',
        taskReward: '',
        taskScore: 0,
        taskStatus: '',
        taskImg: '',
        favId: null
    });
    const [isOpen, setIsOpen] = useState(false);

    useEffect(() => {
        if (taskId) {
            getTaskInfoAct();
        }
    }, [taskId])

    const getTaskInfoAct = async () => {
        await getTaskInfo({ taskId }).then(res => {
            if (res.code === 200 && res.data) {
                const d = res.data;
                setTaskDetail({
                    taskId: d.taskId,
                    taskName: d.taskName ?? '',
                    taskDetail: d.taskDesc ?? d.taskDetail ?? '',
                    taskReward: d.taskReward ?? '',
                    taskScore: d.taskScore ?? 0,
                    taskStatus: d.taskStatus ?? '',
                    taskImg: Array.isArray(d.taskImage) ? d.taskImage[0] ?? '' : (d.taskImage ?? ''),
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
        await addFav({collectionId: taskId, collectionType: 'task'}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getTaskInfoAct();
            }
        })
    }

    const defaultValue = taskDetail.taskImg ? [{url: taskDetail.taskImg}] : [{url: ""}];

    return (
        <>
            <div className={"p-5"}>
                <TaskInfoCom
                    favId={taskDetail.favId}
                    taskDetail={taskDetail.taskDetail}
                    taskName={taskDetail.taskName}
                    taskReward={taskDetail.taskReward}
                    taskScore={taskDetail.taskScore}
                    taskStatus={taskDetail.taskStatus}
                    defaultValue={defaultValue}
                    deleteButton={deleteButton}
                    addFavAct={addFavAct}
                />
            </div>
            <ConfirmBox
                isOpen={isOpen}
                onClose={() => setIsOpen(false)}
                cancelAct={() => setIsOpen(false)}
                confirmAct={deleteAct}
                modalText="确定要删除这个任务吗？"
            />
        </>
    );
}
