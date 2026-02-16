import prisma from './prisma';
import { PasswordUtils } from './passwordUtils';

// 用户相关ORM操作
export class UserService {
  // 用户登录（支持昵称或邮箱）
  static async login(usernameOrEmail: string, password: string) {
    const user = await prisma.userInfo.findFirst({
      where: {
        OR: [
          { username: usernameOrEmail },
          { userEmail: usernameOrEmail }
        ]
      },
      select: {
        userId: true,
        userEmail: true,
        username: true,
        lover: true,
        score: true,
        password: true
      }
    });

    if (!user) {
      return null;
    }

    // 验证密码
    const isPasswordValid = await PasswordUtils.verifyPassword(password, user.password);
    
    if (!isPasswordValid) {
      return null;
    }

    // 返回用户信息（不包含密码）
    const { password: _, ...userInfo } = user;
    return userInfo;
  }

  // 用户注册 - 检查用户是否存在
  static async checkUserExists(userEmail: string, username: string) {
    return await prisma.userInfo.findFirst({
      where: {
        OR: [
          { userEmail },
          { username }
        ]
      },
      select: {
        userId: true
      }
    });
  }

  // 创建用户
  static async createUser(data: {
    userEmail: string;
    username: string;
    password: string;
    avatar: string;
    describeBySelf: string;
    lover: string;
  }) {
    // 加密密码
    const hashedPassword = await PasswordUtils.hashPassword(data.password);
    
    return await prisma.userInfo.create({
      data: {
        ...data,
        password: hashedPassword
      }
    });
  }

  // 根据邮箱获取用户信息
  static async getUserByEmail(userEmail: string) {
    return await prisma.userInfo.findUnique({
      where: { userEmail },
      select: {
        userId: true,
        userEmail: true,
        username: true,
        avatar: true,
        describeBySelf: true,
        lover: true,
        score: true,
        registrationTime: true
      }
    });
  }

  // 更新用户信息
  static async updateUser(userEmail: string, data: {
    username?: string;
    lover?: string;
    avatar?: string;
    describeBySelf?: string;
  }) {
    return await prisma.userInfo.update({
      where: { userEmail },
      data
    });
  }

  // 获取用户积分
  static async getUserScore(userEmail: string) {
    return await prisma.userInfo.findUnique({
      where: { userEmail },
      select: {
        score: true
      }
    });
  }

  // 获取关联者信息
  static async getLoverInfo(userEmail: string) {
    const user = await prisma.userInfo.findUnique({
      where: { userEmail },
      select: { lover: true }
    });

    if (!user || !user.lover) {
      return null;
    }

    return await prisma.userInfo.findUnique({
      where: { userEmail: user.lover },
      select: {
        username: true,
        avatar: true,
        userEmail: true,
        describeBySelf: true,
        score: true,
        registrationTime: true
      }
    });
  }

  // 添加积分
  static async addScore(userEmail: string, value: number) {
    return await prisma.userInfo.update({
      where: { userEmail },
      data: {
        score: {
          increment: value
        }
      },
      select: {
        score: true
      }
    });
  }

  // 扣减积分（包含积分不足检查）
  static async subtractScore(userEmail: string, value: number) {
    const user = await prisma.userInfo.findUnique({
      where: { userEmail },
      select: { score: true }
    });

    if (!user || user.score < value) {
      return { error: '积分不足，兑换失败' };
    }

    return await prisma.userInfo.update({
      where: { userEmail },
      data: {
        score: {
          decrement: value
        }
      },
      select: {
        score: true
      }
    });
  }
}

// 任务相关ORM操作
export class TaskService {
  // 获取任务列表（分页+搜索+状态筛选）
  static async getTaskList(params: {
    userEmail: string;
    lover: string;
    taskStatus?: string;
    searchWords?: string;
    offset: number;
    pageSize: number;
  }) {
    const { userEmail, lover, taskStatus, searchWords = '', offset, pageSize } = params;
    
    const where = {
      AND: [
        {
          OR: [
            { publisherEmail: userEmail },
            { publisherEmail: lover },
            { receiverEmail: userEmail }
          ]
        },
        taskStatus ? { taskStatus } : {},
        searchWords ? { taskName: { contains: searchWords } } : {}
      ]
    };

    const [tasks, totalCount] = await Promise.all([
      prisma.taskList.findMany({
        where,
        orderBy: { taskId: 'desc' },
        skip: offset,
        take: pageSize
      }),
      prisma.taskList.count({ where })
    ]);

    return { tasks, totalCount };
  }

  // 获取任务详情
  static async getTaskDetail(taskId: number) {
    return await prisma.taskList.findUnique({
      where: { taskId }
    });
  }

