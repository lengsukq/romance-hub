import React from "react";

interface OnSaleProps {
    [key: string]: any;
}

export const OnSale = ({
    ...props
}: OnSaleProps) => (
    <svg aria-hidden="true"
         focusable="false"
         viewBox="0 0 1024 1024"
         version="1.1"
         xmlns="http://www.w3.org/2000/svg"
         width="1em" height="1em">
        <path
            d="M858.8 512.7v231.9c0 64-51.9 115.9-115.9 115.9H279.1c-64 0-115.9-51.9-115.9-115.9V512.7c0-16 13-29 29-29s29 13 29 29v231.9c0 32 26 58 58 58H743c32 0 58-26 58-58V512.7c0-16 13-29 29-29 15.9 0 28.8 13 28.8 29zM499.3 167.3c3.6-1.6 7.5-2.4 11.7-2.4 4.5 0 8.9 1 12.7 2.9 3.3 1.4 6.5 3.5 9.2 6.2l123 123c11.3 11.3 11.3 29.7 0 41s-29.7 11.3-41 0L540 263.1v394.5c0 16-13 29-29 29s-29-13-29-29V262.9l-75 75c-11.3 11.3-29.7 11.3-41 0s-11.3-29.7 0-41l123-123c3-3 6.6-5.2 10.3-6.6z"></path>
    </svg>
);
