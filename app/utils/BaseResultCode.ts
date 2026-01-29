/**
 * @author ycx
 * @description 业务异常通用code
 */
class BaseResultCode {
    /**
     * code
     */
    public code: number;
    /**
     * 说明
     */
    public desc: string;

    static SUCCESS = new BaseResultCode(200, '成功');
    static FAILED = new BaseResultCode(500, '系统异常');
    static VALIDATE_FAILED = new BaseResultCode(400, '参数校验失败');

    /************************************/
    static API_NOT_FOUNT = new BaseResultCode(404, '接口不存在');
    static API_BUSY = new BaseResultCode(700, '操作过于频繁');
    /***********************************/

    constructor(code: number, desc: string) {
        this.code = code;
        this.desc = desc;
    }
}

export default BaseResultCode;
