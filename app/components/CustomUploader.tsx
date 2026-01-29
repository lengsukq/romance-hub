'use client'
import React, { useCallback, useState } from 'react';
import { Button, Card, CardBody } from "@heroui/react";
import { TrashCan } from "@/components/icon/trashCan";
import { UpImg } from "@/components/icon/upImg";

interface UploadFile {
  url: string;
  file?: File;
}

interface CustomUploaderProps {
  value?: UploadFile[];
  upload?: (file: File) => Promise<{ url: string }>;
  onDelete?: () => void;
  deletable?: boolean;
  showUpload?: boolean;
  resultType?: 'dataUrl' | 'file';
  maxCount?: number;
  accept?: string;
}

export default function CustomUploader({
  value = [],
  upload,
  onDelete,
  deletable = true,
  showUpload = true,
  resultType = 'dataUrl',
  maxCount = 1,
  accept = 'image/*'
}: CustomUploaderProps) {
  const [files, setFiles] = useState<UploadFile[]>(value);
  const [uploading, setUploading] = useState(false);

  const handleFileSelect = useCallback(async (event: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFiles = Array.from(event.target.files || []);
    
    if (selectedFiles.length === 0) return;
    
    const file = selectedFiles[0]; // 只处理第一个文件
    
    if (upload) {
      setUploading(true);
      try {
        const result = await upload(file);
        const newFile: UploadFile = {
          url: result.url,
          file: resultType === 'file' ? file : undefined
        };
        setFiles([newFile]); // 替换现有文件
      } catch (error) {
        console.error('Upload failed:', error);
      } finally {
        setUploading(false);
      }
    } else {
      // 如果没有上传函数，直接显示预览
      const reader = new FileReader();
      reader.onload = (e) => {
        const newFile: UploadFile = {
          url: e.target?.result as string,
          file: resultType === 'file' ? file : undefined
        };
        setFiles([newFile]);
      };
      reader.readAsDataURL(file);
    }
    
    // 清空 input 值，允许重新选择同一文件
    event.target.value = '';
  }, [upload, resultType]);

  const handleDelete = useCallback((index: number) => {
    setFiles(files => files.filter((_, i) => i !== index));
    if (onDelete) {
      onDelete();
    }
  }, [onDelete]);

  return (
    <div className="custom-uploader">
      {/* 已上传的文件预览 */}
      {files.length > 0 && (
        <div className="flex flex-wrap gap-2 mb-4">
          {files.map((file, index) => (
            <div key={index} className="relative">
              <Card className="w-20 h-20">
                <CardBody className="p-0 overflow-hidden">
                  <img
                    src={file.url}
                    alt={`上传的图片 ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                  {deletable && (
                    <Button
                      isIconOnly
                      size="sm"
                      className="absolute top-1 right-1 min-w-0 w-5 h-5 bg-red-500 text-white"
                      onClick={() => handleDelete(index)}
                    >
                      <TrashCan className="w-3 h-3" />
                    </Button>
                  )}
                </CardBody>
              </Card>
            </div>
          ))}
        </div>
      )}

      {/* 上传按钮 */}
      {showUpload && files.length < maxCount && (
        <div className="upload-area">
          <input
            type="file"
            accept={accept}
            onChange={handleFileSelect}
            className="hidden"
            id="file-upload"
            disabled={uploading}
          />
          <label
            htmlFor="file-upload"
            className={`
              flex flex-col items-center justify-center
              w-20 h-20 border-2 border-dashed border-gray-300
              rounded-lg cursor-pointer hover:border-blue-500
              transition-colors duration-200
              ${uploading ? 'opacity-50 cursor-not-allowed' : ''}
            `}
          >
            {uploading ? (
              <div className="flex flex-col items-center">
                <div className="animate-spin rounded-full h-6 w-6 border-b-2 border-blue-500"></div>
                <span className="text-xs text-gray-500 mt-1">上传中</span>
              </div>
            ) : (
              <div className="flex flex-col items-center">
                <UpImg className="w-6 h-6 text-gray-400" />
                <span className="text-xs text-gray-500 mt-1">上传</span>
              </div>
            )}
          </label>
        </div>
      )}

      {/* 空状态提示 */}
      {files.length === 0 && !showUpload && (
        <div className="flex items-center justify-center w-20 h-20 border border-gray-200 rounded-lg">
          <span className="text-gray-400 text-xs">无图片</span>
        </div>
      )}
    </div>
  );
}
