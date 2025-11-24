import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../app_localizations.dart';
import '../../widgets/info_dialog.dart';
import '../../utils/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  final int user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isLoadingProfile = false;
  bool _isLoadingImage = false;
  bool _isUploadingImage = false;

  Map<String, dynamic>? _profileData;
  String? _profileImageUrl;
  String? _currentImageError;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
  }

  void _initializeProfile() {
    _profileImageUrl =
        'http://195.201.241.253:7001/ords/modern/Approval/emp_photo/${widget.user}';
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;

    setState(() {
      _isLoadingProfile = true;
    });

    try {
      print('🔄 Loading profile data for user: ${widget.user}');

      final response = await http
          .get(
            Uri.parse(
              'http://195.201.241.253:7001/ords/modern/Approval/emp_info/${widget.user}',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📡 Profile API Response Status: ${response.statusCode}');
      print('📡 Profile API Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] != null && data['items'].isNotEmpty) {
          setState(() {
            _profileData = data['items'][0];
          });
          print('✅ Profile data loaded successfully');
        } else {
          print('⚠️ No profile data found in response');
          _showErrorDialog('profile_not_found');
        }
      } else {
        print('❌ Failed to load profile: ${response.statusCode}');
        _showErrorDialog('failed_to_load_profile');
      }
    } catch (e) {
      print('❌ Exception loading profile: $e');
      _showErrorDialog('network_error');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        print('❌ No internet connection');
        _showErrorDialog('no_internet_connection');
        return false;
      }

      final result = await http
          .get(
            Uri.parse(
              'http://195.201.241.253:7001/ords/modern/Approval/emp_info/${widget.user}',
            ),
          )
          .timeout(const Duration(seconds: 5));

      return result.statusCode == 200;
    } catch (e) {
      print('❌ Internet connection test failed: $e');
      _showErrorDialog('connection_test_failed');
      return false;
    }
  }

  Future<void> _showImageSourceDialog() async {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            localizations.translate('select_image_source')!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        localizations.translate('camera_emulator_note')!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF6C63FF)),
                title: Text(localizations.translate('camera')!),
                subtitle: Text(
                  localizations.translate('camera_subtitle')!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF6C63FF),
                ),
                title: Text(localizations.translate('gallery')!),
                subtitle: Text(
                  localizations.translate('gallery_subtitle')!,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                localizations.translate('cancel')!,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      print('🔄 Picking image from ${source.toString()}');

      int maxWidth = source == ImageSource.camera ? 600 : 800;
      int maxHeight = source == ImageSource.camera ? 600 : 800;
      int imageQuality = source == ImageSource.camera ? 70 : 85;

      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: imageQuality,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (image != null) {
        print('✅ Image selected: ${image.path}');

        final fileSize = await image.length();
        print('📏 Image file size: ${fileSize} bytes');

        if (fileSize > 5 * 1024 * 1024) {
          _showErrorDialog('image_too_large');
          return;
        }

        await _uploadImage(image);
      } else {
        print('ℹ️ No image selected');
      }
    } catch (e) {
      print('❌ Error picking image: $e');

      String errorKey = 'image_pick_error';
      if (e.toString().contains('channel-error')) {
        errorKey = 'image_picker_channel_error';
      } else if (e.toString().contains('camera_access_denied')) {
        errorKey = 'camera_permission_denied';
      } else if (e.toString().contains('photo_access_denied')) {
        errorKey = 'gallery_permission_denied';
      } else if (e.toString().contains('camera_access_denied') ||
          e.toString().contains('Camera not available')) {
        final localizations = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localizations.translate('camera_not_available_using_gallery') ??
                  'Camera not available, using gallery instead',
            ),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );
        _pickImage(ImageSource.gallery);
        return;
      }

      _showErrorDialog(errorKey);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    if (!mounted) return;

    if (!await _checkInternetConnection()) {
      return;
    }

    setState(() {
      _isUploadingImage = true;
    });

    try {
      print('🔄 Starting image upload...');

      final bytes = await image.readAsBytes();

      print('📏 Image bytes length: ${bytes.length}');

      List<int> finalBytes = bytes;
      if (bytes.length > 1024 * 1024) {
        print('🗜️ Compressing large image...');
      }

      final base64Image = base64Encode(finalBytes);
      print(
        '📤 Image converted to base64, size: ${base64Image.length} characters',
      );

      if (base64Image.length > 2 * 1024 * 1024) {
        print('⚠️ Base64 image too large: ${base64Image.length} characters');
        _showErrorDialog('image_too_large');
        return;
      }

      final requestData = {'emp_id': widget.user, 'photo': base64Image};

      print('📤 Sending POST request to upload image...');
      print('📤 Request data keys: ${requestData.keys}');
      print('📤 Employee ID: ${widget.user}');
      print('📤 Photo length: ${base64Image.length}');

      final response = await http
          .post(
            Uri.parse(
              'http://195.201.241.253:7001/ords/modern/Approval/emp_photo/${widget.user}',
            ),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Cache-Control': 'no-cache',
            },
            body: json.encode(requestData),
          )
          .timeout(const Duration(seconds: 45));

      print('📡 Upload Response Request ${requestData}');
      print('📡 Upload Response Status: ${response.statusCode}');
      print('📡 Upload Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final responseData = json.decode(response.body);
          if (responseData['status'] == 'error') {
            print('❌ Server returned error: ${responseData['message']}');
            _showErrorDialog('server_error');
            return;
          }
        } catch (e) {}

        print('✅ Image uploaded successfully');

        await _reloadProfileImage();

        final localizations = AppLocalizations.of(context)!;
        _showSuccessDialog('image_updated_successfully');
      } else {
        print('❌ Failed to upload image: ${response.statusCode}');
        _showErrorDialog('image_upload_failed');
      }
    } catch (e) {
      print('❌ Exception uploading image: $e');
      if (e.toString().contains('TimeoutException')) {
        _showErrorDialog('upload_timeout');
      } else if (e.toString().contains('SocketException')) {
        _showErrorDialog('network_error');
      } else {
        _showErrorDialog('image_upload_error');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  Future<void> _reloadProfileImage() async {
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _currentImageError = null;

        _profileImageUrl =
            'http://195.201.241.253:7001/ords/modern/Approval/emp_photo/${widget.user}?t=${DateTime.now().millisecondsSinceEpoch}';
      });
    }
  }

  void _showErrorDialog(String messageKey) {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => InfoDialog(
            title: localizations.translate('error')!,
            message: localizations.translate(messageKey)!,
            isSuccess: false,
            buttonText: localizations.translate('ok'),
          ),
    );
  }

  void _showSuccessDialog(String messageKey) {
    if (!mounted) return;

    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder:
          (context) => InfoDialog(
            title: localizations.translate('success')!,
            message: localizations.translate(messageKey)!,
            isSuccess: true,
            buttonText: localizations.translate('ok'),
          ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '-';

    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getSocialStatus(int? status) {
    final localizations = AppLocalizations.of(context)!;
    switch (status) {
      case 0:
        return localizations.translate('single')!;
      case 1:
        return localizations.translate('married')!;
      case 2:
        return localizations.translate('divorced')!;
      case 3:
        return localizations.translate('widowed')!;
      default:
        return '-';
    }
  }

  String _getGender(String? gender) {
    final localizations = AppLocalizations.of(context)!;
    if (gender == 'M') return localizations.translate('male')!;
    if (gender == 'F') return localizations.translate('female')!;
    return '-';
  }

  String _getReligion(int? religionType) {
    final localizations = AppLocalizations.of(context)!;
    switch (religionType) {
      case 1:
        return localizations.translate('muslim')!;
      case 2:
        return localizations.translate('christian')!;
      case 3:
        return localizations.translate('jewish')!;
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF6C63FF),
        title: Text(
          localizations.translate('personal_profile')!,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.language, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body:
          _isLoadingProfile
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF6C63FF)),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل البيانات...',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
              : _profileData == null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      localizations.translate('failed_to_load_profile')!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadProfileData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                      ),
                      child: Text(
                        localizations.translate('retry')!,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildProfileImageSection(),
                    const SizedBox(height: 24),

                    _buildPersonalInfoCard(),
                    const SizedBox(height: 16),

                    _buildWorkInfoCard(),
                    const SizedBox(height: 16),

                    _buildContactInfoCard(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfileImageSection() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF6C63FF), width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child:
                      _isLoadingImage || _isUploadingImage
                          ? Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF6C63FF),
                                strokeWidth: 2,
                              ),
                            ),
                          )
                          : Image.network(
                            _profileImageUrl!,
                            width: 132,
                            height: 132,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF6C63FF),
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              print('❌ Error loading profile image: $error');
                              return Container(
                                color: Colors.grey.shade200,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey.shade400,
                                ),
                              );
                            },
                          ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _isUploadingImage ? null : _showImageSourceDialog,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isUploadingImage
                          ? Icons.hourglass_empty
                          : Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Text(
            _profileData!['emp_name'] ?? '-',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            _profileData!['job_desc'] ?? '-',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
          ),

          if (_isUploadingImage) ...[
            const SizedBox(height: 12),
            Text(
              localizations.translate('uploading_image')!,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      title: localizations.translate('personal_information')!,
      icon: Icons.person_outline,
      children: [
        _buildInfoRow(
          localizations.translate('employee_code')!,
          _profileData!['emp_code']?.toString() ?? '-',
          Icons.badge_outlined,
        ),
        _buildInfoRow(
          localizations.translate('national_id')!,
          _profileData!['users_code']?.toString() ?? '-',
          Icons.credit_card_outlined,
        ),
        _buildInfoRow(
          localizations.translate('birth_date')!,
          _formatDate(_profileData!['birth_date']),
          Icons.cake_outlined,
        ),
        _buildInfoRow(
          localizations.translate('birth_place')!,
          _profileData!['birth_plc'] ?? '-',
          Icons.location_on_outlined,
        ),
        _buildInfoRow(
          localizations.translate('gender')!,
          _getGender(_profileData!['gender']),
          Icons.wc_outlined,
        ),
        _buildInfoRow(
          localizations.translate('social_status')!,
          _getSocialStatus(_profileData!['social_status']),
          Icons.family_restroom_outlined,
        ),
        _buildInfoRow(
          localizations.translate('religion')!,
          _getReligion(_profileData!['religion_type']),
          Icons.mosque_outlined,
        ),
      ],
    );
  }

  Widget _buildWorkInfoCard() {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      title: localizations.translate('work_information')!,
      icon: Icons.work_outline,
      children: [
        _buildInfoRow(
          localizations.translate('job_title')!,
          _profileData!['job_desc'] ?? '-',
          Icons.work_outline,
        ),
        _buildInfoRow(
          localizations.translate('job_code')!,
          _profileData!['job_code']?.toString() ?? '-',
          Icons.numbers_outlined,
        ),
        _buildInfoRow(
          localizations.translate('company_employee_code')!,
          _profileData!['comp_emp_code']?.toString() ?? '-',
          Icons.business_outlined,
        ),
      ],
    );
  }

  Widget _buildContactInfoCard() {
    final localizations = AppLocalizations.of(context)!;

    return _buildInfoCard(
      title: localizations.translate('contact_information')!,
      icon: Icons.contact_mail_outlined,
      children: [
        _buildInfoRow(
          localizations.translate('current_address')!,
          _profileData!['current_address'] ?? '-',
          Icons.home_outlined,
          isLongText: true,
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                child: Icon(icon, color: const Color(0xFF6C63FF), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon, {
    bool isLongText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment:
            isLongText ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade500, size: 20),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF2D3748),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }
}
