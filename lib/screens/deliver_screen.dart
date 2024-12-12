import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class DeliverScreen extends StatefulWidget {
  const DeliverScreen({Key? key}) : super(key: key);

  @override
  _DeliverScreenState createState() => _DeliverScreenState();
}

class _DeliverScreenState extends State<DeliverScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<dynamic> _messages = [];
  bool _isLoading = true;
  Timer? _timer;

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
          DateTime.parse(createdAtStr).add(const Duration(hours: 9));
      final now = DateTime.now();
      final difference = now.difference(createdAt).inHours;
      return difference >= 24;
    } catch (e) {
      print('Date parsing error: $e');
      return false;
    }
  }

  String _getDeliveryMessage(String createdAtStr) {
    try {
      final createdAt =
          DateTime.parse(createdAtStr).add(const Duration(hours: 9));
      final now = DateTime.now();
      final difference = now.difference(createdAt).inHours;
      final remainingHours = 24 - difference;

      if (remainingHours <= 0) {
        return 'メッセージは届きました';
      } else {
        final deliveryTime = createdAt.add(const Duration(hours: 24));
        return '${deliveryTime.year}年${deliveryTime.month}月${deliveryTime.day}日 ${deliveryTime.hour}時${deliveryTime.minute}分に届く予定です\n(あと${remainingHours.ceil()}時間)';
      }
    } catch (e) {
      print('Delivery message formatting error: $e');
      return 'メッセージの配信予定時刻を計算できません';
    }
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime =
          DateTime.parse(dateTimeStr).add(const Duration(hours: 9));
      return '${dateTime.year}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.day.toString().padLeft(2, '0')} '
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      print('Date formatting error: $e');
      return dateTimeStr;
    }
  }

  String _formatTimeDifference(String createdAtStr) {
    try {
      final createdAt =
          DateTime.parse(createdAtStr).add(const Duration(hours: 9));
      final now = DateTime.now();
      final difference = now.difference(createdAt).inHours;

      if (difference < 24) {
        final remainingHours = 24 - difference;
        return 'あと${remainingHours}時間';
      } else {
        final days = (difference / 24).floor();
        return '$days日前に配信完了';
      }
    } catch (e) {
      print('Time difference formatting error: $e');
      return '';
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
              'recipient_id, content, created_at, recipient:users!letters_recipient_id_fkey(name)')
          .eq('sender_id', userId)
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
        title: const Text('送信メッセージ'),
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
                        final createdAtStr = message['created_at'];
                        final isDeliverable =
                            _isMessageDeliverable(createdAtStr);
                        final deliveryMessage =
                            _getDeliveryMessage(createdAtStr);

                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  deliveryMessage,
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '宛先: ${message['recipient']['name']}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _formatDateTime(createdAtStr),
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                      Text(
                                        _formatTimeDifference(createdAtStr),
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
