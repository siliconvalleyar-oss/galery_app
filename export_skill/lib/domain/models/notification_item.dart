import 'package:flutter/material.dart';

/// Domain entity representing a notification item.
class NotificationItem {
  final int id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String time;
  bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.time,
    this.isUnread = true,
  });
}
