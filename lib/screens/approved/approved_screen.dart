import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:modernapproval/models/approved_request_model.dart';
import 'package:modernapproval/screens/approvals/purchase_request_approval/purchase_request_detail_screen.dart';
import '../../../app_localizations.dart';
import '../../../models/purchase_request_model.dart';
import '../../../models/user_model.dart';
import '../../../services/api_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/error_display.dart';

class ApprovedScreen extends StatefulWidget {
  final UserModel user;

  const ApprovedScreen({super.key, required this.user});

  @override
  State<ApprovedScreen> createState() => _ApprovedScreenState();
}

class _ApprovedScreenState extends State<ApprovedScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<ApprovedRequest>> _requestsFuture;

  String _storeNameFilter = '';
  DateTime? _selectedDate;
  List<ApprovedRequest> _filteredRequests = [];
  bool _showFilters = false;

  // ألوان واضحة وقوية
  final List<Color> _cardColors = [
    const Color(0xFF5B9BD5), // أزرق
    const Color(0xFF70AD47), // أخضر
    const Color(0xFFF4A460), // برتقالي
    const Color(0xFF8E8EBD), // بنفسجي
    const Color(0xFFE67E7E), // أحمر فاتح
    const Color(0xFF9B9B9B), // رمادي
  ];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _requestsFuture = _apiService.getApprovedRequests(
        userId: widget.user.usersCode,
      );
    });
  }

  void _applyFilters(List<ApprovedRequest> allRequests) {
    setState(() {
      _filteredRequests =
          allRequests.where((request) {
            // If both filters are empty, show all
            if (_storeNameFilter.isEmpty && _selectedDate == null) {
              return true;
            }

            bool matchesStoreName = true;
            bool matchesDate = true;

            // Apply store name filter only if it's not empty
            if (_storeNameFilter.isNotEmpty) {
              matchesStoreName = (request.storeName ?? '')
                  .toLowerCase()
                  .contains(_storeNameFilter.toLowerCase());
            }

            // Apply date filter only if a date is selected
            if (_selectedDate != null) {
              matchesDate =
                  request.trnsDate != null &&
                  _isSameDate(request.trnsDate!, _selectedDate!);
            }

            return matchesStoreName && matchesDate;
          }).toList();
    });
  }

  bool _isSameDate(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _clearFilters() {
    setState(() {
      _storeNameFilter = '';
      _selectedDate = null;
      _showFilters = false;
    });
    _requestsFuture.then((data) => _applyFilters(data));
  }

  Widget _buildFilterWidget() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Filter toggle button
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            color: Colors.white,
          ),
          onPressed: () {
            setState(() {
              _showFilters = !_showFilters;
            });
          },
        ),

        // Clear filters button (visible when filters are active)
        if (_storeNameFilter.isNotEmpty || _selectedDate != null)
          IconButton(
            icon: Icon(Icons.clear, color: Colors.white),
            onPressed: _clearFilters,
          ),
      ],
    );
  }

  Widget _buildFilterSection() {
    if (!_showFilters) return SizedBox.shrink();
    final l = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          // Store name filter
          SizedBox(
            height: 46,
            child: TextField(
              decoration: InputDecoration(
                labelText: l.translate('filter_by_store_name'),
                prefixIcon: Icon(Icons.store, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(28)),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _storeNameFilter = value;
                });
                _requestsFuture.then((data) => _applyFilters(data));
              },
            ),
          ),

          SizedBox(height: 8),

          // Date filter
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showDatePicker(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 18),
                        SizedBox(width: 8),
                        Text(
                          _selectedDate == null
                              ? l.translate('filter_by_date')
                              : DateFormat('yyyy-MM-dd').format(_selectedDate!),
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_selectedDate != null) ...[
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    setState(() {
                      _selectedDate = null;
                    });
                    _requestsFuture.then((data) => _applyFilters(data));
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _requestsFuture.then((data) => _applyFilters(data));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        title: l.translate('approvedRequests'),
        filterWidget: _buildFilterWidget(),
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),

          // List content
          Expanded(
            child: FutureBuilder<List<ApprovedRequest>>(
              future: _requestsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: const Color(0xFF7CB9E8),
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l.translate('loading') ?? 'Loading...',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return ErrorDisplay(
                    errorMessageKey:
                        snapshot.error.toString().contains('noInternet')
                            ? 'noInternet'
                            : 'serverError',
                    onRetry: _fetchData,
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7CB9E8).withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.inventory_2_outlined,
                            size: 64,
                            color: const Color(0xFF7CB9E8).withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l.translate('noData'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l.translate('noRequestsAvailable') ??
                              'No requests available',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final allRequests = snapshot.data!;

                // Apply filters when data loads or when filtered list is empty
                if (_filteredRequests.isEmpty &&
                    _storeNameFilter.isEmpty &&
                    _selectedDate == null) {
                  _filteredRequests = allRequests;
                }

                final displayRequests =
                    _showFilters &&
                            (_storeNameFilter.isNotEmpty ||
                                _selectedDate != null)
                        ? _filteredRequests
                        : allRequests;

                // Show filter results info
                if (_showFilters &&
                    (_storeNameFilter.isNotEmpty || _selectedDate != null)) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8),
                        color: Colors.blue.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l.translate(
                                'resultsFound',
                                params: {
                                  "resultLength": "${displayRequests.length}",
                                },
                              ),
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: _clearFilters,
                              child: Text(l.translate('clearFilters')),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: displayRequests.length,
                          itemBuilder: (context, index) {
                            return _buildApprovedRequestCard(
                              context,
                              displayRequests[index],
                              index,
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: displayRequests.length,
                  itemBuilder: (context, index) {
                    return _buildApprovedRequestCard(
                      context,
                      displayRequests[index],
                      index,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedRequestCard(
    BuildContext context,
    ApprovedRequest request,
    int index,
  ) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final cardColor = _cardColors[index % _cardColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            //todo apply navigation later on
            // final result = await Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder:
            //         (context) => PurchaseRequestDetailScreen(
            //       user: widget.user,
            //       request: request,
            //     ),
            //   ),
            // );
            //
            // if (result == true) {
            //   print("✅ Navigated back from Details, refreshing list...");
            //   _fetchData();
            // }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: cardColor.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.description_outlined,
                    color: cardColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.store_outlined,
                            size: 15,
                            color: cardColor,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              request.storeName ?? 'N/A',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: cardColor,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isArabic
                            ? (request.trnsDesc ?? '')
                            : (request.trnsDesc ?? ''),
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.black87,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 13,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                request.formattedTrnsDate,
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                request.authPk1! + " / " + request.authPk2!,
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  isArabic ? Icons.chevron_left : Icons.chevron_right,
                  size: 25,
                  color: Colors.grey.shade500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
