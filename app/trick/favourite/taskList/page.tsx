'use client'
import React, {useEffect, useState} from "react";
import TaskCard from "@/components/taskCard";
import {addFav, getFav} from "@/utils/client/apihttp";
import {Notify} from "react-vant";
import NoDataCom from "@/components/noDataCom";
import {useRouter} from "next/navigation";
import { TaskItem } from "@/types";

export default function App() {
    const [taskListData, setTaskListData] = useState<TaskItem[]>([]);
    const [isLoading, setLoading] = useState(false);
    const router = useRouter();

    const getFavAct = () => {
        getFav({type:"task"}).then(res=>{
            setTaskListData(res.data)
        })
    }
    
    useEffect(() => {
        getFavAct();
    }, [])
    
    const addFavAct = async (item: TaskItem) => {
        setLoading(true);
        const params = {
            collectionId: item.taskId,
            collectionType: 'task' as const
        }
        await addFav(params).then(res => {
            setLoading(false);
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getFavAct();
            }
        })
    }

    const checkDetails = (item: TaskItem) => {
        router.push(`/trick/taskInfo?taskId=${item.taskId}`)
    }
    
    return (
        <>
            {taskListData.length > 0 ?
                <div className="gap-2 grid grid-cols-2 sm:grid-cols-4 p-5">
                    <TaskCard taskList={taskListData} checkDetails={checkDetails}/>
                </div> : <NoDataCom/>}
        </>
    );
}
