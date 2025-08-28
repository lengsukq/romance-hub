import React from "react";
import {Button, Dropdown, DropdownItem, DropdownMenu, DropdownTrigger} from "@heroui/react";
import {FilterIco} from "@/components/icon/filterIco";
import {useDispatch, useSelector} from 'react-redux'
import {
    closeSearch,
    openSearch,
    setAccept,
    setAll,
    setComplete,
    setNotStart,
    setPass
} from "@/app/store/taskListStore";
import {SearchIcon} from "@/components/icon/SearchICon";
import { Key } from "@react-types/shared";

export function TaskListLeftDropdown() {
    const taskStatusStore = useSelector((state: any) => state.taskListDataStatus.status);
    const [selectedKeys, setSelectedKeys] = React.useState<Set<string | number>>(new Set([taskStatusStore]));
    const dispatch = useDispatch()
    const onChange = (value: Key) => {
        console.log('onChange', value, typeof value, value === '已核验');
        const setValueObj: Record<string, any> = {
            "未开始": setNotStart(),
            "已接受": setAccept(),
            "待核验": setComplete(),
            "已核验": setPass(),
            "所有的": setAll(),
        }
        dispatch(setValueObj[value as string])
    }
    
    const handleSelectionChange = (keys: any) => {
        setSelectedKeys(keys);
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
                          selectedKeys={selectedKeys}
                          onSelectionChange={handleSelectionChange}>
                <DropdownItem key="所有的">所有的</DropdownItem>
                <DropdownItem key="未开始">未开始</DropdownItem>
                <DropdownItem key="已接受">已接受</DropdownItem>
                <DropdownItem key="待核验">待核验</DropdownItem>
                <DropdownItem key="已核验">已核验</DropdownItem>
            </DropdownMenu>
        </Dropdown>
    );
}

export function TaskListRightDropdown() {
    const isSearch = useSelector((state: any) => state.taskListDataStatus.isSearch);

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
