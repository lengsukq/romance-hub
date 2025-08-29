'use client'
import React, {useEffect, useState} from "react";
import GiftList from "@/components/giftList";
import {addFav, getFav} from "@/utils/client/apihttp";
import {Notify} from "@/utils/client/notificationUtils";
import NoDataCom from "@/components/noDataCom";

interface GiftItem {
    giftId: string;
    giftName: string;
    giftImg: string;
    needScore: number;
    giftDetail: string;
    remained: number;
    redeemed: number;
    isShow: number;
    favId?: string | null;
    collectionName?: string;
    creationTime?: string;
}

export default function App() {
    const [giftListData, setGiftListData] = useState<GiftItem[]>([]);
    const [isLoading, setLoading] = useState(false);

    const getFavAct = () => {
        getFav({type:"gift"}).then(res=>{
            setGiftListData(res.data)
        })
    }
    
    useEffect(() => {
        getFavAct();
    }, [])
    
    const addFavAct = async (item: GiftItem) => {
        setLoading(true);
        const params = {
            collectionId: item.giftId,
            collectionType: 'gift' as const
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
        <>
            {giftListData.length > 0 ?
                <GiftList giftListData={giftListData}
                          listType={"favList"}
                          addFavAct={addFavAct}
                          isLoading={isLoading}
                /> : <NoDataCom/>}
        </>
    );
}
