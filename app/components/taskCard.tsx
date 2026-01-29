import { Card, CardBody, CardFooter, CardHeader, Image } from "@heroui/react";
import React from "react";
import { TaskItem } from "@/types";

interface TaskCardProps {
  taskList: TaskItem[];
  checkDetails: (task: TaskItem) => void;
}

export default function TaskCard({ taskList, checkDetails }: TaskCardProps) {
    return (
        <>
            {taskList.map((item: TaskItem) => (
                <Card 
                    shadow="sm" 
                    key={item.taskId} 
                    isPressable 
                    onClick={() => checkDetails(item)}
                    className="hover:scale-[1.02] transition-transform duration-200"
                >
                    <CardHeader className="pb-0 pt-2 px-4 flex-col items-start">
                        <p className="text-large uppercase font-bold truncate w-full">
                            {item.taskName}
                        </p>
                        <small className="text-default-500">
                            {item.creationTime}
                        </small>
                    </CardHeader>
                    <CardBody className="overflow-visible p-0">
                        <Image
                            shadow="sm"
                            radius="lg"
                            width="100%"
                            alt={item.taskName}
                            className="w-full object-cover h-[140px]"
                            src={item.taskImage[0]}
                            fallbackSrc="/placeholder-task.jpg"
                        />
                    </CardBody>
                    <CardFooter className="text-small justify-between">
                        <b className={`truncate w-3/5 text-left ${item.taskScore > 0 ? 'text-primary' : ''}`}>
                            {item.taskScore > 0 ? `${item.taskScore}❤️ ` : ''}
                            {item.publisherName}
                        </b>
                        <p className="text-default-500">
                            {item.taskStatus}
                        </p>
                    </CardFooter>
                </Card>
            ))}
        </>
    )

};

