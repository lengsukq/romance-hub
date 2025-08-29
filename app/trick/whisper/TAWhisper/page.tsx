'use client'
import React, {useEffect, useState} from "react";
import WhisperForm from "@/components/whisperForm";
import {addFav, getTAWhisper} from "@/utils/client/apihttp";
import {Notify} from "@/utils/client/notificationUtils";
import NoDataCom from "@/components/noDataCom";
import { WhisperItem } from "@/types";

export default function App() {
    const [whisperData, setWhisperData] = useState<WhisperItem[]>([]);
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        getTAWhisperAct().then(r => '');
    }, [])
    
    const getTAWhisperAct = async () => {
        try {
            await getTAWhisper({searchWords: ""}).then(res => {
                if (res.code===200){
                    setWhisperData(res.data)
                }else{
                    Notify.show({type: 'warning', message: `${res.msg}`})
                }
            })
        }catch (e){
            console.log(e);
        }
    }
    
    const addFavAct = async (item: WhisperItem) => {
        setIsLoading(true);
        await addFav({collectionId: item.whisperId, collectionType: 'whisper'}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getTAWhisperAct();
            }
            setIsLoading(false);
        })
    }
    
    return (
        <div className={"p-5"}>
            {whisperData.length > 0 ?
                whisperData.map((item) => (
                    <WhisperForm 
                        key={item.whisperId} 
                        item={item} 
                        addFavAct={addFavAct} 
                        addLoading={isLoading}
                    />
                )) : <NoDataCom/>}
        </div>
    );
}
