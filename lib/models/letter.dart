class Letter {
  final String id;
  final String senderId;
  final String recipientId;
  final String recipientName;
  final String letterSet;
  final String content;
  final bool isArrived;
  final DateTime arriveAt;
  final bool readFlag;

  Letter({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.recipientName, // 新規追加
    required this.letterSet,      // 新規追加
    required this.content,
    required this.isArrived,
    required this.arriveAt,
    required this.readFlag,
  });

  factory Letter.fromJson(Map<String, dynamic> json) {
    return Letter(
      id: json['id'],
      senderId: json['sender_id'],
      recipientId: json['recipient_id'],
      recipientName: json['recipient_name'], // 新規追加
      letterSet: json['letter_set'],         // 新規追加
      content: json['content'] ?? '',
      isArrived: json['is_arrived'] == 1,
      arriveAt: DateTime.parse(json['arrive_at']),
      readFlag: json['read_flag'] == 1,
    );
  }
}