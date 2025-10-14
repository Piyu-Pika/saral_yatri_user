// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _notifications =
//       FlutterLocalNotificationsPlugin();

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//     );

//     await _notifications.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: _onNotificationTapped,
//     );
//   }

//   static Future<bool?> requestPermissions() async {
//     return await _notifications
//         .resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();
//   }

//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//     String? payload,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'saral_yatri_channel',
//       'SaralYatri Notifications',
//       channelDescription: 'Notifications for SaralYatri bus booking app',
//       importance: Importance.max,
//       priority: Priority.high,
//       showWhen: false,
//     );

//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _notifications.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: payload,
//     );
//   }

//   static Future<void> showTicketBookingNotification(String ticketNumber) async {
//     await showNotification(
//       id: 1,
//       title: 'Ticket Booked Successfully!',
//       body: 'Your ticket $ticketNumber has been booked.',
//       payload: 'ticket_booking',
//     );
//   }

//   static Future<void> showTicketExpiryNotification(String ticketNumber) async {
//     await showNotification(
//       id: 2,
//       title: 'Ticket Expiring Soon',
//       body: 'Your ticket $ticketNumber will expire soon.',
//       payload: 'ticket_expiry',
//     );
//   }

//   static void _onNotificationTapped(NotificationResponse response) {
//     // Handle notification tap
//     final payload = response.payload;
//     if (payload != null) {
//       // Navigate to appropriate screen based on payload
//     }
//   }
// }
