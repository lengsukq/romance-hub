import React from "react";
import {Button} from "@heroui/react";
import {HeartIcon} from "@/components/icon/HeartIcon";

interface FavButtonProps {
    buttonAct?: () => void;
    isFav?: boolean;
    btnSize?: 'sm' | 'md' | 'lg';
    iconSize?: number;
    isLoading?: boolean;
}

export default function FavButton({
    buttonAct = () => {},
    isFav,
    btnSize = 'md',
    iconSize = 24,
    isLoading = false
}: FavButtonProps) {
    return (
        <Button 
            isIconOnly 
            variant="faded" 
            aria-label="Like" 
            size={btnSize} 
            onClick={() => buttonAct()} 
            isLoading={isLoading}
        >
            <HeartIcon isFav={isFav} size={iconSize}/>
        </Button>
    );
}
