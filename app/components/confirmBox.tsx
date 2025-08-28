import {Button, Modal, ModalBody, ModalContent, ModalFooter, ModalHeader} from "@heroui/react";

interface ConfirmBoxProps {
    isOpen: boolean;
    onClose: () => void;
    cancelAct: () => void;
    confirmAct: () => void;
    modalText?: string;
}

export default function ConfirmBox({
    isOpen,
    onClose,
    cancelAct,
    confirmAct,
    modalText = ""
}: ConfirmBoxProps) {
    return (
        <>
            <Modal
                size="xs"
                placement={"center"}
                isOpen={isOpen}
                onClose={onClose}>
                <ModalContent>
                    {(onClose) => (
                        <>
                            <ModalHeader className="flex flex-col gap-1">提示</ModalHeader>
                            <ModalBody>
                                {modalText}
                            </ModalBody>
                            <ModalFooter>
                                <Button color="danger" variant="light" onClick={cancelAct}>
                                    取消
                                </Button>
                                <Button color="primary" onClick={confirmAct}>
                                    确认
                                </Button>
                            </ModalFooter>
                        </>
                    )}
                </ModalContent>
            </Modal>
        </>
    )
}
