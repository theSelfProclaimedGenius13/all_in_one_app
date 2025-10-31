import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // 1. Create the plugin instance
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // 2. Define Android notification channel
  final AndroidNotificationChannel _channel = const AndroidNotificationChannel(
    'pomodoro_channel', // id
    'Pomodoro Notifications', // title
    description: 'Notifications for Pomodoro work/break cycles.', // description
    importance: Importance.max,
    playSound: true,
  );

  /// 3. Initialize the service
  Future<void> init() async {
    // --- Android Setup ---
    // Initialize the plugin with the default app icon
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // --- iOS Setup ---
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // --- Combine settings ---
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // --- Initialize plugin ---
    await _plugin.initialize(settings);

    // --- Create the Android channel ---
    // This is required for Android 8.0+
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_channel);
  }

  /// 4. The simple method our BLoC will call
  Future<void> showNotification(String title, String body) async {
    // --- Define platform-specific details ---
    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channel.id, // Must use the same channel ID
        _channel.name,
        channelDescription: _channel.description,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(presentSound: true),
    );

    // --- Show the notification ---
    await _plugin.show(
      0, // notification id
      title,
      body,
      details,
    );
  }
}
