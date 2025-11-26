import 'package:modernapproval/models/approvals/inventory_issue/inventory_issue_model/inventory_issue.dart';

import 'link.dart';

class InventoryIssueModel {
  List<InventoryIssue>? items;
  bool? hasMore;
  int? limit;
  int? offset;
  int? count;
  List<Link>? links;

  InventoryIssueModel({
    this.items,
    this.hasMore,
    this.limit,
    this.offset,
    this.count,
    this.links,
  });

  factory InventoryIssueModel.fromJson(Map<String, dynamic> json) {
    return InventoryIssueModel(
      items:
          (json['items'] as List<dynamic>?)
              ?.map((e) => InventoryIssue.fromJson(e as Map<String, dynamic>))
              .toList(),
      hasMore: json['hasMore'] as bool?,
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
      count: json['count'] as int?,
      links:
          (json['links'] as List<dynamic>?)
              ?.map((e) => Link.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items?.map((e) => e.toJson()).toList(),
    'hasMore': hasMore,
    'limit': limit,
    'offset': offset,
    'count': count,
    'links': links?.map((e) => e.toJson()).toList(),
  };
}