  // 检查任务收藏状态
  static async checkTaskFavourite(taskId: number, userEmail: string) {
    return await prisma.favouriteList.findFirst({
      where: {
        userEmail,
        collectionId: taskId.toString(),
        collectionType: 'task'
      }
    });
  }

  // 创建任务
  static async createTask(data: {
    publisherEmail: string;
    taskName: string;
    taskDesc: string;
    taskImage: string;
    taskScore: number;
    receiverEmail?: string;
  }) {
    return await prisma.taskList.create({
      data: {
        ...data,
        taskStatus: '未开始'
      }
    });
  }

  // 检查任务权限
  static async checkTaskPermission(taskId: number) {
    return await prisma.taskList.findUnique({
      where: { taskId },
      select: {
        publisherEmail: true,
        receiverEmail: true
      }
    });
  }

  // 更新任务
  static async updateTask(taskId: number, data: {
    taskStatus?: string;
    taskName?: string;
    taskDesc?: string;
    taskImage?: string;
    taskScore?: number;
  }) {
    return await prisma.taskList.update({
      where: { taskId },
      data
    });
  }

  // 删除任务
  static async deleteTask(taskId: number) {
    return await prisma.taskList.delete({
      where: { taskId }
    });
  }
}

// 礼物相关ORM操作
export class GiftService {
  // 获取可兑换礼物列表
  static async getAvailableGifts(searchWords: string = '') {
    return await prisma.giftList.findMany({
      where: {
        isShow: true,
        remained: { gt: 0 },
        giftName: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      },
      orderBy: { giftId: 'desc' }
    });
  }

  // 获取我的礼物列表
  static async getMyGifts(params: {
    userEmail: string;
    searchWords?: string;
    type?: string;
  }) {
    const { userEmail, searchWords = '', type } = params;
    
    let where: any = {
      publisherEmail: userEmail,
      giftName: { contains: searchWords }
    };

    // 根据类型筛选
    switch (type) {
      case '已上架':
        where.isShow = true;
        break;
      case '已下架':
        where.isShow = false;
        break;
      case '待使用':
        where.remained = { gt: 0 };
        break;
      case '已用完':
        where.remained = 0;
        break;
    }

    return await prisma.giftList.findMany({
      where,
      orderBy: { giftId: 'desc' }
    });
  }

  // 获取礼物详情
  static async getGiftDetail(giftId: number) {
    return await prisma.giftList.findUnique({
      where: { giftId },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      }
    });
  }

  // 创建礼物
  static async createGift(data: {
    publisherEmail: string;
    giftImg: string;
    giftName: string;
    giftDetail: string;
    needScore: number;
    remained: number;
    isShow?: boolean;
  }) {
    return await prisma.giftList.create({
      data
    });
  }

  // 检查礼物权限
  static async checkGiftPermission(giftId: number) {
    return await prisma.giftList.findUnique({
      where: { giftId },
      select: {
        publisherEmail: true
      }
    });
  }

  // 更新礼物
  static async updateGift(giftId: number, data: {
    giftName?: string;
    giftDetail?: string;
    needScore?: number;
    remained?: number;
    giftImg?: string;
    isShow?: boolean;
  }) {
    return await prisma.giftList.update({
      where: { giftId },
      data
    });
  }

  // 获取礼物信息（用于兑换检查）
  static async getGiftForExchange(giftId: number) {
    return await prisma.giftList.findUnique({
      where: { 
        giftId,
        isShow: true
      },
      select: {
        giftId: true,
        publisherEmail: true,
        needScore: true,
        remained: true
      }
    });
  }

  // 减少礼物库存
  static async decrementGiftStock(giftId: number) {
    return await prisma.giftList.update({
      where: { giftId },
      data: {
        remained: {
          decrement: 1
        }
      }
    });
  }

  // 上架/下架礼物
  static async toggleGiftShow(giftId: number, isShow: boolean) {
    return await prisma.giftList.update({
      where: { giftId },
      data: { isShow }
    });
  }
}

// 留言相关ORM操作
export class WhisperService {
  // 获取我的留言列表
  static async getMyWhispers(userEmail: string, searchWords: string = '') {
    return await prisma.whisperList.findMany({
      where: {
        publisherEmail: userEmail,
        title: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      },
      orderBy: { whisperId: 'desc' }
    });
  }

  // 获取TA的留言列表
  static async getTAWhispers(userEmail: string, lover: string, searchWords: string = '') {
    return await prisma.whisperList.findMany({
      where: {
        publisherEmail: lover,
        title: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      },
      orderBy: { whisperId: 'desc' }
    });
  }

  // 检查留言收藏状态
  static async checkWhisperFavourite(whisperId: number, userEmail: string) {
    return await prisma.favouriteList.findFirst({
      where: {
        userEmail,
        collectionId: whisperId.toString(),
        collectionType: 'whisper'
      }
    });
  }

