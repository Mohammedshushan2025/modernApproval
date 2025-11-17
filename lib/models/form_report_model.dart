class FormReportItem {
  final int userId;
  final int pageId;
  final String pageName;
  final String pageNameE;
  final int ord;
  final String type;

  FormReportItem({
    required this.userId,
    required this.pageId,
    required this.pageName,
    required this.pageNameE,
    required this.ord,
    required this.type,
  });

  factory FormReportItem.fromJson(Map<String, dynamic> json) {
    return FormReportItem(
      userId: json['user_id'],
      pageId: json['page_id'],
      pageName: json['page_name'],
      pageNameE: json['page_name_e'],
      ord: json['ord'],
      type: json['type'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'page_id': pageId,
      'page_name': pageName,
      'page_name_e': pageNameE,
      'ord': ord,
      'type': type,
    };
  }
}