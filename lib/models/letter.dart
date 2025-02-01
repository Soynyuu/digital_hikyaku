class Letter {
  final String id;
  final String senderId;
  final String senderName;
  final String recipientId;
  final String recipientName;
  final String letterSet;
  final String content;
  final bool isArrived;  // arrive_atの比較結果
  final DateTime arriveAt;  // 到着予定時刻
  final bool readFlag;
  final String createdAt;

  Letter({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.recipientId,
    required this.recipientName,
    required this.letterSet,
    required this.content,
    required this.isArrived,
    required this.arriveAt,
    required this.readFlag,
    required this.createdAt,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'],
      letterSet: json['letter_set_id'],
      content: json['content'] ?? '',
      isArrived: json['arrive_at'] == 1,
      arriveAt: DateTime.parse(json['read_flag']),  // read_flagに到着予定時刻が入っている
      readFlag: json['created_at'] == 1,  // created_atにread_flagが入っている
      createdAt: json['letter_set_id'],  // letter_set_idにcreated_atが入っている
    );
  }
}