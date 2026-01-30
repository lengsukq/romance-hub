/// 统一路由管理
/// 所有路径与命名集中在此，避免魔法字符串
class AppRoutes {
  AppRoutes._();

  // ---------- 路径常量 ----------
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/index';

  static const String tasks = '/tasks';
  static const String postTask = '/post-task';
  static const String taskDetailPrefix = '/task';

  static const String gifts = '/gifts';
  static const String myGifts = '/my-gifts';
  static const String addGift = '/add-gift';

  static const String whispersPrefix = '/whispers';
  static const String postWhisper = '/post-whisper';

  static const String favouritesPrefix = '/favourites';

  static const String userInfo = '/user-info';
  static const String config = '/config';

  // ---------- 路由命名（用于 goNamed） ----------
  static const String nameLogin = 'login';
  static const String nameRegister = 'register';
  static const String nameHome = 'home';
  static const String nameTaskList = 'taskList';
  static const String nameTaskDetail = 'taskDetail';
  static const String namePostTask = 'postTask';
  static const String nameGiftList = 'giftList';
  static const String nameMyGiftList = 'myGiftList';
  static const String nameAddGift = 'addGift';
  static const String nameWhisperList = 'whisperList';
  static const String namePostWhisper = 'postWhisper';
  static const String nameFavouriteList = 'favouriteList';
  static const String nameUserInfo = 'userInfo';
  static const String nameConfig = 'config';

  // ---------- 带参数路径 ----------
  /// 任务详情：/task/:taskId
  static String taskDetail(int taskId) => '$taskDetailPrefix/$taskId';

  /// 留言列表：/whispers?type=my|ta
  static String whisperList({String type = 'my'}) =>
      '$whispersPrefix?type=$type';

  /// 收藏列表：/favourites?type=task|gift|whisper
  static String favouriteList({String type = 'task'}) =>
      '$favouritesPrefix?type=$type';

  // ---------- 初始页（未登录 / 已登录） ----------
  static const String initialLocation = login;
}
