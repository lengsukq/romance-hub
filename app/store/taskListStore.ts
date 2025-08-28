import { createSlice, PayloadAction } from '@reduxjs/toolkit';

// 任务状态枚举
export enum TaskStatus {
    NOT_START = "未开始",
    ACCEPTED = "已接受", 
    COMPLETE = "待核验",
    PASS = "已核验",
    ALL = ""
}

// 状态接口
interface TaskListState {
    status: string;
    isSearch: boolean;
}

const initialState: TaskListState = {
    status: '',
    isSearch: false,
};

export const statusSlice = createSlice({
    name: 'taskListStatus',
    initialState,
    reducers: {
        setNotStart: (state) => {
            state.status = TaskStatus.NOT_START;
        },
        setAccept: (state) => {
            state.status = TaskStatus.ACCEPTED;
        },
        setComplete: (state) => {
            state.status = TaskStatus.COMPLETE;
        },
        setPass: (state) => {
            state.status = TaskStatus.PASS;
        },
        setAll: (state) => {
            state.status = TaskStatus.ALL;
        },
        openSearch: (state) => {
            console.log('openSearch: true');
            state.isSearch = true;
        },
        closeSearch: (state) => {
            console.log('closeSearch: false');
            state.isSearch = false;
        }
    },
});

export const { setNotStart, setAccept, setComplete, setPass, setAll, openSearch, closeSearch } = statusSlice.actions;

export default statusSlice.reducer;
