import { createSlice } from '@reduxjs/toolkit';

// 礼物状态枚举
export enum GiftType {
    ALL = "",
    UP = "已上架",
    DOWN = "已下架", 
    USE = "待使用",
    USED = "已用完"
}

// 礼物状态接口
interface MyGiftState {
    type: string;
    isSearch: boolean;
}

const initialState: MyGiftState = {
    type: GiftType.UP,
    isSearch: false,
};

export const statusSlice = createSlice({
    name: 'myGiftType',
    initialState,
    reducers: {
        setAll: (state) => {
            state.type = GiftType.ALL;
        },
        setUp: (state) => {
            state.type = GiftType.UP;
        },
        setDown: (state) => {
            state.type = GiftType.DOWN;
        },
        setUse: (state) => {
            state.type = GiftType.USE;
        },
        setUsed: (state) => {
            state.type = GiftType.USED;
        },
        openSearch: (state) => {
            state.isSearch = true;
        },
        closeSearch: (state) => {
            state.isSearch = false;
        }
    },
});

export const { setAll, setUp, setDown, setUse, setUsed, openSearch, closeSearch } = statusSlice.actions;

export default statusSlice.reducer;
