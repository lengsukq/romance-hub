'use client'
import React, {useEffect, useState} from "react";
import WhisperForm from "@/components/whisperForm";
import {addFav, getMyWhisper} from "@/utils/client/apihttp";
import NoDataCom from "@/components/noDataCom";
import {Notify} from "react-vant";
import { WhisperItem } from "@/types";

export default function App() {
    const [whisperData, setWhisperData] = useState<WhisperItem[]>([])
    const [isLoading, setIsLoading] = useState(false);

    useEffect(() => {
        getMyWhisperAct().then(r => '');
    }, [])
    
    const getMyWhisperAct = async () => {
        await getMyWhisper({searchWords: ""}).then(res => {
            console.log('getMyWhisper', res)
            setWhisperData(res.data)
        })
    }
    
    const addFavAct = async (item: WhisperItem) => {
        console.log('addFavAct')
        setIsLoading(true);
        await addFav({collectionId: item.whisperId, collectionType: 'whisper'}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getMyWhisperAct();
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
