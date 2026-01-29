'use client'
import React, {useEffect, useState} from "react";
import {getMyGift, showGift, useGift} from "@/utils/client/apihttp";
import GiftList from "@/components/giftList";
import {Notify} from "@/utils/client/notificationUtils";
import {useDispatch, useSelector} from "react-redux";
import SearchModal from "@/components/searchModal";
import {closeSearch} from "@/store/myGiftStore";
import NoDataCom from "@/components/noDataCom";
import { RootState } from "@/store/store";

interface GiftItem {
    giftId: number;
    giftName: string;
    giftImg: string;
    needScore: number;
    giftDetail: string;
    remained: number;
    redeemed: number;
    isShow: number;
    use?: number;
    used?: number;
}

export default function App() {
    const myGiftType = useSelector((state: RootState) => state.myGiftType.type);
    const isSearch = useSelector((state: RootState) => state.myGiftType.isSearch);
    const dispatch = useDispatch();
    const [searchWords, setSearchWords] = useState('')
    const [listType, setListType] = useState<"getGift" | "checkGift" | "useGift" | "overGift" | "favList">('checkGift');
    const [isLoading, setIsLoading] = useState(false);
    
    const keyToFalse = () => {
        dispatch(closeSearch())
    }

    const typeObj: Record<string, "getGift" | "checkGift" | "useGift" | "overGift" | "favList"> = {
        "已上架": "checkGift",
        "已下架": "checkGift",
        "待使用": "useGift",
        "已用完": "overGift",
    }

    useEffect(() => {
        setSearchWords('');
        setListType(typeObj[myGiftType])
        getGiftList(myGiftType, '').then(r => {
        })
    }, [myGiftType])
    
    const [giftListData, setGiftListData] = useState<GiftItem[]>([])
    
    const getGiftList = async (type = myGiftType, words = searchWords) => {
        await getMyGift({
            type: myGiftType,
            searchWords: words
        }).then(res => {
            if (res.code===200){
                setGiftListData(res.data);
                dispatch(closeSearch())
            }else{
                Notify.show({type:'warning', message: `${res.msg}`})
            }
        })
    }
    
    const buttonAction = async (item: GiftItem, theKey: boolean) => {
        setIsLoading(true);
        if (myGiftType==='待使用'){
            await useGift({giftId: item.giftId}).then(res => {
                Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
                getGiftList();
            })
        }else{
            await showGift({giftId: item.giftId, isShow: theKey}).then(res => {
                Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
                getGiftList();
            })
        }
        setIsLoading(false);
    }

    const onKeyDown = async () => {
            await getGiftList()
    }
    
    return (
        <>
            <SearchModal openKey={isSearch}
                         keyToFalse={keyToFalse}
                         searchWords={searchWords}
                         setSearchWords={setSearchWords}
                         onKeyDown={onKeyDown}
                         placeholder={"请输入礼物名称"}/>
            {giftListData.length>0?
                <GiftList giftListData={giftListData}
                          listType={listType}
                          buttonAction={buttonAction}
                          isLoading={isLoading}
                />:<NoDataCom/>}
        </>
    );
}
