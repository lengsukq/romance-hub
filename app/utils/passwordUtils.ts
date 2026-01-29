import bcrypt from 'bcryptjs';

/**
 * 密码加密工具类
 */
export class PasswordUtils {
  /**
   * 加密密码
   * @param password 明文密码
   * @returns 加密后的密码
   */
  static async hashPassword(password: string): Promise<string> {
    const saltRounds = 12; // 加密强度，数值越高越安全但越慢
    return await bcrypt.hash(password, saltRounds);
  }

  /**
   * 验证密码
   * @param password 明文密码
   * @param hashedPassword 加密后的密码
   * @returns 是否匹配
   */
  static async verifyPassword(password: string, hashedPassword: string): Promise<boolean> {
    return await bcrypt.compare(password, hashedPassword);
  }

  /**
   * 检查密码强度
   * @param password 密码
   * @returns 密码强度信息
   */
  static checkPasswordStrength(password: string): {
    isValid: boolean;
    score: number;
    message: string;
  } {
    if (!password) {
      return {
        isValid: false,
        score: 0,
        message: '密码不能为空'
      };
    }

    if (password.length < 6) {
      return {
        isValid: false,
        score: 1,
        message: '密码长度至少6位'
      };
    }

    let score = 0;
    const messages: string[] = [];

    // 长度检查
    if (password.length >= 8) score += 1;
    if (password.length >= 12) score += 1;

    // 字符类型检查
    if (/[a-z]/.test(password)) score += 1;
    if (/[A-Z]/.test(password)) score += 1;
    if (/[0-9]/.test(password)) score += 1;
    if (/[^a-zA-Z0-9]/.test(password)) score += 1;

    // 生成提示信息
    if (score < 3) {
      messages.push('密码强度较弱');
    } else if (score < 5) {
      messages.push('密码强度中等');
    } else {
      messages.push('密码强度较强');
    }

    return {
      isValid: password.length >= 6,
      score,
      message: messages.join('，')
    };
  }
}
