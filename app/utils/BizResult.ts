import BaseResultCode from './BaseResultCode';

/**
 * @author ycx
 * @description 统一返回结果
 */
class BizResult<T = any> {
    /**
     * 返回code
     */
    public code: number;
    /**
     * 返回消息
     */
    public msg: string;
    /**
     * 返回数据
     */
    public data: T;
    /**
     * 返回时间
     */
    public time: number;

    /**
     * @param code 返回code
     * @param msg 返回消息
     * @param data 返回具体对象
     */
    constructor(code: number, msg: string, data: T) {
        this.code = code;
        this.msg = msg;
        this.data = data;
        this.time = Date.now();
    }

    /**
     * 成功
     * @param data 返回对象
     * @param msg 自定义message
     * @return BizResult
     */
    static success<T = any>(data: T, msg: string = BaseResultCode.SUCCESS.desc): BizResult<T> {
        return new BizResult(BaseResultCode.SUCCESS.code, msg, data);
    }

    /**
     * 失败
     * @param errData 错误数据
     * @param msg 自定义message
     * @return BizResult
     */
    static fail<T = any>(errData: T, msg: string = BaseResultCode.FAILED.desc): BizResult<T> {
        return new BizResult(BaseResultCode.FAILED.code, msg, errData);
    }

    /**
     * 参数校验失败
     * @param param 参数
     * @param msg 自定义message
     * @return BizResult
     */
    static validateFailed<T = any>(param: T, msg: string = BaseResultCode.VALIDATE_FAILED.desc): BizResult<T> {
        return new BizResult(BaseResultCode.VALIDATE_FAILED.code, msg, param);
    }
}

export default BizResult;
