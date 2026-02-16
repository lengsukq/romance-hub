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
    const [taskImage, setTaskImage] = useState<string[]>([]);

    const vantUpload = async (file: File) => {
        try {
            const img = await imgUpload({ target: { files: [file] } } as any);
            if (img) {
                setTaskImage([img]);
            }
            return { url: img };
        } catch (error) {
            console.error('Upload failed:', error);
            return { url: '' };
        }
    };

    const imgUploadDelete = () => {
        setTaskImage([]);
    };

    const onChangeEnd = (value: number | number[]) => {
        const score = Array.isArray(value) ? value[0] : value;
        setTaskScore(score);
    };

    const postTaskAct = async () => {
        if (isInvalidFn(taskName) || isInvalidFn(taskDetail) || isInvalidFn(taskReward)) {
            Notify.show({ type: 'warning', message: '请填写完整的任务信息' });
            return;
        }
        if (!taskImage || taskImage.length === 0) {
            Notify.show({ type: 'warning', message: '请至少上传一张任务图片' });
            return;
        }
        const params = {
            taskName,
            taskDesc: taskDetail,
            taskImage,
            taskScore,
        };
        await postTask(params).then(res => {
            Notify.show({ type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}` });
            if (res.code === 200) {
                setTaskName('');
                setTaskDetail('');
                setTaskReward('');
                setTaskScore(0);
                setTaskImage([]);
            }
        });
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
