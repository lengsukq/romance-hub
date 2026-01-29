import { configureStore } from '@reduxjs/toolkit';
import taskListDataStatus from "@/store/taskListStore";
import myGiftType from "@/store/myGiftStore";

export const store = configureStore({
    reducer: {
        taskListDataStatus,
        myGiftType,
    },
});

// 推断根状态类型和dispatch类型
export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
