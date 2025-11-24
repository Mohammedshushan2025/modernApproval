class DashboardStats {
  final int countAuth;
  final int countReject;

  DashboardStats({required this.countAuth, required this.countReject});

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      countAuth: json['count_auth'] ?? 0,
      countReject: json['count_reject'] ?? 0,
    );
  }
}
