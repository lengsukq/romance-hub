import React from "react";
import {Button, Dropdown, DropdownItem, DropdownMenu, DropdownTrigger} from "@heroui/react";
import {FilterIco} from "@/components/icon/filterIco";
import {useDispatch, useSelector} from 'react-redux'
import {SearchIcon} from "@/components/icon/SearchICon";
import {setAll, setUp, setDown, setUse, setUsed, closeSearch, openSearch} from "@/app/store/myGiftStore";
import { Key } from "@react-types/shared";

export function MyGiftLeftDropdown() {
    const myGiftType = useSelector((state: any) => state.myGiftType.type);
    const [myGiftTypeKey, setMyGiftTypeKey] = React.useState<Set<string | number>>(new Set([myGiftType]));
    const dispatch = useDispatch()
    const onChange = (value: Key) => {
        console.log('onChange', value, typeof value, value === '已核验');
        const setValueObj: Record<string, any> = {
            "所有的": setAll(),
            "已上架": setUp(),
            "已下架": setDown(),
            "待使用": setUse(),
            "已用完": setUsed(),
        }
        dispatch(setValueObj[value as string])
    }
    
    const handleSelectionChange = (keys: any) => {
        setMyGiftTypeKey(keys);
    }
    return (
        <Dropdown>
            <DropdownTrigger>
                <Button isIconOnly variant="faded">
                    <FilterIco/>
                </Button>
            </DropdownTrigger>
            <DropdownMenu aria-label="Static Actions"
                          selectionMode="single"
                          disallowEmptySelection
                          onAction={onChange}
                          selectedKeys={myGiftTypeKey}
                          onSelectionChange={handleSelectionChange}>
                {/*<DropdownItem key="所有的">所有的</DropdownItem>*/}
                <DropdownItem key="已上架">已上架</DropdownItem>
                <DropdownItem key="已下架">已下架</DropdownItem>
                <DropdownItem key="待使用">待使用</DropdownItem>
                <DropdownItem key="已用完">已用完</DropdownItem>
            </DropdownMenu>
        </Dropdown>
    );
}

export function MyGiftRightDropdown() {
    const isSearch = useSelector((state: any) => state.myGiftType.isSearch);

    const dispatch = useDispatch();
    const openSearchBtn = () => {

        if (isSearch) {
            dispatch(closeSearch())
        }else{
            dispatch(openSearch())
        }
    }
    return (
        <Button isIconOnly variant="faded" onClick={openSearchBtn}>
            <SearchIcon/>
        </Button>
    );
}
