import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modernapproval/models/purchase_request_det_model.dart';
import 'package:modernapproval/models/purchase_request_mast_model.dart';
import 'package:modernapproval/models/purchase_request_model.dart';
import 'package:modernapproval/models/user_model.dart';
import 'package:modernapproval/services/api_service.dart';
import 'package:modernapproval/widgets/error_display.dart';
import '../../../app_localizations.dart';
import '../../../main.dart';

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

  // لتخزين البيانات بعد تحميلها لاستخدامها في الطباعة
  PurchaseRequestMaster? _masterData;
  List<PurchaseRequestDetail>? _detailData;

  @override
  void initState() {
    super.initState();
    _detailsFuture = _loadAllDetails();
  }

  Future<Map<String, dynamic>> _loadAllDetails() async {
    try {
      // جلب البيانات الرئيسية وبيانات الجدول في نفس الوقت
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

      // تخزين البيانات فوراً - هذا هو الحل لمشكلة الطباعة
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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(l.translate('requestDetails')),
        backgroundColor: const Color(0xFF6C63FF),
        actions: [
          // زر تغيير اللغة
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {
              final myAppState = MyApp.of(context);
              if (myAppState != null) {
                if (isArabic) {
                  myAppState.changeLanguage(const Locale('en', ''));
                } else {
                  myAppState.changeLanguage(const Locale('ar', ''));
                }
              }
            },
          ),
          // زر الطباعة - الآن يعمل من أول مرة
          IconButton(
            icon: const Icon(Icons.print_outlined, color: Colors.white),
            onPressed: (_masterData != null && _detailData != null)
                ? () => _printDocument(l)
                : null,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
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
          final detailData = snapshot.data!['detail'] as List<PurchaseRequestDetail>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMasterSection(l, masterData, isArabic),
                const SizedBox(height: 20),
                Text(
                  l.translate('itemDetails'),
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87),
                ),
                const SizedBox(height: 12),
                _buildDetailTable(l, detailData, isArabic),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==== الجزء 1: البيانات الرئيسية ====
  Widget _buildMasterSection(
      AppLocalizations l, PurchaseRequestMaster master, bool isArabic) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF6C63FF),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.translate('masterInfo'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1F36),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 1),
            _buildInfoRow(l.translate('store_name'), master.storeName ?? 'N/A'),
            _buildInfoRow(
                l.translate('item_name'),
                isArabic ? (master.descA ?? '') : (master.descE ?? '')),
            _buildInfoRow(l.translate('req_date'), master.formattedReqDate),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 180,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.task_alt),
                  label: Text(l.translate('takeAction')),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A1F36),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Amiri'),
                  ),
                  onPressed: () => _showActionDialog(context, l),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$title:',
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4A5568),
                  fontSize: 15),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ==== الجزء 2: زر اتخاذ القرار ====
  void _showActionDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            l.translate('takeAction'),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                title: Text(
                  l.translate('approve'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Approve action pending...')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red, size: 28),
                title: Text(
                  l.translate('reject'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reject action pending...')),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline, size: 28),
                title: Text(
                  l.translate('cancel'),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==== الجزء 3: جدول الأصناف المحسّن ====
  Widget _buildDetailTable(
      AppLocalizations l, List<PurchaseRequestDetail> details, bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(
            const Color(0xFF6C63FF).withOpacity(0.1),
          ),
          headingRowHeight: 56,
          dataRowMinHeight: 48,
          dataRowMaxHeight: 72,
          columnSpacing: 16,
          horizontalMargin: 16,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
          ),
          columns: [
            DataColumn(
              label: _buildHeaderCell(l.translate('store_code')),
            ),
            DataColumn(
              label: _buildHeaderCell(l.translate('group_name')),
            ),
            DataColumn(
              label: _buildHeaderCell(l.translate('item_name')),
            ),
            DataColumn(
              label: _buildHeaderCell(l.translate('unit_name')),
            ),
            DataColumn(
              label: _buildHeaderCell(l.translate('quantity')),
            ),
            DataColumn(
              label: _buildHeaderCell(l.translate('note')),
            ),
          ],
          rows: details.map((item) {
            return DataRow(
              cells: [
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: Text(
                      item.storeCode?.toString() ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 80, maxWidth: 150),
                    child: Text(
                      item.groupName ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 150, maxWidth: 250),
                    child: Text(
                      isArabic ? (item.itemNameA ?? '') : (item.itemNameE ?? ''),
                      style: const TextStyle(fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 60),
                    child: Text(
                      item.unitName ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 50),
                    child: Text(
                      item.quantity?.toString() ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Container(
                    constraints: const BoxConstraints(minWidth: 80, maxWidth: 150),
                    child: Text(
                      item.note ?? 'N/A',
                      style: const TextStyle(fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14,
        color: Color(0xFF1A1F36),
      ),
    );
  }

  // ==== الجزء 4: منطق الطباعة ====
  Future<void> _printDocument(AppLocalizations l) async {
    final isArabic = l.locale.languageCode == 'ar';
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    // نفس الأعمدة الموجودة في الجدول بالضبط
    final headers = [
      l.translate('store_code'),
      l.translate('group_name'),
      l.translate('item_name'),
      l.translate('unit_name'),
      l.translate('quantity'),
      l.translate('note'),
    ];

    // نفس البيانات الموجودة في الجدول بالضبط
    final data = _detailData!.map((item) => [
      item.storeCode?.toString() ?? 'N/A',
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
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(
              l.translate('requestDetails'),
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.Divider(thickness: 2),
          // البيانات الرئيسية
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('${l.translate('store_name')}: ${_masterData?.storeName ?? ''}'),
                pw.Text('${l.translate('req_date')}: ${_masterData?.formattedReqDate}'),
                pw.Text('${l.translate('item_name')}: ${isArabic ? (_masterData?.descA ?? '') : (_masterData?.descE ?? '')}'),
              ],
            ),
          ),
          pw.Divider(),
          // الجدول - نفس البيانات بالضبط
          pw.Table.fromTextArray(
            headers: headers,
            data: data,
            border: pw.TableBorder.all(color: PdfColors.grey),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
            cellStyle: const pw.TextStyle(fontSize: 10),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modernapproval/models/purchase_request_det_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../app_localizations.dart';
import '../../../main.dart';
import '../../../models/purchase_request_mast_model.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/error_display.dart';


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
      return {'master': _masterData, 'detail': _detailData};
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
        centerTitle: true,
        title: Text(l.translate('requestDetails'),style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
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
      body: FutureBuilder<Map<String, dynamic>>(
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
          final detailData = snapshot.data!['detail'] as List<PurchaseRequestDetail>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMasterSection(l, masterData, isArabic),
                const SizedBox(height: 24),
                // ==== ✅ استدعاء ودجت الجدول الجديدة ====
                _buildDetailTable(l, detailData, isArabic),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasterSection(
      AppLocalizations l, PurchaseRequestMaster master, bool isArabic) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.translate('masterInfo'),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColorDark,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow(l.translate('store_name'), master.storeName ?? 'N/A'),
            _buildInfoRow(
                l.translate('item_name'),
                isArabic ? (master.descA ?? '') : (master.descE ?? '')),
            _buildInfoRow(l.translate('req_date'), master.formattedReqDate),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.task_alt, size: 20),
                label: Text(l.translate('takeAction')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F36),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri'),
                ),
                onPressed: () => _showActionDialog(context, l),
              ),
            ),
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
            child: Text(value,
                style: const TextStyle(color: Colors.black87, height: 1.5)),
          ),
        ],
      ),
    );
  }

  // ==== ✅ ودجت الجدول الجديدة والاحترافية ====
  Widget _buildDetailTable(
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

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: MaterialStateProperty.all(Colors.grey.shade100),
          dataRowMinHeight: 60,
          dataRowMaxHeight: 80,
          columns: columns
              .map((title) => DataColumn(
              label: Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold))))
              .toList(),
          rows: details.map((item) {
            return DataRow(
              cells: [
                DataCell(Text(item.storeCode?.toString() ?? 'N/A')),
                DataCell(Text(item.storeName ?? 'N/A')),
                DataCell(Text(item.formattedReqDate)),
                DataCell(Text(item.groupName ?? 'N/A')),
                DataCell(SizedBox(
                  width: 200, // تحديد عرض لاسم الصنف
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
          }).toList(),
        ),
      ),
    );
  }

  void _showActionDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(l.translate('takeAction')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: Text(l.translate('approve')),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // TODO: Add Approve Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Approve action pending...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.red),
                title: Text(l.translate('reject')),
                onTap: () {
                  Navigator.pop(dialogContext);
                  // TODO: Add Reject Logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reject action pending...')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.remove_circle_outline),
                title: Text(l.translate('cancel')),
                onTap: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ==== ✅ ترقية شاملة لمنطق الطباعة ====
  Future<void> _printDocument(AppLocalizations l) async {
    final isArabic = l.locale.languageCode == 'ar';
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    final headers = [
      l.translate('item_name'),
      l.translate('group_name'),
      l.translate('quantity'),
      l.translate('unit_name'),
      l.translate('note'),
    ];

    final data = _detailData!.map((item) {
      return [
        isArabic ? (item.itemNameA ?? '') : (item.itemNameE ?? ''),
        item.groupName ?? 'N/A',
        item.quantity?.toString() ?? 'N/A',
        item.unitName ?? 'N/A',
        item.note ?? 'N/A',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
        header: (context) => _buildPdfHeader(l, ttf),
        footer: (context) => _buildPdfFooter(l, context, ttf),
        build: (context) => [
          _buildPdfMasterInfo(l, ttf),
          pw.SizedBox(height: 25),
          pw.Text(l.translate('itemDetails'), style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey, height: 10),
          _buildPdfTable(l, headers, data, ttf),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

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
              pw.Text("Modern Company",
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
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: ttf),
      headerDecoration:
      const pw.BoxDecoration(color: PdfColor.fromInt(0xFF6C63FF)),
      cellHeight: 35,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5), // Item Name
        1: const pw.FlexColumnWidth(2),   // Group Name
        2: const pw.FlexColumnWidth(1),   // Quantity
        3: const pw.FlexColumnWidth(1),   // Unit
        4: const pw.FlexColumnWidth(2.5), // Notes
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

*/


/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:modernapproval/models/purchase_request_det_model.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../app_localizations.dart';
import '../../../main.dart';
import '../../../models/purchase_request_mast_model.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/error_display.dart';


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
      return {'master': _masterData, 'detail': _detailData};
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
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        centerTitle: true,
        title: Text(l.translate('requestDetails'),style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
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
      body: FutureBuilder<Map<String, dynamic>>(
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
          final detailData = snapshot.data!['detail'] as List<PurchaseRequestDetail>;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMasterSection(l, masterData, isArabic),
                const SizedBox(height: 28),
                _buildDetailTable(l, detailData, isArabic),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMasterSection(
      AppLocalizations l, PurchaseRequestMaster master, bool isArabic) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.translate('masterInfo'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoRow(l.translate('store_name'), master.storeName ?? 'N/A'),
            const SizedBox(height: 12),
            _buildInfoRow(
                l.translate('item_name'),
                isArabic ? (master.descA ?? '') : (master.descE ?? '')),
            const SizedBox(height: 12),
            _buildInfoRow(l.translate('req_date'), master.formattedReqDate),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.task_alt, size: 20),
                label: Text(l.translate('takeAction')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A1F36),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Amiri'),
                  elevation: 2,
                ),
                onPressed: () => _showActionDialog(context, l),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF5A6C7D),
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Color(0xFF2C3E50),
              height: 1.5,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailTable(
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l.translate('itemDetails'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(const Color(0xFFF0F2F7)),
              dataRowMinHeight: 56,
              dataRowMaxHeight: 76,
              headingRowHeight: 52,
              dividerThickness: 0.8,
              columns: columns
                  .map((title) => DataColumn(
                  label: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2C3E50),
                      fontSize: 13,
                    ),
                  )))
                  .toList(),
              rows: details.map((item) {
                return DataRow(
                  color: MaterialStateProperty.resolveWith<Color?>(
                        (Set<MaterialState> states) {
                      if (details.indexOf(item) % 2 == 0) {
                        return const Color(0xFFFAFBFC);
                      }
                      return Colors.white;
                    },
                  ),
                  cells: [
                    DataCell(Text(
                      item.storeCode?.toString() ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(Text(
                      item.storeName ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(Text(
                      item.formattedReqDate,
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(Text(
                      item.groupName ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(SizedBox(
                      width: 180,
                      child: Text(
                        isArabic
                            ? (item.itemNameA ?? '')
                            : (item.itemNameE ?? ''),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF2C3E50),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )),
                    DataCell(Text(
                      item.unitName ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                    DataCell(Text(
                      item.quantity?.toString() ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF2C3E50),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )),
                    DataCell(Text(
                      item.note ?? 'N/A',
                      style: const TextStyle(
                        color: Color(0xFF5A6C7D),
                        fontSize: 13,
                      ),
                    )),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, AppLocalizations l) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(
            l.translate('takeAction'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2C3E50),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildActionTile(
                context: dialogContext,
                icon: Icons.check_circle,
                iconColor: const Color(0xFF27AE60),
                title: l.translate('approve'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Approve action pending...')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context: dialogContext,
                icon: Icons.cancel,
                iconColor: const Color(0xFFE74C3C),
                title: l.translate('reject'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Reject action pending...')),
                  );
                },
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                context: dialogContext,
                icon: Icons.remove_circle_outline,
                iconColor: const Color(0xFF95A5A6),
                title: l.translate('cancel'),
                onTap: () {
                  Navigator.pop(dialogContext);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE8EBF0), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==== ✅ ترقية شاملة لمنطق الطباعة ====
  Future<void> _printDocument(AppLocalizations l) async {
    final isArabic = l.locale.languageCode == 'ar';
    final fontData = await rootBundle.load("assets/fonts/Amiri-Regular.ttf");
    final ttf = pw.Font.ttf(fontData);

    final pdf = pw.Document();

    final headers = [
      l.translate('item_name'),
      l.translate('group_name'),
      l.translate('quantity'),
      l.translate('unit_name'),
      l.translate('note'),
    ];

    final data = _detailData!.map((item) {
      return [
        isArabic ? (item.itemNameA ?? '') : (item.itemNameE ?? ''),
        item.groupName ?? 'N/A',
        item.quantity?.toString() ?? 'N/A',
        item.unitName ?? 'N/A',
        item.note ?? 'N/A',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        textDirection: isArabic ? pw.TextDirection.rtl : pw.TextDirection.ltr,
        theme: pw.ThemeData.withFont(base: ttf, bold: ttf, italic: ttf),
        header: (context) => _buildPdfHeader(l, ttf),
        footer: (context) => _buildPdfFooter(l, context, ttf),
        build: (context) => [
          _buildPdfMasterInfo(l, ttf),
          pw.SizedBox(height: 25),
          pw.Text(l.translate('itemDetails'), style: pw.TextStyle(font: ttf, fontSize: 16, fontWeight: pw.FontWeight.bold)),
          pw.Divider(color: PdfColors.grey, height: 10),
          _buildPdfTable(l, headers, data, ttf),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

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
              pw.Text("Modern Company",
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
    return pw.Table.fromTextArray(
      headers: headers,
      data: data,
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      headerStyle: pw.TextStyle(
          fontWeight: pw.FontWeight.bold, color: PdfColors.white, font: ttf),
      headerDecoration:
      const pw.BoxDecoration(color: PdfColor.fromInt(0xFF6C63FF)),
      cellHeight: 35,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
      },
      cellPadding: const pw.EdgeInsets.all(6),
      columnWidths: {
        0: const pw.FlexColumnWidth(3.5), // Item Name
        1: const pw.FlexColumnWidth(2),   // Group Name
        2: const pw.FlexColumnWidth(1),   // Quantity
        3: const pw.FlexColumnWidth(1),   // Unit
        4: const pw.FlexColumnWidth(2.5), // Notes
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

 */



