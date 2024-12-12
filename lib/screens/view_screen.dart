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
  List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  Timer? _timer;
  int _currentPage = 0;
  static const int _itemsPerPage = 10;
  bool _hasMorePages = true;

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
      final createdAt = DateTime.parse(createdAtStr).add(Duration(hours: 9));
      final now = DateTime.now();
      final deliveryTime = createdAt.add(Duration(hours: 24));
      return now.isAfter(deliveryTime);
    } catch (e) {
      return false;
    }
  }

  bool _isDeliveryDay(String createdAtStr) {
    try {
      final createdAt = DateTime.parse(createdAtStr).add(Duration(hours: 9));
      final now = DateTime.now();
      final nextDay = createdAt.add(Duration(days: 1));

      return now.year == nextDay.year &&
          now.month == nextDay.month &&
          now.day == nextDay.day &&
          now.hour >= 9;
    } catch (e) {
      return false;
    }
  }

  String _formatDate(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr).add(Duration(hours: 9));
      return '${dateTime.month}月${dateTime.day}日';
    } catch (e) {
      return '';
    }
  }

  void _showMessageContent(BuildContext context, Map<String, dynamic> message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.7,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${message['sender']['name']}より',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Text(
                      message['content'],
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('閉じる'),
                ),
              ],
            ),
          ),
        );
      },
    );
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
          .order('created_at', ascending: false)
          .range(_currentPage * _itemsPerPage,
              (_currentPage + 1) * _itemsPerPage - 1);

      // テスト用のサンプルデータを作成
      // final now = DateTime.now();
      // final yesterday = now.subtract(Duration(days: 1));

      // final sampleMessages = [
      //   {
      //     'sender_id': 'sample1',
      //     'content': 'これは昨日朝9時に送信されたテストメッセージです',
      //     'created_at':
      //         DateTime(yesterday.year, yesterday.month, yesterday.day, 0, 0)
      //             .toIso8601String(),
      //     'sender': {'name': 'テストユーザー1'}
      //   },
      //   {
      //     'sender_id': 'sample2',
      //     'content': 'これは昨日夜21時に送信されたテストメッセージです',
      //     'created_at':
      //         DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 0)
      //             .toIso8601String(),
      //     'sender': {'name': 'テストユーザー2'}
      //   }
      // ];

      if (mounted) {
        setState(() {
          if (_currentPage == 0) {
            // _messages = [...sampleMessages, ...response];
            _messages = [...response];
          } else {
            _messages.addAll(response);
          }
          _hasMorePages = response.length == _itemsPerPage;
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

  List<Map<String, dynamic>> _getFilteredMessages() {
    return _messages.where((message) {
      final isDeliverable = _isMessageDeliverable(message['created_at']);
      final isDeliveryDay = _isDeliveryDay(message['created_at']);
      return isDeliverable || isDeliveryDay;
    }).toList();
  }

  void _loadMoreMessages() {
    if (!_isLoading && _hasMorePages) {
      setState(() {
        _currentPage++;
        _isLoading = true;
      });
      _fetchMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredMessages = _getFilteredMessages();

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
          _isLoading && _currentPage == 0
              ? const Center(child: CircularProgressIndicator())
              : filteredMessages.isEmpty
                  ? const Center(child: Text('メッセージがありません。'))
                  : ListView.builder(
                      itemCount:
                          filteredMessages.length + (_hasMorePages ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == filteredMessages.length) {
                          if (_isLoading) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextButton(
                                onPressed: _loadMoreMessages,
                                child: Text('次の10件を表示'),
                              ),
                            ),
                          );
                        }

                        final message = filteredMessages[index];
                        final isDeliverable =
                            _isMessageDeliverable(message['created_at']);
                        final isDeliveryDay =
                            _isDeliveryDay(message['created_at']);

                        if (!isDeliverable && !isDeliveryDay) {
                          return SizedBox.shrink();
                        }

                        if (isDeliveryDay && !isDeliverable) {
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                vertical: 10, horizontal: 20),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Center(
                                child: Text(
                                  'メッセージ配達中です。今日中に届きます。',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                          );
                        }

                        // 24時間経過したメッセージ
                        return Card(
                          margin: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: InkWell(
                            onTap: () => _showMessageContent(context, message),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${message['sender']['name']} さんから届きました。',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.grey[800],
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '送信日: ${_formatDate(message['created_at'])}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(Icons.mail_outline),
                                ],
                              ),
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
