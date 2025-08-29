import { PrismaClient } from '../../generated/prisma';

const prisma = new PrismaClient();

// 配置类型枚举
export enum ConfigType {
  IMAGE_BED = 'image_bed',
  NOTIFICATION = 'notification',
  OTHER = 'other'
}

// 图床配置接口
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
}

// 通知配置接口
export interface NotificationConfig {
  id: string;
  notifyType: string;
  notifyName: string;
  webhookUrl: string | null;
  apiKey: string | null;
  isActive: boolean;
  description: string | null;
}

// 系统配置接口
export interface SystemConfig {
  id: string;
  configKey: string;
  configValue: string;
  configType: string;
  description?: string;
  isActive: boolean;
}

export class ConfigService {
  // 获取系统配置
  static async getSystemConfig(key: string): Promise<string | null> {
    try {
      const config = await prisma.systemConfig.findFirst({
        where: {
          configKey: key,
          isActive: true
        }
      });
      return config?.configValue || null;
    } catch (error) {
      console.error('获取系统配置失败:', error);
      return null;
    }
  }

  // 设置系统配置
  static async setSystemConfig(key: string, value: string, type: ConfigType, description?: string): Promise<boolean> {
    try {
      await prisma.systemConfig.upsert({
        where: { configKey: key },
        update: {
          configValue: value,
          configType: type,
          description,
          updatedAt: new Date()
        },
        create: {
          configKey: key,
          configValue: value,
          configType: type,
          description,
          isActive: true
        }
      });
      return true;
    } catch (error) {
      console.error('设置系统配置失败:', error);
      return false;
    }
  }

  // 获取默认图床配置
  static async getDefaultImageBed(): Promise<ImageBedConfig | null> {
    try {
      const config = await prisma.imageBedConfig.findFirst({
        where: {
          isDefault: true,
          isActive: true
        },
        orderBy: {
          priority: 'desc'
        }
      });
      return config;
    } catch (error) {
      console.error('获取默认图床配置失败:', error);
      return null;
    }
  }

  // 获取指定图床配置
  static async getImageBedConfig(bedName: string): Promise<ImageBedConfig | null> {
    try {
      const config = await prisma.imageBedConfig.findFirst({
        where: {
          bedName,
          isActive: true
        }
      });
      return config;
    } catch (error) {
      console.error('获取图床配置失败:', error);
      return null;
    }
  }

  // 获取所有图床配置
  static async getAllImageBedConfigs(): Promise<ImageBedConfig[]> {
    try {
      const configs = await prisma.imageBedConfig.findMany({
        where: {
          isActive: true
        },
        orderBy: [
          { isDefault: 'desc' },
          { priority: 'desc' }
        ]
      });
      return configs;
    } catch (error) {
      console.error('获取所有图床配置失败:', error);
      return [];
    }
  }

  // 设置图床配置
  static async setImageBedConfig(config: Omit<ImageBedConfig, 'id' | 'createdAt' | 'updatedAt'>): Promise<boolean> {
    try {
      await prisma.imageBedConfig.upsert({
        where: { bedName: config.bedName },
        update: {
          bedType: config.bedType,
          apiUrl: config.apiUrl,
          apiKey: config.apiKey,
          authHeader: config.authHeader,
          isActive: config.isActive,
          isDefault: config.isDefault,
          priority: config.priority,
          description: config.description,
          updatedAt: new Date()
        },
        create: {
          bedName: config.bedName,
          bedType: config.bedType,
          apiUrl: config.apiUrl,
          apiKey: config.apiKey,
          authHeader: config.authHeader,
          isActive: config.isActive,
          isDefault: config.isDefault,
          priority: config.priority,
          description: config.description
        }
      });

      // 如果设置为默认图床，需要将其他图床设为非默认
      if (config.isDefault) {
        await prisma.imageBedConfig.updateMany({
          where: {
            bedName: { not: config.bedName }
          },
          data: {
            isDefault: false
          }
        });
      }

      return true;
    } catch (error) {
      console.error('设置图床配置失败:', error);
      return false;
    }
  }

  // 获取通知配置
  static async getNotificationConfig(notifyType: string): Promise<NotificationConfig | null> {
    try {
      const config = await prisma.notificationConfig.findFirst({
        where: {
          notifyType,
          isActive: true
        }
      });
      return config;
    } catch (error) {
      console.error('获取通知配置失败:', error);
      return null;
    }
  }

  // 获取所有通知配置
  static async getAllNotificationConfigs(): Promise<NotificationConfig[]> {
    try {
      const configs = await prisma.notificationConfig.findMany({
        where: {
          isActive: true
        },
        orderBy: {
          notifyType: 'asc'
        }
      });
      return configs;
    } catch (error) {
      console.error('获取所有通知配置失败:', error);
      return [];
    }
  }

  // 设置通知配置
  static async setNotificationConfig(config: Omit<NotificationConfig, 'id' | 'createdAt' | 'updatedAt'>): Promise<boolean> {
    try {
      await prisma.notificationConfig.upsert({
        where: { notifyType: config.notifyType },
        update: {
          notifyName: config.notifyName,
          webhookUrl: config.webhookUrl,
          apiKey: config.apiKey,
          isActive: config.isActive,
          description: config.description,
          updatedAt: new Date()
        },
        create: {
          notifyType: config.notifyType,
          notifyName: config.notifyName,
          webhookUrl: config.webhookUrl,
          apiKey: config.apiKey,
          isActive: config.isActive,
          description: config.description
        }
      });
      return true;
    } catch (error) {
      console.error('设置通知配置失败:', error);
      return false;
    }
  }

  // 初始化默认配置
  static async initializeDefaultConfigs(): Promise<void> {
    try {
      // 初始化默认图床配置
      const defaultImageBeds = [
        {
          bedName: 'SM',
          bedType: 'smms',
          apiUrl: 'https://sm.ms/api/v2/upload',
          apiKey: null,
          authHeader: 'Authorization',
          isActive: true,
          isDefault: true,
          priority: 100,
          description: 'SM.MS图床'
        },
        {
          bedName: 'IMGBB',
          bedType: 'imgbb',
          apiUrl: 'https://api.imgbb.com/1/upload',
          apiKey: null,
          authHeader: null,
          isActive: true,
          isDefault: false,
          priority: 50,
          description: 'ImgBB图床'
        }
      ];

      for (const bed of defaultImageBeds) {
        await this.setImageBedConfig(bed);
      }

      // 初始化默认通知配置
      const defaultNotifications = [
        {
          notifyType: 'wx_robot',
          notifyName: '企业微信机器人',
          webhookUrl: null,
          apiKey: null,
          isActive: true,
          description: '企业微信机器人通知'
        }
      ];

      for (const notification of defaultNotifications) {
        await this.setNotificationConfig(notification);
      }

      console.log('默认配置初始化完成');
    } catch (error) {
      console.error('初始化默认配置失败:', error);
    }
  }
}
