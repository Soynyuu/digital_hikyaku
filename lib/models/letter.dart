import 'package:intl/intl.dart';

class Letter {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final bool isArrived;
  final DateTime arriveAt;
  final bool readFlag;  // int -> bool に変更
  final DateTime createdAt;
  final String letterSet;

  Letter({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.isArrived,
    required this.arriveAt,
    required this.readFlag,
    required this.createdAt,
    required this.letterSet,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'],
      isArrived: json['is_arrived'] == 1 || json['is_arrived'] == true,
      arriveAt: DateTime.parse(json['arrive_at']),
      readFlag: json['read_flag'] == 1 || json['read_flag'] == true,  // int値をbooleanに変換
      createdAt: DateTime.parse(json['created_at']),
      letterSet: json['letter_set_id'],
    );
  }
}