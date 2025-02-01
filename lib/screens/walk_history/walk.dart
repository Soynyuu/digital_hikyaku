import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/background_scaffold.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class WalkHistoryScreen extends StatefulWidget {
  const WalkHistoryScreen({super.key});
  @override
  _WalkHistoryScreenState createState() => _WalkHistoryScreenState();
}

class _WalkHistoryScreenState extends State<WalkHistoryScreen>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  List<Map<String, dynamic>> letters = [];
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    // アニメーションを繰り返すのではなく、1秒ごとに更新
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {}); // 進捗を更新
      }
    });
    _loadLetters();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadLetters() async {
    try {
      final response = await _apiService.getSendHistory();
      if (response.statusCode == 200) {
        setState(() {
          letters = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } catch (e) {
      debugPrint('Error loading letters: $e');
    }
  }

  double _calculateProgress(String createAt, String arriveAt) {
    final now = DateTime.now().toUtc();
    // 末尾に"Z"を付与してUTCとしてパース
    final created = DateTime.parse(createAt + "Z");
    final arrival = DateTime.parse(arriveAt + "Z");

    if (arrival.isAfter(now)) {
      final totalDuration = arrival.difference(created).inMilliseconds.toDouble();
      final currentDuration = now.difference(created).inMilliseconds.toDouble();
      return (currentDuration / totalDuration).clamp(0.0, 1.0);
    } else {
      return 1.0;
    }
  }

  Widget _buildDeliveryStatus(double progress) {
    String status;
    Color statusColor;
    if (progress >= 1.0) {
      status = '配達完了';
      statusColor = Colors.green.shade700;
    } else {
      status = '配達中';
      statusColor = Colors.brown.shade700;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        border: Border.all(color: statusColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: GoogleFonts.sawarabiGothic(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          '飛脚の配達状況',
          style: GoogleFonts.sawarabiMincho(
            fontWeight: FontWeight.w600,
            color: Colors.brown.shade900,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
              ),
              child: RefreshIndicator(
                onRefresh: _loadLetters,
                child: letters.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.mail_outline,
                              size: 64,
                              color: Colors.brown.shade200,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              '送信した手紙はありません',
                              style: GoogleFonts.sawarabiGothic(
                                fontSize: 16,
                                color: Colors.brown.shade700,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: letters.length,
                        itemBuilder: (context, index) {
                          final letter = letters[index];
                          final progress = _calculateProgress(
                            letter['created_at'],
                            letter['arrive_at'],
                          );

                          return Card(
                            elevation: 4,
                            shadowColor: Colors.brown.withOpacity(0.2),
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                  color: Colors.brown.shade200, width: 0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _buildDeliveryStatus(progress),
                                      Text(
                                        'To: ${letter['recipient_name']}',
                                        style: GoogleFonts.sawarabiGothic(
                                          fontSize: 14,
                                          color: Colors.brown.shade800,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'レターセット: ${letter['letter_set_id']}',
                                        style: GoogleFonts.sawarabiGothic(
                                          fontSize: 12,
                                          color: Colors.brown.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // プログレスバー部分の修正
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Container(
                                        height: 32, // 高さを拡大
                                        child: TweenAnimationBuilder<double>(
                                          duration: const Duration(milliseconds: 500),
                                          curve: Curves.easeInOut,
                                          tween: Tween<double>(
                                            begin: 0,
                                            end: progress,
                                          ),
                                          builder: (context, value, _) {
                                            return Stack(
                                              children: [
                                                Align(
                                                  alignment: Alignment.center,
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.circular(8),
                                                    child: LinearProgressIndicator(
                                                      value: value,
                                                      backgroundColor: Colors.brown.shade50,
                                                      valueColor: AlwaysStoppedAnimation<Color>(
                                                        progress >= 1.0
                                                            ? Colors.green.shade300
                                                            : Colors.brown.shade300,
                                                      ),
                                                      minHeight: 8,
                                                    ),
                                                  ),
                                                ),
                                                Positioned(
                                                  left: (constraints.maxWidth - 32) * value,
                                                  top: (32 - 32) / 2, // 垂直中央に配置
                                                  child: Icon(
                                                    Icons.directions_run,
                                                    size: 32, // アイコンサイズを32に変更
                                                    color: Colors.brown.shade700,
                                                  ),
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    // mainAxisAlignmentは削除して左右の余白はFlexibleとSizedBoxで調整
                                    children: [
                                      Flexible(
                                          child: _buildDateInfo(
                                              '発送', letter['created_at'])),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: Colors.brown.shade300,
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                          child: _buildDateInfo(
                                              '到着予定', letter['arrive_at'])),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInfo(String label, String dateStr) {
    // UTCとしてパース後、JST(+9時間)に変換
    final utcDate = DateTime.parse(dateStr + "Z");
    final jstDate = utcDate.add(const Duration(hours: 9));

    final formattedDate = DateFormat('MM/dd HH:mm').format(jstDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 12,
            color: Colors.brown.shade600,
          ),
        ),
        Text(
          formattedDate,
          style: GoogleFonts.sawarabiGothic(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.brown.shade900,
          ),
        ),
      ],
    );
  }
}
