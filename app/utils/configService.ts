import prisma from './prisma';
import { UserService } from './ormService';

// 配置接口定义
export interface SystemConfig {
  id: string;
  configKey: string;
  configValue: string;
  configType: string;
  description?: string;
  isActive: boolean;
  createdAt: Date;
  updatedAt: Date;
  userEmail: string;
}

export interface ImageBedConfig {
  id: string;
  bedName: string;
  bedType: string;
  apiUrl: string;
  apiKey: string | null;
  authHeader: string | null;
  isActive: boolean;
  isDefault: boolean;
  priority: number;
  description: string | null;
  createdAt: Date;
  updatedAt: Date;
  userEmail: string | null;
}

export interface NotificationConfig {
  id: string;
  notifyType: string;
  notifyName: string;
  webhookUrl: string | null;
  apiKey: string | null;
  isActive: boolean;
  description: string | null;
  createdAt: Date;
  updatedAt: Date;
  userEmail: string | null;
}

export class ConfigService {
  // 获取系统配置
  static async getSystemConfig(configKey: string, userEmail: string): Promise<string | null> {
    try {
      const config = await prisma.systemConfig.findUnique({
        where: {
          configKey_userEmail: {
            configKey,
            userEmail
          }
        }
      });
      return config?.configValue || null;
    } catch (error) {
      console.error('获取系统配置失败:', error);
      return null;
    }
  }

  // 获取默认图床配置
  static async getDefaultImageBed(userEmail: string): Promise<ImageBedConfig | null> {
    try {
      const bed = await prisma.imageBedConfig.findFirst({
        where: {
          userEmail,
          isDefault: true,
          isActive: true
        },
        orderBy: { priority: 'desc' }
      });
      return bed;
    } catch (error) {
      console.error('获取默认图床配置失败:', error);
      return null;
    }
  }

  // 获取图床配置
  static async getImageBedConfig(bedName: string, userEmail: string): Promise<ImageBedConfig | null> {
    try {
      const bed = await prisma.imageBedConfig.findUnique({
        where: {
          bedName_userEmail: {
            bedName,
            userEmail
          }
        }
      });
      return bed;
    } catch (error) {
      console.error('获取图床配置失败:', error);
      return null;
    }
  }

  // 获取通知配置
  static async getNotificationConfig(notifyType: string, userEmail: string): Promise<NotificationConfig | null> {
    try {
      const config = await prisma.notificationConfig.findUnique({
        where: {
          notifyType_userEmail: {
            notifyType,
            userEmail
          }
        }
      });
      return config;
    } catch (error) {
      console.error('获取通知配置失败:', error);
      return null;
    }
  }

  // 获取所有图床配置
  static async getAllImageBedConfigs(userEmail: string): Promise<ImageBedConfig[]> {
    try {
      return await prisma.imageBedConfig.findMany({
        where: { userEmail },
        orderBy: [
          { isDefault: 'desc' },
          { priority: 'desc' },
          { createdAt: 'desc' }
        ]
      });
    } catch (error) {
      console.error('获取所有图床配置失败:', error);
      return [];
    }
  }

  // 获取所有通知配置
  static async getAllNotificationConfigs(userEmail: string): Promise<NotificationConfig[]> {
    try {
      return await prisma.notificationConfig.findMany({
        where: { userEmail },
        orderBy: { createdAt: 'desc' }
      });
    } catch (error) {
      console.error('获取所有通知配置失败:', error);
      return [];
    }
  }

  // 设置系统配置（自动同步到lover）
  static async setSystemConfig(configKey: string, configValue: string, configType: string, description: string, userEmail: string): Promise<boolean> {
    try {
      // 获取lover邮箱
      const loverEmail = await this.getLoverEmail(userEmail);
      
      // 设置用户配置
      await prisma.systemConfig.upsert({
        where: {
          configKey_userEmail: {
            configKey,
            userEmail
          }
        },
        update: {
          configValue,
          configType,
          description,
          updatedAt: new Date()
        },
        create: {
          configKey,
          configValue,
          configType,
          description,
          userEmail
        }
      });

      // 如果有lover，同步到lover
      if (loverEmail) {
        await prisma.systemConfig.upsert({
          where: {
            configKey_userEmail: {
              configKey,
              userEmail: loverEmail
            }
          },
          update: {
            configValue,
            configType,
            description,
            updatedAt: new Date()
          },
          create: {
            configKey,
            configValue,
            configType,
            description,
            userEmail: loverEmail
          }
        });
      }

      return true;
    } catch (error) {
      console.error('设置系统配置失败:', error);
      return false;
    }
  }

