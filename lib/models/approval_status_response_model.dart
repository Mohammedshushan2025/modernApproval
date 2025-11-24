class ApprovalStatusResponse {
  final int prevSer;
  final int prevLevel;
  final int roundNo;
  final int authFlag;
  final int rejectType;
  final int trnsStatus;
  final String authPk1;
  final String authPk2;
  final String? authPk3;
  final String? authPk4;
  final String? authPk5;

  ApprovalStatusResponse({
    required this.prevSer,
    required this.prevLevel,
    required this.roundNo,
    required this.authFlag,
    required this.rejectType,
    required this.trnsStatus,
    required this.authPk1,
    required this.authPk2,
    this.authPk3,
    this.authPk4,
    this.authPk5,
  });

  factory ApprovalStatusResponse.fromJson(Map<String, dynamic> json) {
    return ApprovalStatusResponse(
      prevSer: json['prev_ser'],
      prevLevel: json['prev_level'],
      roundNo: json['round_no'],
      authFlag: json['auth_flag'],
      rejectType: json['reject_type'],
      trnsStatus: json['trns_status'],
      authPk1: json['auth_pk1'],
      authPk2: json['auth_pk2'],
      authPk3: json['auth_pk3'],
      authPk4: json['auth_pk4'],
      authPk5: json['auth_pk5'],
    );
  }
}
