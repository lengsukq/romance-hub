// 验证值类型
type ValidateValue = string | Record<string, any>;

// 非空校验
export function isInvalidFn(key: ValidateValue, regex?: RegExp): boolean {
    if (typeof key === 'string') {
        if (regex) {
            return !regex.test(key);
        } else {
            return key === "";
        }
    } else if (typeof key === 'object' && key !== null) {
        return Object.values(key).includes("");
    }
    return false;
}

// 输入数字校验为0或正整数
export function numberInvalidFn(key: string | number): boolean {
    if (key === "") return true;
    const validateNumber = (key: string | number): RegExpMatchArray | null => 
        key.toString().match(/^[0-9]*$/);
    return !validateNumber(key);
}

// 邮箱校验
export function eMailInvalidFn(key: string): boolean {
    if (key === "") return true;
    const validateEmail = (key: string): RegExpMatchArray | null => 
        key.match(/^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,4}$/i);
    return !validateEmail(key);
}

// 相同校验
export function sameInvalidFn(key: string, key2: string): boolean {
    if (key === "") return true;
    return key !== key2;
}

// 快速设置本地缓存-对象  对象名，属性名，新值
export function setLocalData(objName: string, attName: string, value: any): void {
    try {
        const dataStr = localStorage.getItem(objName);
        if (!dataStr) {
            console.warn(`本地缓存中未找到对象: ${objName}`);
            return;
        }
        
        const data = JSON.parse(dataStr);
        data[attName] = value;
        localStorage.setItem(objName, JSON.stringify(data));
    } catch (error) {
        console.error('设置本地缓存失败:', error);
    }
}

// 快速获取本地缓存
export function getLocalData(objName: string, attName: string): any {
    try {
        const dataStr = localStorage.getItem(objName);
        if (!dataStr) {
            console.warn(`本地缓存中未找到对象: ${objName}`);
            return null;
        }
        
        const data = JSON.parse(dataStr);
        return data[attName];
    } catch (error) {
        console.error('获取本地缓存失败:', error);
        return null;
    }
}

// 退出，清除本地所有缓存和cookie
export function clearLocalData(): void {
    try {
        localStorage.clear();
        document.cookie.split(';').forEach(item => {
            const trimmedItem = item.replace(/(^\s*)|(\s*$)/g, '');
            const cookieName = trimmedItem.split('=')[0];
            if (cookieName) {
                document.cookie = `${cookieName}=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;`;
            }
        });
    } catch (error) {
        console.error('清除本地数据失败:', error);
    }
}