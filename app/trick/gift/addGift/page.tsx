'use client'
import React, {useState} from "react";
import {Avatar, Button, Card, CardBody, CardFooter, CardHeader, Input, Switch} from "@heroui/react";
import {imgUpload} from "@/utils/client/fileTools";
import {UpImg} from "@/components/icon/upImg";
import {addGift} from "@/utils/client/apihttp";
import {Notify} from "react-vant";
import {isInvalidFn, numberInvalidFn} from "@/utils/client/dataTools";

export default function App() {
    const [giftName, setGiftName] = useState('');
    const [giftDetail, setGiftDetail] = useState('');
    const [needScore, setNeedScore] = useState(0);
    const [giftImg, setGiftImg] = useState('');
    const [remained, setRemained] = useState(10);
    const [isShow, setIsShow] = useState(true);
    const [isLoading, setIsLoading] = useState(false);
    
    const upGiftImg = async (event: React.ChangeEvent<HTMLInputElement>) => {
        const img = await imgUpload(event);
        setGiftImg(img);
    }
    
    const addGiftAct = () => {
        let params = {giftName, giftDetail, needScore, remained, isShow};
        if (isInvalidFn(params) || numberInvalidFn(needScore) || numberInvalidFn(remained)) {
            return;
        }
        setIsLoading(true);
        const finalParams = {...params, giftImg};
        addGift(finalParams).then(res => {
            setIsLoading(false);
            Notify.show({type: res.code === 200 ? 'success' : 'warning', message: `${res.msg}`})
            if (res.code === 200) {
                // Reset form
                setGiftName('');
                setGiftDetail('');
                setNeedScore(0);
                setGiftImg('');
                setRemained(10);
                setIsShow(true);
            }
        })
    }

    return (
        <div className={"p-5"}>
            <Card className="mb-5">
                <CardHeader className="pb-0 pt-2 px-4 flex-col items-start">
                    <h4 className="font-bold text-large">添加礼物</h4>
                </CardHeader>
                <CardBody className="overflow-visible py-2">
                    <div className={"w-full flex justify-center mb-5"}>
                        <input type="file" name="file" className={"hidden"} id="uploadGift"
                               onChange={upGiftImg}/>
                        <label htmlFor="uploadGift">
                            {giftImg ? 
                                <Avatar isBordered src={giftImg} className="w-20 h-20 text-large"/> :
                                <div className="w-20 h-20 border-2 border-dashed border-gray-300 flex items-center justify-center rounded-full">
                                    <UpImg />
                                </div>
                            }
                        </label>
                    </div>
                    
                    <Input
                        isInvalid={isInvalidFn(giftName)}
                        color={isInvalidFn(giftName) ? "danger" : "success"}
                        errorMessage={isInvalidFn(giftName) && "请输入礼物名称"}
                        value={giftName}
                        onChange={(e) => setGiftName(e.target.value)}
                        label="礼物名称"
                        placeholder="请输入礼物名称"
                        className="mb-3"
                    />
                    
                    <Input
                        isInvalid={isInvalidFn(giftDetail)}
                        color={isInvalidFn(giftDetail) ? "danger" : "success"}
                        errorMessage={isInvalidFn(giftDetail) && "请输入礼物描述"}
                        value={giftDetail}
                        onChange={(e) => setGiftDetail(e.target.value)}
                        label="礼物描述"
                        placeholder="请输入礼物描述"
                        className="mb-3"
                    />
                    
                    <Input
                        isInvalid={numberInvalidFn(needScore)}
                        color={numberInvalidFn(needScore) ? "danger" : "success"}
                        errorMessage={numberInvalidFn(needScore) && "请输入正确的积分"}
                        type="number"
                        value={needScore.toString()}
                        onChange={(e) => setNeedScore(Number(e.target.value))}
                        label="所需积分"
                        placeholder="请输入所需积分"
                        className="mb-3"
                    />
                    
                    <Input
                        isInvalid={numberInvalidFn(remained)}
                        color={numberInvalidFn(remained) ? "danger" : "success"}
                        errorMessage={numberInvalidFn(remained) && "请输入库存数量"}
                        type="number"
                        value={remained.toString()}
                        onChange={(e) => setRemained(Number(e.target.value))}
                        label="库存数量"
                        placeholder="请输入库存数量"
                        className="mb-3"
                    />
                    
                    <div className="flex items-center justify-between mb-3">
                        <span>是否上架</span>
                        <Switch 
                            isSelected={isShow} 
                            onValueChange={setIsShow}
                            color="success"
                        />
                    </div>
                </CardBody>
                <CardFooter className="flex justify-center">
                    <Button 
                        color="primary" 
                        onClick={addGiftAct} 
                        isLoading={isLoading}
                        className="w-full"
                    >
                        添加礼物
                    </Button>
                </CardFooter>
            </Card>
        </div>
    );
}
