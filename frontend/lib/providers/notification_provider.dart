import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type; // 'create', 'update', 'delete'
  final DateTime timestamp;
  final bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.read = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'timestamp': timestamp.toIso8601String(),
        'read': read,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      type: json['type'],
      timestamp: DateTime.parse(json['timestamp']),
      read: json['read'] ?? false,
    );
  }
}

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  static const String _storageKey = 'app_notifications';

  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _notifications.where((n) => !n.read).length;

  NotificationProvider() {
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? data = prefs.getString(_storageKey);
      if (data != null) {
        final List<dynamic> jsonList = json.decode(data);
        _notifications =
            jsonList.map((json) => AppNotification.fromJson(json)).toList();
        _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        notifyListeners();
      }
    } catch (e) {
      // Ignore errors
    }
  }

  Future<void> _saveNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String data =
          json.encode(_notifications.map((n) => n.toJson()).toList());
      await prefs.setString(_storageKey, data);
    } catch (e) {
      // Ignore errors
    }
  }

  void addNotification(String title, String message, String type) {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
    );
    _notifications.insert(0, notification);
    _saveNotifications();
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = AppNotification(
        id: _notifications[index].id,
        title: _notifications[index].title,
        message: _notifications[index].message,
        type: _notifications[index].type,
        timestamp: _notifications[index].timestamp,
        read: true,
      );
      _saveNotifications();
      notifyListeners();
    }
  }

  void markAllAsRead() {
    _notifications = _notifications.map((n) {
      return AppNotification(
        id: n.id,
        title: n.title,
        message: n.message,
        type: n.type,
        timestamp: n.timestamp,
        read: true,
      );
    }).toList();
    _saveNotifications();
    notifyListeners();
  }

  void clearAll() {
    _notifications.clear();
    _saveNotifications();
    notifyListeners();
  }
}
