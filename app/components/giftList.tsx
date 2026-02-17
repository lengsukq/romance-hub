import { Avatar, Button, Card, CardBody, CardFooter, CardHeader } from "@heroui/react";
import FavButton from "@/components/buttonCom/FavButton";
import { formatDateTime } from "@/utils/dateFormat";

interface GiftItem {
    giftId: number;
    giftImg: string;
    giftName: string;
    needScore: number;
    giftDetail: string;
    remained: number;
    redeemed: number;
    isShow: number;
    use?: number;
    used?: number;
    favId?: number | null;
    collectionName?: string;
    creationTime?: string;
}

interface GiftListProps {
    giftListData: GiftItem[];
    listType: "getGift" | "checkGift" | "useGift" | "overGift" | "favList";
    buttonAction?: (item: GiftItem, theKey: boolean) => void;
    addFavAct?: (item: GiftItem) => void;
    isLoading?: boolean;
}

export default function GiftList({
    giftListData, 
    listType, 
    buttonAction = () => '',
    addFavAct = () => '',
    isLoading = false
}: GiftListProps) {

    const ActButton = ({item}: {item: GiftItem}) => {
        let theKey: boolean;
        let trueText = '', falseText = '', keyStyle = 'bg-transparent text-foreground border-default-200';
        
        if (listType === "getGift") {
            theKey = item.remained !== 0;
            trueText = "兑换";
            falseText = "售罄";
        } else if (listType === "checkGift") {
            theKey = item.isShow === 0;
            trueText = "上架";
            falseText = "下架";
        } else if (listType === "useGift") {
            theKey = true;
            trueText = "使用";
        } else if (listType === "overGift") {
            theKey = false;
            keyStyle = 'hidden'
        } else if (listType === 'favList'){
            theKey = false;
            keyStyle = 'hidden'
        } else {
            theKey = false;
        }
        
        return (
            <div className={"ml-1"}>
                <Button
                    onClick={() => buttonAction(item, theKey)}
                    className={theKey ? "" : keyStyle}
                    color="primary"
                    radius="full"
                    size="sm"
                    variant={theKey ? "solid" : "bordered"}
                    isLoading={isLoading}>
                    {theKey ? trueText : falseText}
                </Button>
            </div>
        )
    }
    
    const FavButtonCom = ({item}: {item: GiftItem}) => {
        if (listType !== 'checkGift'){
            return (<FavButton btnSize={'sm'} iconSize={18} isFav={!!item.favId} buttonAct={() =>addFavAct(item)} isLoading={isLoading}/>)
        }
        return null;
    }

    const CustomFooter = ({item}: {item: GiftItem}) => {
        console.log('CustomFooter',listType,listType === "useGift")
        let textLeft = '库存：', textRight = '已售：', valueLeft: string | number = item.remained, valueRight: string | number = item.redeemed;

        if (listType === "useGift" || listType === "overGift") {
            textLeft = "拥有：";
            valueLeft = item.use || 0;
            textRight = "已用：";
            valueRight = item.used || 0;
        } else if (listType === 'favList'){
            textLeft = `${item.collectionName}发布于`;
            valueLeft = formatDateTime(item.creationTime);
            textRight = "";
            valueRight = "";
        }

        return (
            <CardFooter className="flex justify-between">
                <div className="gap-3 flex">
                    <div className="flex gap-1">
                        <p className="font-semibold text-default-400 text-small">{textLeft}</p>
                        <p className=" text-default-400 text-small">{valueLeft}</p>
                    </div>
                    <div className="flex gap-1">
                        <p className="font-semibold text-default-400 text-small">{textRight}</p>
                        <p className="text-default-400 text-small">{valueRight}</p>
                    </div>
                </div>
            </CardFooter>
        )
    }

    return (
        <div className={"p-5"}>
            {giftListData.map((item, index) => (
                <Card className="mb-5" key={item.giftId}>
                    <CardHeader className="justify-between">
                        <div className="flex gap-5">
                            <Avatar isBordered radius="full" size="md" src={item.giftImg}/>
                            <div className="flex flex-col gap-1 items-start justify-center">
                                <h4 className="text-small font-semibold leading-none text-default-600">{item.giftName}</h4>
                                <h5 className="text-small tracking-tight text-default-400">需要积分：{item.needScore}</h5>
                            </div>
                        </div>
                        <div className={"flex items-center"}>
                            <FavButtonCom item={item}/>
                            <ActButton item={item}/>
                        </div>
                    </CardHeader>
                    <CardBody className="px-3 py-0 text-small text-default-400">
                        <p>
                            {item.giftDetail}
                        </p>
                    </CardBody>
                    <CustomFooter item={item}/>
                </Card>
            ))}
        </div>
    )
}
