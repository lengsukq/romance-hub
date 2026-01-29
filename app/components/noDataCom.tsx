import {NoData} from "@/components/icon/noData";

export default function NoDataCom() {
    return (
        <div className={"flex flex-col justify-center items-center h-50vh"}>
            <NoData/>
            <p className={"mt-5 text-gray-600"}>暂时还没有数据哦</p>
        </div>
    )
}
