class NotificationModel {
  final String id;
  final String title;
  final String date;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.date,
    required this.isRead,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? date,
    bool? isRead,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}