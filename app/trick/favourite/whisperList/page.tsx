'use client'
import React, {useEffect, useState} from "react";
import WhisperForm from "@/components/whisperForm";
import {addFav, getFav} from "@/utils/client/apihttp";
import {Notify} from "react-vant";
import NoDataCom from "@/components/noDataCom";
import { WhisperItem } from "@/types";

export default function App() {
    const [whisperListData, setWhisperListData] = useState<WhisperItem[]>([]);
    const [isLoading, setLoading] = useState(false);

    const getFavAct = () => {
        getFav({type:"whisper"}).then(res=>{
            setWhisperListData(res.data)
        })
    }
    
    useEffect(() => {
        getFavAct();
    }, [])
    
    const addFavAct = async (item: WhisperItem) => {
        setLoading(true);
        const params = {
            collectionId: item.whisperId,
            collectionType: 'whisper' as const
        }
        await addFav(params).then(res => {
            setLoading(false);
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getFavAct();
            }
        })
    }
    
    return (
        <div className={"p-5"}>
            {whisperListData.length > 0 ?
                whisperListData.map((item) => (
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
