import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class ViewScreen extends StatefulWidget {
  const ViewScreen({Key? key}) : super(key: key);

  @override
  _ViewScreenState createState() => _ViewScreenState();
}

class _ViewScreenState extends State<ViewScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  Timer? _timer;
  DateTime? _serverTimeOffset;

  @override
  void initState() {
    super.initState();
    _fetchMessages();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {});
      }
    });
    tz.initializeTimeZones();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool _isMessageDeliverable(String createdAtStr) {
    try {
      final createdAt =
          DateTime.parse(createdAtStr).add(Duration(hours: 9)); // JSTに変換
      final now = DateTime.now();

      // 時間差を計算（時間単位）
      final difference = now.difference(createdAt).inHours;

      // 24時間（1日）以上経過している場合にtrueを返す
      return difference >= 24;
    } catch (e) {
      return false;
    }
  }

  String _getDeliveryMessage(String createdAtStr) {
    try {
      final createdAt =
          DateTime.parse(createdAtStr).add(Duration(hours: 9)); // JSTに変換
      final now = DateTime.now();
      final difference = now.difference(createdAt).inHours;
      final remainingHours = 24 - difference;

      if (remainingHours <= 0) {
        return ''; // 配信可能な場合は空文字を返す（メッセージ本文が表示される）
      } else {
        final deliveryTime = createdAt.add(Duration(hours: 24));
        return 'メッセージが届きました！\n${deliveryTime.year}年${deliveryTime.month}月${deliveryTime.day}日 ${deliveryTime.hour}時${deliveryTime.minute}分に確認できるようになります。\n(あと${remainingHours.ceil()}時間)';
      }
    } catch (e) {
      return 'メッセージの配信予定時刻を計算できません';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr).add(Duration(hours: 9));
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _formatTimeDifference(DateTime createdAt) {
    final now = DateTime.now();
    final dateTime =
        DateTime.parse(createdAt.toString()).add(Duration(hours: 9));
    final difference = now.difference(dateTime).inHours;

    if (difference < 24) {
      final remainingHours = 24 - difference;
      return 'あと${remainingHours}時間';
    } else {
      final days = (difference / 24).floor();
      return '$days日前';
    }
  }

  Future<void> _fetchMessages() async {
    final userId = _supabase.auth.currentUser?.id;

    if (userId == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ログインが必要です。')),
        );
      }
      return;
    }

    try {
      final response = await _supabase
          .from('letters')
          .select(
              'sender_id, content, created_at, sender:users!letters_sender_id_fkey(name)')
          .eq('recipient_id', userId)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _messages = response;
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Error: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('メッセージの取得に失敗しました。')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('受信メッセージ'),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/icons/haikei.png',
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _messages.isEmpty
                  ? const Center(child: Text('メッセージがありません。'))
                  : ListView.builder(
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final message = _messages[index];
                        final createdAt = DateTime.parse(message['created_at']);
                        final isDeliverable =
                            _isMessageDeliverable(message['created_at']);
                        final deliveryMessage =
                            _getDeliveryMessage(message['created_at']);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDeliverable
                                      ? message['content']
                                      : deliveryMessage,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '送信者: ${message['sender']['name']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatDateTime(message['created_at']),
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        _formatTimeDifference(createdAt),
                                        style: TextStyle(
                                            color: Colors.grey[400],
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
        ],
      ),
    );
  }
}
