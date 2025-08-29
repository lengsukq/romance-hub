'use client'
import { Notify } from './notificationUtils';

// 基础响应接口
interface BaseResponse {
  code: number;
  msg: string;
  data?: any;
}

// HTTP选项接口
interface HttpOptions {
  method?: string;
  headers?: HeadersInit;
  credentials?: RequestCredentials;
  mode?: RequestMode;
  body?: string | FormData;
  type?: string;
  Type?: string;
}

// 请求参数接口
interface RequestParams {
  [key: string]: any;
}

const checkStatus = (res: Response): Response => {
  if (res.status >= 200 && res.status < 300) {
    return res;
  }
  Notify.show({ type: 'warning', message: `网络请求失败,${res.status}` });
  const error = new Error(res.statusText);
  (error as any).response = res;
  throw error;
};

/**
 * 捕获成功登录过期状态码等
 * @param res
 * @returns {Promise<Response>}
 */
const judgeOkState = async (res: Response): Promise<Response> => {
  const cloneRes: BaseResponse = await res.clone().json();
  // console.log('judgeOkState', cloneRes)
  // if (cloneRes.msg=== '登录过期'){
  // }
  //TODO:可以在这里管控全局请求
  if (!!cloneRes.code && cloneRes.code !== 200) {
    Notify.show({ type: 'warning', message: `${cloneRes.msg}${cloneRes.code}` });
  }
  return res;
};

/**
 * 捕获失败
 * @param error
 * @returns {BaseResponse}
 */
const handleError = (error: Error): BaseResponse => {
  if (error instanceof TypeError) {
    Notify.show({ type: 'warning', message: `网络请求失败,${error}` });
  }
  return {   //防止页面崩溃，因为每个接口都有判断res.code以及data
    code: -1,
    msg: '网络请求失败',
    data: false,
  };
};

class HttpClass {
    /**
     * 静态的fetch请求通用方法
     * @param url
     * @param options
     * @returns {Promise<BaseResponse>}
     */
    static async staticFetch(url: string = '', options: HttpOptions = {}): Promise<BaseResponse> {
        const defaultOptions: HttpOptions = {
            /*允许携带cookies*/
            credentials: 'include',
            /*允许跨域**/
            mode: 'cors',
            headers: {},
        };
        // 无headers配置 使用默认请求头，当上传类型为FormData时，默认不设置请求头，否则报错
        if ((options.method === 'POST' || options.method === 'PUT') && options.Type !== 'FormData') {
            if (defaultOptions.headers) {
                if (defaultOptions.headers instanceof Headers) {
                    defaultOptions.headers.set('Content-Type', 'application/json; charset=utf-8');
                } else if (Array.isArray(defaultOptions.headers)) {
                    defaultOptions.headers.push(['Content-Type', 'application/json; charset=utf-8']);
                } else {
                    defaultOptions.headers['Content-Type'] = 'application/json; charset=utf-8';
                }
            } else {
                defaultOptions.headers = { 'Content-Type': 'application/json; charset=utf-8' };
            }
        }
        const newOptions = { ...defaultOptions, ...options };
        return fetch(url, newOptions)
            .then(checkStatus)
            .then(judgeOkState)
            .then(res => res.json())
            .catch(handleError);
    }

    /**
     * post请求方式
     * @param url
     * @param params
     * @param option
     * @returns {Promise<BaseResponse>}
     */
    post(url: string, params: RequestParams = {}, option: HttpOptions = {}): Promise<BaseResponse> {
        const options = Object.assign({ method: 'POST' }, option);

        //可以是上传键值对形式，也可以是文件，使用append创造键值对数据
        if (options.type === 'FormData' && options.body !== undefined) {
            const formData = new FormData();
            for (const key of Object.keys(options.body as Record<string, any>)) {
                formData.append(key, (options.body as Record<string, any>)[key]);
            }
            options.body = formData;
        } else {
            //一般我们常用场景用的是json，所以需要在headers加Content-Type类型
            options.body = JSON.stringify(params);
        }
        return HttpClass.staticFetch(url, options); //类的静态方法只能通过类本身调用
    }

    /**
     * put方法
     * @param url
     * @param params
     * @param option
     * @returns {Promise<BaseResponse>}
     */
    put(url: string, params: RequestParams = {}, option: HttpOptions = {}): Promise<BaseResponse> {
        const options = Object.assign({ method: 'PUT' }, option);
        options.body = JSON.stringify(params);
        return HttpClass.staticFetch(url, options); //类的静态方法只能通过类本身调用
    }

    /**
     * get请求方式
     * @param url
     * @param params
     * @param option
     * @returns {Promise<BaseResponse>}
     */
    async get(url: string, params: RequestParams, option: HttpOptions = {}): Promise<BaseResponse> {
        // 将params对象转换为查询字符串
        const queryString = new URLSearchParams(params).toString();
        // 将查询字符串附加到URL上
        const fullUrl = `${url}?${queryString}`;

        // 合并默认选项和提供的选项
        const options = Object.assign({ method: 'GET' }, option);
        // 使用完整的URL和选项进行请求
        return await HttpClass.staticFetch(fullUrl, options);
    }

    /**
     * delete请求方式
     * @param url
     * @param option
     * @returns {Promise<BaseResponse>}
     */
    deleteAct(url: string, option: HttpOptions = {}): Promise<BaseResponse> {
        const options = Object.assign({ method: 'DELETE' }, option);
        return HttpClass.staticFetch(url, options);
    }
}

const requestFun = new HttpClass(); //new生成实例
export const { post, get, deleteAct } = requestFun;
export default requestFun;
