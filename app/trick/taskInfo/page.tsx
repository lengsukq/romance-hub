'use client'
import React, {useEffect, useState} from "react";
import {getTaskInfo, deleteTask, addFav} from "@/utils/client/apihttp";
import TaskInfoCom from "@/components/taskInfo";
import {Notify} from "react-vant";
import {useRouter, useSearchParams} from "next/navigation";
import ConfirmBox from "@/components/confirmBox";

interface TaskDetail {
    taskId: string;
    taskName: string;
    taskDetail: string;
    taskReward: string;
    taskScore: number;
    taskStatus: string;
    taskImg: string;
    favId?: string | null;
}

export default function App() {
    const router = useRouter();
    const searchParams = useSearchParams();
    const taskId = searchParams.get('taskId') || '';
    
    const [taskDetail, setTaskDetail] = useState<TaskDetail>({
        taskId: '',
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
        await getTaskInfo({taskId}).then(res => {
            if (res.code === 200) {
                setTaskDetail(res.data);
            }
        })
    }

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
