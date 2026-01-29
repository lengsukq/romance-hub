'use client'
import React, {useEffect, useState} from "react";
import {getTask} from "@/utils/client/apihttp";
import {useRouter} from 'next/navigation'
import {useDispatch, useSelector} from 'react-redux'
import SearchModal from "@/components/searchModal";
import {closeSearch} from "@/store/taskListStore";
import NoDataCom from "@/components/noDataCom";
import TaskCard from "@/components/taskCard";
import useInfiniteScroll from "@/hooks/useInfiniteScroll";
import { RootState } from "@/store/store";
import { TaskItem } from "@/types";

interface TaskListResponse {
    record: TaskItem[];
    totalPages: number;
}

export default function App() {
    const taskStatusStore = useSelector((state: RootState) => state.taskListDataStatus.status);
    const isSearch = useSelector((state: RootState) => state.taskListDataStatus.isSearch);
    const dispatch = useDispatch();
    const [taskList, setTaskList] = useState<TaskItem[]>([])
    const [searchWords, setSearchWords] = useState('');

    const router = useRouter()
    
    useEffect(() => {
        setCurrentPage(1)
        setSearchWords('');
        getTaskList(taskStatusStore, '',1).then(() => {
            // console.log('useEffect', r)
        });
    }, [taskStatusStore])
    
    const keyToFalse = () => {
        dispatch(closeSearch());
    }
    
    const onKeyDown = async () => {
        await getTaskList()
    }

    let pageSize = 10;
    const [currentPage, setCurrentPage] = useState(1);
    const [totalPages, setTotalPages] = useState(0);
    
    const getTaskList = async (taskStatus = taskStatusStore, words = searchWords, current = currentPage) => {
        await getTask({
            current: current,
            pageSize: pageSize,
            taskStatus: taskStatus,
            searchWords: words
        }).then(res => {
            dispatch(closeSearch());
            const data = res.data as TaskListResponse;
            setTotalPages(data.totalPages || 0);
            // 判断是否是第一次请求，如果是，则直接设置列表数据，否则添加到现有列表
            if (current === 1) {
                setTaskList(data.record);
            } else {
                setTaskList(prevList => [...prevList, ...data.record]);
            }
        })
    }

    const checkDetails = (item: TaskItem) => {
        router.push(`/trick/taskInfo?taskId=${item.taskId}`)
    }

    useInfiniteScroll(() => {
        if (currentPage < totalPages) {
            setCurrentPage(currentPage+1)
            getTaskList(taskStatusStore, searchWords, currentPage+1);
        }
    })
    
    return (
        <>
            <SearchModal openKey={isSearch}
                         keyToFalse={keyToFalse}
                         searchWords={searchWords}
                         setSearchWords={setSearchWords}
                         onKeyDown={onKeyDown}/>
            {taskList.length > 0 ?
                <div className="gap-2 grid grid-cols-2 sm:grid-cols-4 p-5">
                    <TaskCard taskList={taskList} checkDetails={checkDetails}/>
                </div> : <NoDataCom/>}
        </>
    )
}