  // 设置图床配置（自动同步到lover）
  static async setImageBedConfig(bedName: string, bedType: string, apiUrl: string, apiKey: string, authHeader: string, isDefault: boolean, priority: number, description: string, userEmail: string): Promise<boolean> {
    try {
      // 获取lover邮箱
      const loverEmail = await this.getLoverEmail(userEmail);
      
      // 设置用户配置
      await prisma.imageBedConfig.upsert({
        where: {
          bedName_userEmail: {
            bedName,
            userEmail
          }
        },
        update: {
          bedType,
          apiUrl,
          apiKey,
          authHeader,
          isDefault,
          priority,
          description,
          updatedAt: new Date()
        },
        create: {
          bedName,
          bedType,
          apiUrl,
          apiKey,
          authHeader,
          isDefault,
          priority,
          description,
          userEmail
        }
      });

      // 如果有lover，同步到lover
      if (loverEmail) {
        await prisma.imageBedConfig.upsert({
          where: {
            bedName_userEmail: {
              bedName,
              userEmail: loverEmail
            }
          },
          update: {
            bedType,
            apiUrl,
            apiKey,
            authHeader,
            isDefault,
            priority,
            description,
            updatedAt: new Date()
          },
          create: {
            bedName,
            bedType,
            apiUrl,
            apiKey,
            authHeader,
            isDefault,
            priority,
            description,
            userEmail: loverEmail
          }
        });
      }

      return true;
    } catch (error) {
      console.error('设置图床配置失败:', error);
      return false;
    }
  }

  // 设置通知配置（自动同步到lover）
  static async setNotificationConfig(notifyType: string, notifyName: string, webhookUrl: string, apiKey: string, description: string, userEmail: string): Promise<boolean> {
    try {
      // 获取lover邮箱
      const loverEmail = await this.getLoverEmail(userEmail);
      
      // 设置用户配置
      await prisma.notificationConfig.upsert({
        where: {
          notifyType_userEmail: {
            notifyType,
            userEmail
          }
        },
        update: {
          notifyName,
          webhookUrl,
          apiKey,
          description,
          updatedAt: new Date()
        },
        create: {
          notifyType,
          notifyName,
          webhookUrl,
          apiKey,
          description,
          userEmail
        }
      });

      // 如果有lover，同步到lover
      if (loverEmail) {
        await prisma.notificationConfig.upsert({
          where: {
            notifyType_userEmail: {
              notifyType,
              userEmail: loverEmail
            }
          },
          update: {
            notifyName,
            webhookUrl,
            apiKey,
            description,
            updatedAt: new Date()
          },
          create: {
            notifyType,
            notifyName,
            webhookUrl,
            apiKey,
            description,
            userEmail: loverEmail
          }
        });
      }

      return true;
    } catch (error) {
      console.error('设置通知配置失败:', error);
      return false;
    }
  }

  // 初始化默认配置
  static async initializeDefaultConfigs(userEmail: string): Promise<boolean> {
    try {
      // 初始化系统配置
      const systemConfigs = [
        { key: 'WEB_URL', value: 'http://localhost:3000', type: 'other', description: '网站URL' },
        { key: 'UPLOAD_PATH', value: '/uploads', type: 'other', description: '上传路径' }
      ];

      for (const config of systemConfigs) {
        await this.setSystemConfig(config.key, config.value, config.type, config.description, userEmail);
      }

      // 初始化图床配置
      const imageBedConfigs = [
        {
          name: 'SM.MS',
          type: 'smms',
          apiUrl: 'https://sm.ms/api/v2/upload',
          apiKey: '',
          authHeader: 'Authorization',
          isDefault: true,
          priority: 100,
          description: 'SM.MS图床'
        }
      ];

      for (const bed of imageBedConfigs) {
        await this.setImageBedConfig(
          bed.name,
          bed.type,
          bed.apiUrl,
          bed.apiKey,
          bed.authHeader,
          bed.isDefault,
          bed.priority,
          bed.description,
          userEmail
        );
      }

      // 初始化通知配置
      const notificationConfigs = [
        {
          type: 'wx_robot',
          name: '微信机器人',
          webhookUrl: '',
          apiKey: '',
          description: '微信机器人通知'
        }
      ];

      for (const notify of notificationConfigs) {
        await this.setNotificationConfig(
          notify.type,
          notify.name,
          notify.webhookUrl,
          notify.apiKey,
          notify.description,
          userEmail
        );
      }

      return true;
    } catch (error) {
      console.error('初始化默认配置失败:', error);
      return false;
    }
  }

  // 获取lover邮箱
  private static async getLoverEmail(userEmail: string): Promise<string | null> {
    try {
      const user = await prisma.userInfo.findUnique({
        where: { userEmail },
        select: { lover: true }
      });
      return user?.lover || null;
    } catch (error) {
      console.error('获取lover邮箱失败:', error);
      return null;
    }
  }
}
