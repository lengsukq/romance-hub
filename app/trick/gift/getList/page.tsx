'use client'
import React, {useEffect, useState} from "react";
import {addFav, exchangeGift, getGiftList} from "@/utils/client/apihttp";
import GiftList from "@/components/giftList";
import {Notify} from "@/utils/client/notificationUtils";
import {closeSearch} from "@/store/myGiftStore";
import {useDispatch} from "react-redux";
import NoDataCom from "@/components/noDataCom";

interface GiftItem {
    giftId: number;
    giftName: string;
    giftImg: string;
    needScore: number;
    giftDetail: string;
    remained: number;
    redeemed: number;
    isShow: number;
    favId?: number | null;
}

export default function App() {
    const dispatch = useDispatch();
    const [isLoading, setLoading] = useState(false);
    
    useEffect(() => {
        getGiftListAct().then(r => {
        })
    }, [])
    
    const [giftListData, setGiftListData] = useState<GiftItem[]>([]);

    const getGiftListAct = async (isShow = '', words = '') => {
        await getGiftList({
            searchWords: words
        }).then(res => {
            dispatch(closeSearch());
            setGiftListData(res.code === 200 ? res.data : []);
        })
    }

    const buttonAction = async (item: GiftItem, theKey: boolean) => {
        console.log('buttonAction', item, theKey)
        setLoading(true);
        await exchangeGift({giftId: item.giftId}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            getGiftListAct();
        })
        setLoading(false);
    }

    const addFavAct = async (item: GiftItem) => {
        setLoading(true);
        await addFav({collectionId: item.giftId, collectionType: 'gift'}).then(res => {
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                getGiftListAct();
            }
            setLoading(false);
        })
    }

    return (
        <>
            {giftListData.length > 0 ?
                <GiftList giftListData={giftListData}
                          listType={"getGift"}
                          buttonAction={buttonAction}
                          addFavAct={addFavAct}
                          isLoading={isLoading}
                /> : <NoDataCom/>}
        </>
    );
}
