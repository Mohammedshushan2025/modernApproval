
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modernapproval/models/approval_status_response_model.dart';
import 'package:modernapproval/models/purchase_request_det_model.dart';
import 'package:modernapproval/models/purchase_request_mast_model.dart';
import 'package:modernapproval/models/purchase_request_model.dart';
import 'package:modernapproval/models/user_model.dart';
import 'package:modernapproval/services/api_service.dart';
import 'package:modernapproval/widgets/error_display.dart';
import '../../../app_localizations.dart';
import '../../../main.dart';
import 'package:intl/intl.dart';

// --- مكتبات الطباعة ---
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// ---------------------

class PurchaseRequestDetailScreen extends StatefulWidget {
  final UserModel user;
  final PurchaseRequest request;

  const PurchaseRequestDetailScreen({
    super.key,
    required this.user,
    required this.request,
  });

  @override
  State<PurchaseRequestDetailScreen> createState() =>
      _PurchaseRequestDetailScreenState();
}

class _PurchaseRequestDetailScreenState
    extends State<PurchaseRequestDetailScreen> {
  final ApiService _apiService = ApiService();
  late Future<Map<String, dynamic>> _detailsFuture;

  PurchaseRequestMaster? _masterData;
  List<PurchaseRequestDetail>? _detailData;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadAllDetails();
  }

  Future<Map<String, dynamic>> _loadAllDetails() async {
    try {
      final results = await Future.wait([
        _apiService.getPurchaseRequestMaster(
          trnsTypeCode: widget.request.trnsTypeCode,
          trnsSerial: widget.request.trnsSerial,
        ),
        _apiService.getPurchaseRequestDetail(
          trnsTypeCode: widget.request.trnsTypeCode,
          trnsSerial: widget.request.trnsSerial,
        ),
      ]);

      setState(() {
        _masterData = results[0] as PurchaseRequestMaster;
        _detailData = results[1] as List<PurchaseRequestDetail>;
      });

      return {
        'master': _masterData,
        'detail': _detailData,
      };
    } catch (e) {
      rethrow;
    }
  }

  void _retryLoad() {
    setState(() {
      _detailsFuture = _loadAllDetails();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: Text(l.translate('requestDetails')),
        backgroundColor: const Color(0xFF6C63FF),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final myAppState = MyApp.of(context);
              if (myAppState != null) {
                myAppState.changeLanguage(
                    isArabic ? const Locale('en', '') : const Locale('ar', ''));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: _masterData != null && _detailData != null
                ? () => _printDocument(l)
                : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _detailsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return ErrorDisplay(
                  errorMessageKey: snapshot.error.toString().contains('noInternet')
                      ? 'noInternet'
                      : 'serverError',
                  onRetry: _retryLoad,
                );
              }

              if (!snapshot.hasData) {
                return ErrorDisplay(errorMessageKey: 'noData', onRetry: _retryLoad);
              }

              final masterData = snapshot.data!['master'] as PurchaseRequestMaster;
              final detailData =
              snapshot.data!['detail'] as List<PurchaseRequestDetail>;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildCompactMasterSection(l, masterData, isArabic),
                    const SizedBox(height: 20),
                    _buildModernDetailTable(l, detailData, isArabic),
                  ],
                ),
              );
            },
          ),
          if (_isSubmitting)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      l.translate('submissionLoading'),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Amiri',
                          decoration: TextDecoration.none
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }


  Widget _buildCompactMasterSection(
      AppLocalizations l, PurchaseRequestMaster master, bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              const Color(0xFF6C63FF).withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF6C63FF),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l.translate('masterInfo'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1F36),
                    ),
                  ),
                ],
              ),
              const Divider(height: 16, thickness: 1),
              _buildCompactInfoRow(
                Icons.store,
                l.translate('store_name'),
                master.storeName ?? 'N/A',
              ),
              const SizedBox(height: 8),
              _buildCompactInfoRow(
                Icons.description,
                l.translate('item_name'),
                isArabic ? (master.descA ?? '') : (master.descE ?? ''),
              ),
              const SizedBox(height: 8),
              _buildCompactInfoRow(
                Icons.calendar_today,
                l.translate('req_date'),
                master.formattedReqDate,
              ),
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 280),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6C63FF).withOpacity(0.85),
                        const Color(0xFF8B7FFF).withOpacity(0.85),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6C63FF).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.task_alt, size: 20),
                    label: Text(
                      l.translate('takeAction'),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : () => _showActionDialog(context, l),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactInfoRow(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF6C63FF).withOpacity(0.7), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailTable(
      AppLocalizations l, List<PurchaseRequestDetail> details, bool isArabic) {
    final columns = [
      l.translate('group_name'),
      l.translate('item_name'),
      l.translate('unit_name'),
      l.translate('quantity'),
      l.translate('note'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l.translate('itemDetails'),
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        const Divider(height: 16),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFF6C63FF).withOpacity(0.1)),
              headingTextStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
                fontSize: 14,
              ),
              dataRowMinHeight: 60,
              dataRowMaxHeight: 80,
              columnSpacing: 30,
              columns: columns
                  .map((title) => DataColumn(
                  label: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold))))
                  .toList(),
              rows: List<DataRow>.generate(details.length, (index) {
                final item = details[index];
                final color = index.isEven ? Colors.white : Colors.grey.shade50;
                return DataRow(
                  color: MaterialStateProperty.all(color),
                  cells: [
                    DataCell(Text(item.groupName ?? 'N/A')),
                    DataCell(SizedBox(
                      child: Text(
                        isArabic ? (item.itemNameA ?? '') : (item.itemNameE ?? ''),
                        overflow: TextOverflow.visible,
                      ),
                    )),
                    DataCell(Text(item.unitName ?? 'N/A')),
                    DataCell(Text(item.quantity?.toString() ?? 'N/A')),
                    DataCell(Text(item.note ?? 'N/A')),
                  ],
                );
              }),
            ),
          ),
        ),
      ],
    );
  }

  void _showActionDialog(BuildContext context, AppLocalizations l) {
    final TextEditingController notesController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: Text(l.translate('takeAction')),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: notesController,
                    decoration: InputDecoration(
                      labelText: l.translate('notes'),
                      hintText: l.translate('notesHint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                  if (isDialogLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(width: 16),
                          Text(l.translate('submitting')),
                        ],
                      ),
                    )
                  else
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.check_circle, color: Colors.green),
                          title: Text(l.translate('approve')),
                          onTap: () {
                            setDialogState(() => isDialogLoading = true);
                            _submitApproval(
                                context, notesController.text, 1);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.cancel, color: Colors.red),
                          title: Text(l.translate('reject')),
                          onTap: () {
                            setDialogState(() => isDialogLoading = true);
                            _submitApproval(
                                context, notesController.text, -1);
                          },
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isDialogLoading
                      ? null
                      : () => Navigator.pop(dialogContext),
                  child: Text(l.translate('cancel')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitApproval(
      BuildContext dialogContext, String notes, int actualStatus) async {

    if (widget.request.prevSer == null || widget.request.lastLevel == null) {
      print("❌ CRITICAL ERROR: Missing 'prev_ser' or 'last_level' in the initial PurchaseRequest object.");
      print("❌ Make sure 'GET_PUR_REQUEST_AUTH' API returns these values!");
      _showErrorDialog("بيانات الطلب الأساسية غير مكتملة (prev_ser, last_level). لا يمكن المتابعة.");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final l = AppLocalizations.of(context)!;
    final int userId = widget.user.usersCode;
    final int roleCode = widget.user.roleCode!;
    final String authPk1 = widget.request.authPk1;
    final String authPk2 = widget.request.authPk2;
    final int lastLevel = widget.request.lastLevel!;
    final int prevSerOriginal = widget.request.prevSer!;

    try {
      print("--- 🚀 Starting Approval Process (Status: $actualStatus) ---");
      final ApprovalStatusResponse s1 = await _apiService.stage1_getStatus(
        userId: userId,
        roleCode: roleCode,
        authPk1: authPk1,
        authPk2: authPk2,
        actualStatus: actualStatus,
      );

      final int trnsStatus = s1.trnsStatus;
      final int prevSerS1 = s1.prevSer;
      final int prevLevelS1 = s1.prevLevel;
      final int roundNoS1 = s1.roundNo;

      print("--- ℹ️ Stage 1 Data Received: trnsStatus=$trnsStatus, prevSer=$prevSerS1, prevLevel=$prevLevelS1, roundNo=$roundNoS1");

      print("--- ℹ️ Checking Stage 3 Condition: lastLevel ($lastLevel) == 1 && trnsStatus ($trnsStatus) == 1");
      if (lastLevel == 1 && trnsStatus == 1) {
        print("--- 🚀 Condition Met (Stage 3) ---");
        await _apiService.stage3_checkLastLevel(
          userId: userId,
          authPk1: authPk1,
          authPk2: authPk2,
        );
      } else {
        print("--- ⏩ Skipping Stage 3 (Condition Not Met) ---");
      }

      final Map<String, dynamic> stage4Body = {
        "user_id": userId,
        "actual_status": actualStatus,
        "trns_notes": notes,
        "prev_ser": prevSerS1,
        "round_no": roundNoS1,
        "auth_pk1": authPk1,
        "auth_pk2": authPk2,
        "trns_status": trnsStatus
      };
      await _apiService.stage4_updateStatus(stage4Body);

      final Map<String, dynamic> stage5Body = {
        "auth_pk1": authPk1,
        "auth_pk2": authPk2,
        "prev_ser": prevSerOriginal,
        "prev_level": prevLevelS1
      };
      await _apiService.stage5_deleteStatus(stage5Body);

      print("--- ℹ️ Checking Stage 6 Condition: trnsStatus ($trnsStatus) == 0 || trnsStatus ($trnsStatus) == -1");
      if (trnsStatus == 0 || trnsStatus == -1) {
        print("--- 🚀 Condition Met (Stage 6) ---");
        final Map<String, dynamic> stage6Body = {
          "trns_status": trnsStatus,
          "prev_ser": prevSerS1,
          "prev_level": prevLevelS1,
          "round_no": roundNoS1,
          "auth_pk1": s1.authPk1,
          "auth_pk2": s1.authPk2,
          "auth_pk3": s1.authPk3,
          "auth_pk4": s1.authPk4,
          "auth_pk5": s1.authPk5
        };
        await _apiService.stage6_postFinalStatus(stage6Body);
      } else {
        print("--- ⏩ Skipping Stage 6 (Condition Not Met) ---");
      }

      print("--- ✅ Process Completed Successfully ---");
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.pop(dialogContext);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.translate('submissionSuccess')),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true);

    } catch (e) {
      print("--- ❌ Process Failed ---");
      print("❌ ERROR DETAILS: $e");
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.pop(dialogContext);
      _showErrorDialog(e.toString());
    }
  }

  void _showErrorDialog(String error) {
    final l = AppLocalizations.of(context)!;
    String userMessage = l.translate('submissionErrorBody');
    if (error.contains('noInternet')) {
      userMessage = l.translate('noInternet');
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.translate('submissionError')),
        content: Text(userMessage),
        actions: [
          TextButton(
            child: Text(l.translate('ok')),
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  Future<void> _printDocument(AppLocalizations l) async {
    if (_masterData == null || _detailData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('البيانات غير متوفرة للطباعة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final isArabic = l.locale.languageCode == 'ar';
      final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
      final ttf = pw.Font.ttf(fontData);

      final logoData = await rootBundle.load("assets/images/lo.png");
      final logoImage = pw.MemoryImage(logoData.buffer.asUint8List());

      final pdf = pw.Document();

      final headers = [
        l.translate('group_name'),
        l.translate('item_name'),
        l.translate('unit_name'),
        l.translate('quantity'),
        l.translate('note'),
      ];

      final data = _detailData!.map((item) => [
        item.groupName ?? 'N/A',
        isArabic ? (item.itemNameA ?? '') : (item.itemNameE ?? ''),
        item.unitName ?? 'N/A',
        item.quantity?.toString() ?? 'N/A',
        item.note ?? 'N/A',
      ]).toList();

      pdf.addPage(
        pw.MultiPage(
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(20),
          header: (context) => _buildPdfHeader(l, ttf, logoImage, isArabic),
          footer: (context) => _buildPdfFooter(l, context, ttf),
          build: (context) => [
            _buildPdfMasterInfo(l, ttf, isArabic),
            pw.SizedBox(height: 20),
            _buildPdfTable(l, headers, data, ttf, isArabic),
          ],
        ),
      );

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      print("❌ Print Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الطباعة: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  pw.Widget _buildPdfHeader(AppLocalizations l, pw.Font ttf, pw.MemoryImage logo, bool isArabic) {
    final companyName = isArabic
        ? 'شركة المنشأت والمعدات الحديثة'
        : 'Modern Structure & Equipment';

    final reportTitle = isArabic
        ? 'تقرير اعتماد طلبات الشراء'
        : 'Purchase Request Approval Report';

    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 15),
      margin: const pw.EdgeInsets.only(bottom: 15),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
            bottom: pw.BorderSide(color: PdfColor.fromInt(0xFF6C63FF), width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: isArabic ? pw.CrossAxisAlignment.end : pw.CrossAxisAlignment.start,
            children: [
              pw.Text(companyName,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, font: ttf, fontSize: 20)),
              pw.Text(reportTitle,
                  style: pw.TextStyle(
                      font: ttf, fontSize: 16, color: PdfColors.grey700)),
            ],
          ),
          pw.Image(logo, width: 60, height: 60),
        ],
      ),
    );
  }

  pw.Widget _buildPdfFooter(AppLocalizations l, pw.Context context, pw.Font ttf) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 15),
      padding: const pw.EdgeInsets.only(top: 10),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey, width: 0.5)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '${l.translate('Printed by')}: ${widget.user.empName} | ${DateFormat('yyyy-MM-dd hh:mm a').format(DateTime.now())}',
            style: pw.TextStyle(font: ttf, color: PdfColors.grey, fontSize: 9),
          ),
          pw.Text(
            '${l.translate('Page')} ${context.pageNumber} ${l.translate('of')} ${context.pagesCount}',
            style: pw.TextStyle(font: ttf, color: PdfColors.grey, fontSize: 9),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildPdfMasterInfo(AppLocalizations l, pw.Font ttf, bool isArabic) {
    return pw.Container(
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: PdfColors.grey200),
          borderRadius: pw.BorderRadius.circular(8),
        ),
        child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(l.translate('masterInfo'), style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.Divider(height: 10),
              _pdfInfoText(l.translate('store_name'), _masterData?.storeName ?? 'N/A', ttf),
              _pdfInfoText(l.translate('req_date'), _masterData?.formattedReqDate ?? 'N/A', ttf),
              _pdfInfoText(l.translate('item_name'), isArabic ? (_masterData?.descA ?? '') : (_masterData?.descE ?? ''), ttf),
            ]
        )
    );
  }

  pw.Widget _buildPdfTable(AppLocalizations l, List<String> headers, List<List<String>> data, pw.Font ttf, bool isArabic) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          l.translate('itemDetails'),
          textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
          style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold),
        ),
        pw.Divider(color: PdfColors.grey, height: 10),
        pw.Table.fromTextArray(
          headers: headers,
          data: data,
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              font: ttf,
              fontSize: 12),
          headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF6C63FF)),
          cellHeight: 40,
          cellStyle: pw.TextStyle(font: ttf, fontSize: 11),
          headerAlignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
          cellAlignment: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
          cellAlignments: {
            0: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            1: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
            2: pw.Alignment.center,
            3: pw.Alignment.center,
            4: isArabic ? pw.Alignment.centerRight : pw.Alignment.centerLeft,
          },
          cellPadding: const pw.EdgeInsets.all(8),
          columnWidths: {
            0: const pw.FlexColumnWidth(2),
            1: const pw.FlexColumnWidth(4),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(2.5),
          },
          rowDecoration: const pw.BoxDecoration(
            border: pw.Border(
              bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
            ),
          ),
          oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
        ),
      ],
    );
  }

  pw.Widget _pdfInfoText(String title, String value, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100,
            child: pw.Text('$title: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf)),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: ttf))),
        ],
      ),
    );
  }
}