'use client'
import React, {Suspense} from "react";
import {GlobalComponent} from "@/components/global/GlobalComponent";

interface TrickProvidersProps {
    children: React.ReactNode;
}

export function TrickProviders({children}: TrickProvidersProps) {
    return (
        <Suspense>
                <div className={"pb-14"}>{children}</div>
                <GlobalComponent/>
        </Suspense>
    );
}
