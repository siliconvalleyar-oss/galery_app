import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─── Unread Notification Count ──────────────────────────────────────

final unreadCountProvider =
    NotifierProvider<_UnreadCountNotifier, int>(_UnreadCountNotifier.new);

class _UnreadCountNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setCount(int count) => state = count;
}