  // 检查用户是否存在
  static async checkUserExists(userEmail: string) {
    return await prisma.userInfo.findUnique({
      where: { userEmail },
      select: { userEmail: true }
    });
  }

  // 创建留言
  static async createWhisper(data: {
    publisherEmail: string;
    toUserEmail: string;
    title: string;
    content: string;
  }) {
    return await prisma.whisperList.create({
      data
    });
  }

  // 检查留言权限
  static async checkWhisperPermission(whisperId: number) {
    return await prisma.whisperList.findUnique({
      where: { whisperId },
      select: {
        publisherEmail: true
      }
    });
  }

  // 删除留言
  static async deleteWhisper(whisperId: number) {
    return await prisma.whisperList.delete({
      where: { whisperId }
    });
  }
}

// 收藏相关ORM操作
export class FavouriteService {
  // 检查是否已收藏
  static async checkFavouriteExists(userEmail: string, collectionId: string, collectionType: string) {
    return await prisma.favouriteList.findFirst({
      where: {
        userEmail,
        collectionId,
        collectionType
      },
      select: {
        favId: true
      }
    });
  }

  // 验证收藏对象是否存在
  static async validateCollectionItem(collectionId: string, collectionType: string) {
    const numericId = parseInt(collectionId, 10);
    if (isNaN(numericId)) {
      return null;
    }
    
    switch (collectionType) {
      case 'task':
        return await prisma.taskList.findUnique({
          where: { taskId: numericId },
          select: { taskId: true }
        });
      case 'gift':
        return await prisma.giftList.findUnique({
          where: { giftId: numericId },
          select: { giftId: true }
        });
      case 'whisper':
        return await prisma.whisperList.findUnique({
          where: { whisperId: numericId },
          select: { whisperId: true }
        });
      default:
        return null;
    }
  }

  // 添加收藏
  static async addFavourite(data: {
    userEmail: string;
    collectionId: string;
    collectionType: string;
  }) {
    return await prisma.favouriteList.create({
      data
    });
  }

  // 移除收藏
  static async removeFavourite(userEmail: string, collectionId: string, collectionType: string) {
    return await prisma.favouriteList.deleteMany({
      where: {
        userEmail,
        collectionId,
        collectionType
      }
    });
  }

  // 获取任务收藏列表
  static async getTaskFavourites(userEmail: string, searchWords: string = '') {
    const favourites = await prisma.favouriteList.findMany({
      where: {
        userEmail,
        collectionType: 'task'
      },
      orderBy: { favId: 'desc' }
    });

    // 获取任务详情
    const taskIds = favourites.map(fav => parseInt(fav.collectionId, 10)).filter(id => !isNaN(id));
    const tasks = await prisma.taskList.findMany({
      where: {
        taskId: { in: taskIds },
        taskName: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      }
    });

    // 合并收藏信息和任务信息
    return favourites.map(fav => ({
      ...fav,
      task: tasks.find(task => task.taskId === parseInt(fav.collectionId, 10))
    })).filter(item => item.task);
  }

  // 获取礼物收藏列表
  static async getGiftFavourites(userEmail: string, searchWords: string = '') {
    const favourites = await prisma.favouriteList.findMany({
      where: {
        userEmail,
        collectionType: 'gift'
      },
      orderBy: { favId: 'desc' }
    });

    // 获取礼物详情
    const giftIds = favourites.map(fav => parseInt(fav.collectionId, 10)).filter(id => !isNaN(id));
    const gifts = await prisma.giftList.findMany({
      where: {
        giftId: { in: giftIds },
        giftName: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      }
    });

    // 合并收藏信息和礼物信息
    return favourites.map(fav => ({
      ...fav,
      gift: gifts.find(gift => gift.giftId === parseInt(fav.collectionId, 10))
    })).filter(item => item.gift);
  }

  // 获取留言收藏列表
  static async getWhisperFavourites(userEmail: string, searchWords: string = '') {
    const favourites = await prisma.favouriteList.findMany({
      where: {
        userEmail,
        collectionType: 'whisper'
      },
      orderBy: { favId: 'desc' }
    });

    // 获取留言详情
    const whisperIds = favourites.map(fav => parseInt(fav.collectionId, 10)).filter(id => !isNaN(id));
    const whispers = await prisma.whisperList.findMany({
      where: {
        whisperId: { in: whisperIds },
        title: { contains: searchWords }
      },
      include: {
        publisher: {
          select: {
            username: true
          }
        }
      }
    });

    // 合并收藏信息和留言信息
    return favourites.map(fav => ({
      ...fav,
      whisper: whispers.find(whisper => whisper.whisperId === parseInt(fav.collectionId, 10))
    })).filter(item => item.whisper);
  }
}
