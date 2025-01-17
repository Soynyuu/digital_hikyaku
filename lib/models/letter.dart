class Letter {
  final String id;
  final String senderId;
  final String recipientId;
  final String content;
  final bool isArrived;
  final DateTime arriveAt;
  final bool readFlag;

  Letter({
    required this.id,
    required this.senderId,
    required this.recipientId,
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
      content: json['content'] ?? '',
      isArrived: json['is_arrived'] == 1,
      arriveAt: DateTime.parse(json['arrive_at']),
      readFlag: json['read_flag'] == 1,
    );
  }
}