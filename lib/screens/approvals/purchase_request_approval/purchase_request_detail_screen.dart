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

  // --- ✅ إضافة متغير للتحكم بحالة الإرسال ---
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

      _masterData = results[0] as PurchaseRequestMaster;
      _detailData = results[1] as List<PurchaseRequestDetail>;

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
      backgroundColor: const Color(0xFFF4F6F9), // استخدام لونك
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
            onPressed: (_masterData != null && _detailData != null)
                ? () => _printDocument(l)
                : null,
          ),
        ],
      ),
      // --- ✅ إضافة Stack لإظهار التحميل ---
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
                    _buildMasterSection(l, masterData, isArabic),
                    const SizedBox(height: 24), // الحفاظ على تصميمك
                    _buildModernDetailTable(l, detailData, isArabic), // استخدام الجدول
                  ],
                ),
              );
            },
          ),
          // --- ✅ ودجت التحميل عند الإرسال ---
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
                          fontFamily: 'Amiri', // ضمان ظهور الخط
                          decoration: TextDecoration.none // إزالة أي خطوط
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

  // --- (الحفاظ على تصميمك للجزء الرئيسي) ---
  Widget _buildMasterSection(
      AppLocalizations l, PurchaseRequestMaster master, bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.translate('masterInfo'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const Divider(height: 20),
            _buildInfoRow(l.translate('store_name'), master.storeName ?? 'N/A'),
            _buildInfoRow(
                l.translate('item_name'), // استخدام نفس المفتاح للوصف
                isArabic ? (master.descA ?? '') : (master.descE ?? '')),
            _buildInfoRow(l.translate('req_date'), master.formattedReqDate),
            const SizedBox(height: 10),
            Center(
              child: SizedBox( // استخدام SizedBox بدلاً من Container
                width: 150,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: Text(l.translate('takeAction')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F36),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri'),
                  ),
                  // --- ✅ تعطيل الزر أثناء الإرسال ---
                  onPressed: _isSubmitting ? null : () => _showActionDialog(context, l),
                ),
              ),
            ),
            const SizedBox(height: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title: ',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.grey.shade700),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  // --- (الحفاظ على تصميم الجدول الخاص بك) ---
  Widget _buildModernDetailTable(
      AppLocalizations l, List<PurchaseRequestDetail> details, bool isArabic) {
    final columns = [
      l.translate('store_code'),
      l.translate('store_name'),
      l.translate('req_date'),
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
          elevation: 2, // تعديل بسيط ليتطابق مع الكرت العلوي
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
              columnSpacing: 30, // مسافات
              columns: columns
                  .map((title) => DataColumn(
                  label: Text(title,
                      style: const TextStyle(fontWeight: FontWeight.bold))))
                  .toList(),
              rows: List<DataRow>.generate(details.length, (index) {
                final item = details[index];
                // تلوين متبادل للصفوف
                final color = index.isEven ? Colors.white : Colors.grey.shade50;
                return DataRow(
                  color: MaterialStateProperty.all(color),
                  cells: [
                    DataCell(Text(item.storeCode?.toString() ?? 'N/A')),
                    DataCell(Text(item.storeName ?? 'N/A')),
                    DataCell(Text(item.formattedReqDate)),
                    DataCell(Text(item.groupName ?? 'N/A')),
                    DataCell(SizedBox(
                      width: 250, // تحديد عرض لاسم الصنف
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


  // ==== ✅ --- تعديل Dialog اتخاذ القرار (بإضافة الملاحظات) --- ✅ ====
  void _showActionDialog(BuildContext context, AppLocalizations l) {
    final TextEditingController notesController = TextEditingController();
    bool isDialogLoading = false;

    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting, // عدم إغلاق الديالوج أثناء التحميل
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
                  // --- ✅ إضافة حقل الملاحظات ---
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
                            // --- استدعاء المنطق الكامل ---
                            _submitApproval(
                                context, notesController.text, 1);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.cancel, color: Colors.red),
                          title: Text(l.translate('reject')),
                          onTap: () {
                            setDialogState(() => isDialogLoading = true);
                            // --- استدعاء المنطق الكامل ---
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

  // ==== ✅ --- المنطق الكامل لعملية الاعتماد/الرفض --- ✅ ====
  Future<void> _submitApproval(
      BuildContext dialogContext, String notes, int actualStatus) async {

    // --- التحقق من البيانات الأولية ---
    // هنا النقطة اللي كنت بتسأل عليها: prevSer و lastLevel بييجوا من
    // كائن widget.request اللي جبناه من الشاشة اللي فاتت
    // واللي اتملى من API (GET_PUR_REQUEST_AUTH)
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
      // --- 🚀 المرحلة الأولى (GET) ---
      print("--- 🚀 Starting Approval Process (Status: $actualStatus) ---");
      final ApprovalStatusResponse s1 = await _apiService.stage1_getStatus(
        userId: userId,
        roleCode: roleCode,
        authPk1: authPk1,
        authPk2: authPk2,
        actualStatus: actualStatus,
      );

      // تخزين البيانات من المرحلة الأولى
      final int trnsStatus = s1.trnsStatus;
      final int prevSerS1 = s1.prevSer;
      final int prevLevelS1 = s1.prevLevel;
      final int roundNoS1 = s1.roundNo;

      print("--- ℹ️ Stage 1 Data Received: trnsStatus=$trnsStatus, prevSer=$prevSerS1, prevLevel=$prevLevelS1, roundNo=$roundNoS1");

      // --- 🚀 المرحلة الثالثة (PUT - Conditional) ---
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

      // --- 🚀 المرحلة الرابعة (PUT) ---
      final Map<String, dynamic> stage4Body = {
        "user_id": userId,
        "actual_status": actualStatus,
        "trns_notes": notes,
        "prev_ser": prevSerS1, // من المرحلة 1
        "round_no": roundNoS1, // من المرحلة 1
        "auth_pk1": authPk1,
        "auth_pk2": authPk2,
        "trns_status": trnsStatus // من المرحلة 1
      };
      await _apiService.stage4_updateStatus(stage4Body);

      // --- 🚀 المرحلة الخامسة (DELETE) ---
      final Map<String, dynamic> stage5Body = {
        "auth_pk1": authPk1,
        "auth_pk2": authPk2,
        "prev_ser": prevSerOriginal, // من الطلب الأصلي
        "prev_level": prevLevelS1 // من المرحلة 1
      };
      await _apiService.stage5_deleteStatus(stage5Body);

      // --- 🚀 المرحلة السادسة (POST - Conditional) ---
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

      // --- ✅ النجاح ---
      print("--- ✅ Process Completed Successfully ---");
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.pop(dialogContext); // إغلاق الديالوج
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(l.translate('submissionSuccess')),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context, true); // العودة بنتيجة true لتحديث القائمة

    } catch (e) {
      // --- ❌ الفشل ---
      print("--- ❌ Process Failed ---");
      print("❌ ERROR DETAILS: $e");
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
      });
      Navigator.pop(dialogContext); // إغلاق الديالوج
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


  // --- (الحفاظ على تصميم الطباعة الخاص بك) ---
  Future<void> _printDocument(AppLocalizations l) async {
    final isArabic = l.locale.languageCode == 'ar';
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    final headers = [
      l.translate('store_code'),
      l.translate('store_name'),
      l.translate('req_date'),
      l.translate('group_name'),
      l.translate('item_name'),
      l.translate('unit_name'),
      l.translate('quantity'),
      l.translate('note'),
    ];

    final data = _detailData!.map((item) => [
      item.storeCode?.toString() ?? 'N/A',
      item.storeName ?? 'N/A',
      item.formattedReqDate,
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
        header: (context) => _buildPdfHeader(l, ttf), // استخدام الهيدر المحسن
        footer: (context) => _buildPdfFooter(l, context, ttf), // استخدام الفوتر المحسن
        build: (context) => [
          _buildPdfMasterInfo(l, ttf), // استخدام البيانات الأساسية المحسنة
          pw.SizedBox(height: 25),
          pw.Text(l.translate('itemDetails'), style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey, height: 10),
          _buildPdfTable(l, headers, data, ttf), // استخدام الجدول المحسن
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // --- ✅ دوال الطباعة المحسنة (كما كانت في الرد السابق) ---
  pw.Widget _buildPdfHeader(AppLocalizations l, pw.Font ttf) {
    const String logoSvg = '''
    <svg viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
      <path d="M256 512A256 256 0 1 0 256 0a256 256 0 1 0 0 512zM159.3 388.7c-2.6 8.4-11.6 13.2-20 10.5s-13.2-11.6-10.5-20C145.2 322.4 192 256 256 256s110.8 66.4 127.3 129.3c2.6 8.4-2.1 17.4-10.5 20s-17.4-2.1-20-10.5C334.1 346.9 300.6 304 256 304s-78.1 42.9-96.7 84.7zM400 256a144 144 0 1 1-288 0 144 144 0 1 1 288 0z" fill="#6c63ff"/>
    </svg>
    ''';

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
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Your Company Name",
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, font: ttf, fontSize: 20)),
              pw.Text("Purchase Request Approval Report",
                  style: pw.TextStyle(
                      font: ttf, fontSize: 16, color: PdfColors.grey700)),
            ],
          ),
          pw.SvgImage(svg: logoSvg, width: 60),
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

  pw.Widget _buildPdfMasterInfo(AppLocalizations l, pw.Font ttf) {
    final isArabic = l.locale.languageCode == 'ar';
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

  pw.Widget _buildPdfTable(AppLocalizations l, List<String> headers,
      List<List<String>> data, pw.Font ttf) {

    // تعديل الهيدرز ليطابق الجدول في التطبيق
    final pdfHeaders = [
      l.translate('store_code'),
      l.translate('store_name'),
      l.translate('req_date'),
      l.translate('group_name'),
      l.translate('item_name'),
      l.translate('unit_name'),
      l.translate('quantity'),
      l.translate('note'),
    ];

    return pw.Table.fromTextArray(
      headers: pdfHeaders,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: ttf),
      headerDecoration:
      const pw.BoxDecoration(color: PdfColor.fromInt(0xFF6C63FF)),
      cellHeight: 35,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.center,
        6: pw.Alignment.center,
        7: pw.Alignment.centerLeft,
      },
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.5),
        1: const pw.FlexColumnWidth(2.5),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
        4: const pw.FlexColumnWidth(3.5),
        5: const pw.FlexColumnWidth(1),
        6: const pw.FlexColumnWidth(1),
        7: const pw.FlexColumnWidth(2),
      },
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  pw.Widget _pdfInfoText(String title, String value, pw.Font ttf) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 100, // تحديد عرض ثابت للعنوان
            child: pw.Text('$title: ',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: ttf)),
          ),
          pw.Expanded(child: pw.Text(value, style: pw.TextStyle(font: ttf))),
        ],
      ),
    );
  }
}