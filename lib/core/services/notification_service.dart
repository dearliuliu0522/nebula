import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 本地通知封装类（单例模式），用于显示：
/// 1. 下载进度通知
/// 2. 下载完成通知
/// 3. 下载错误通知
/// 4. 取消通知
/// 整体设计优点：
/// 1. 单例封装
/// 2. 跨平台初始化
/// 3. Channel 分离
/// 4. 可更新通知
/// 5. 防崩溃处理
class NotificationService {
  // 创建单例
  static final NotificationService _instance = NotificationService._internal();
  // factory 构造函数，无论调用多少次，都返回同一个对象
  factory NotificationService() => _instance;
  // 私有构造函数，防止外部直接new
  NotificationService._internal();

  // 通知插件对象，所有通知操作都通过它
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // 初始化，必须在app启动时调用
  Future<void> init() async {
    // android 初始化配置，使用 launcher icon 作为通知图标。
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    // iOS/macOS 初始化配置
    const iosSettings = DarwinInitializationSettings();

    // Linux 初始化配置
    final linuxSettings = const LinuxInitializationSettings(
      defaultActionName: 'Open notification',
    );

    // 合并初始化配置
    final settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
      linux: linuxSettings,
    );

    // 初始化插件。启动通知系统，监听用户点击通知
    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Handle tap
      },
    );

    // android 权限请求。Android 13+ 需要动态申请通知权限
    await _notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  // 显示下载进度条通知
  Future<void> showProgress(
    int id,
    String title,
    String body,
    int progress,
    int max,
  ) async {
    // onlyAlertOnce：避免每次进度更新都响铃；showProgress：显示进度条
    final androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.low,
      priority: Priority.low,
      onlyAlertOnce: true,
      showProgress: true,
      maxProgress: max,
      progress: progress,
    );

    final details = NotificationDetails(android: androidDetails);

    try {
      // 显示通知，相同 id = 更新同一个通知
      await _notifications.show(id, title, body, details);
    } catch (e) {
      // Ignore notification errors (especially on Windows where plugin might fail)
      // debugPrint("Notification error: $e");
    }
  }

  // 下载完成通知
  Future<void> showCompletion(int id, String title, String body) async {
    // 弹出、声音、高优先级，不显示进度条
    const androidDetails = AndroidNotificationDetails(
      'downloads_channel',
      'Downloads',
      channelDescription: 'Download progress notifications',
      importance: Importance.high,
      priority: Priority.high,
      // No progress bar
    );

    final details = const NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(id, title, body, details);
    } catch (e) {
      // Ignore errors
    }
  }

  // 下载失败通知
  Future<void> showError(int id, String title, String body) async {
    // 使用不同 channel，错误通知单独分类
    const androidDetails = AndroidNotificationDetails(
      'downloads_error_channel',
      'Download Errors',
      channelDescription: 'Notifications for failed downloads',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = const NotificationDetails(android: androidDetails);

    try {
      await _notifications.show(id, title, body, details);
    } catch (e) {
      // Ignore errors
    }
  }

  // 取消指定通知
  Future<void> cancel(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (e) {
      // Ignore errors
    }
  }
}
