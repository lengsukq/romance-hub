'use client'
import React, {useState} from "react";
import {postTask} from "@/utils/client/apihttp";
import TaskInfoCom from "@/components/taskInfo";
import {Notify} from "@/utils/client/notificationUtils";
import {isInvalidFn} from "@/utils/client/dataTools";
import {imgUpload} from "@/utils/client/fileTools";

export default function App() {
    const [taskName, setTaskName] = useState('');
    const [taskDetail, setTaskDetail] = useState('');
    const [taskReward, setTaskReward] = useState('');
    const [taskScore, setTaskScore] = useState(0);

    const vantUpload = async (file: File) => {
        try {
            const formData = new FormData();
            formData.append('file', file);
            const img = await imgUpload({target: {files: [file]}} as any);
            return {url: img};
        } catch (error) {
            console.error('Upload failed:', error);
            return {url: ''};
        }
    }

    const imgUploadDelete = () => {
        console.log('Image deleted');
    }

    const onChangeEnd = (value: number | number[]) => {
        const score = Array.isArray(value) ? value[0] : value;
        setTaskScore(score);
    }

    const postTaskAct = async () => {
        const params = {taskName, taskDetail, taskReward, taskScore};
        if (isInvalidFn(taskName) || isInvalidFn(taskDetail) || isInvalidFn(taskReward)) {
            return;
        }
        
        await postTask(params).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                // Reset form
                setTaskName('');
                setTaskDetail('');
                setTaskReward('');
                setTaskScore(0);
            }
        })
    }

    return (
        <div className={"p-5"}>
            <TaskInfoCom
                isPost={true}
                taskDetail={taskDetail}
                taskName={taskName}
                taskReward={taskReward}
                taskScore={taskScore}
                vantUpload={vantUpload}
                imgUploadDelete={imgUploadDelete}
                setTaskName={setTaskName}
                setTaskReward={setTaskReward}
                setTaskDetail={setTaskDetail}
                onChangeEnd={onChangeEnd}
            />
            <div className="flex justify-center mt-5">
                <button 
                    onClick={postTaskAct}
                    className="bg-blue-500 text-white px-6 py-2 rounded-lg hover:bg-blue-600"
                >
                    发布任务
                </button>
            </div>
        </div>
    );
}
