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

      // 時間差を計算（分単位）
      final difference = now.difference(createdAt).inMinutes;

      // 0分以下の場合は false（お届け中）、1分以上経過している場合は true（表示）
      return difference > 0; // >= から > に変更
    } catch (e) {
      print('Date parsing error: $e');
      return false;
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr).add(Duration(hours: 9));
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Date formatting error: $e');
      return dateTimeStr;
    }
  }

  String _formatTimeDifference(DateTime createdAt) {
    final now = DateTime.now();
    final dateTime =
        DateTime.parse(createdAt.toString()).add(Duration(hours: 9));
    final difference = now.difference(dateTime).inMinutes;

    print("現在時刻: $now");
    print("作成時刻: $dateTime");
    print("差分(分): $difference");

    if (difference == 0) {
      return 'たった今';
    } else if (difference < 60) {
      return '$difference分前';
    } else {
      final hours = (difference / 60).floor();
      return '$hours時間前';
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

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isDeliverable ? message['content'] : 'お届け中です',
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
