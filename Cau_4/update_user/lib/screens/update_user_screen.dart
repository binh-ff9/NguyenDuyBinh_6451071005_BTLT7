import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';

class UpdateUserScreen extends StatefulWidget {
  const UpdateUserScreen({super.key});

  @override
  State<UpdateUserScreen> createState() => _UpdateUserScreenState();
}

class _UpdateUserScreenState extends State<UpdateUserScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Controllers cho từng trường
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isLoadingUser = true;
  bool _isUpdating = false;
  String? _loadError;
  User? _currentUser;
  User? _updatedUser;

  late AnimationController _fadeController;
  late AnimationController _successController;
  late Animation<double> _fadeAnim;
  late Animation<double> _successAnim;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);
    _successAnim = CurvedAnimation(
      parent: _successController,
      curve: Curves.elasticOut,
    );
    _loadUser();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _successController.dispose();
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _zipcodeController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  // Load dữ liệu cũ từ GET
  Future<void> _loadUser() async {
    setState(() {
      _isLoadingUser = true;
      _loadError = null;
    });

    try {
      final user = await _userService.fetchUser(1);
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
      _populateFields(user);
      _fadeController.forward();
    } catch (e) {
      setState(() {
        _loadError = e.toString();
        _isLoadingUser = false;
      });
    }
  }

  void _populateFields(User user) {
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _phoneController.text = user.phone;
    _websiteController.text = user.website;
    _streetController.text = user.street;
    _cityController.text = user.city;
    _zipcodeController.text = user.zipcode;
    _companyController.text = user.companyName;
  }

  // Gửi PUT request
  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;
    if (_currentUser == null) return;

    setState(() {
      _isUpdating = true;
      _updatedUser = null;
    });

    try {
      final updatedData = _currentUser!.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        website: _websiteController.text.trim(),
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        zipcode: _zipcodeController.text.trim(),
        companyName: _companyController.text.trim(),
      );

      final result = await _userService.updateUser(updatedData);

      setState(() {
        _updatedUser = result;
        _isUpdating = false;
      });

      _successController.forward(from: 0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Cập nhật thông tin thành công!',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: Color(0xFF00897B),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Lỗi: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFE53935),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F7F6),
      appBar: AppBar(
        title: const Text(
          'Cập Nhật Hồ Sơ',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF00796B),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isLoadingUser && _loadError == null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadUser,
              tooltip: 'Tải lại',
            ),
        ],
      ),
      body: _isLoadingUser
          ? _buildLoadingState()
          : _loadError != null
              ? _buildErrorState()
              : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Color(0xFF00796B),
            strokeWidth: 3,
          ),
          SizedBox(height: 16),
          Text(
            'Đang tải thông tin user...',
            style: TextStyle(
              color: Color(0xFF00796B),
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 72, color: Color(0xFFE53935)),
            const SizedBox(height: 16),
            const Text(
              'Không tải được dữ liệu!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _loadError ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadUser,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00796B),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _buildHeaderCard(),

            const SizedBox(height: 20),

            // Form card
            _buildFormCard(),

            const SizedBox(height: 20),

            // Result card (sau khi update thành công)
            if (_updatedUser != null) _buildResultCard(),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00796B), Color(0xFF26A69A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00796B).withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hồ sơ cá nhân',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentUser?.name ?? 'User',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${_currentUser?.username ?? ''}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'ID: ${_currentUser?.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chỉnh sửa thông tin',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2E2D),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Dữ liệu được tải từ GET và gửi lên server qua PUT',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),

            const SizedBox(height: 24),

            // Section: Thông tin cơ bản
            _buildSectionLabel('Thông tin cơ bản', Icons.badge_outlined),
            const SizedBox(height: 12),
            _buildField(
              controller: _nameController,
              label: 'Họ và tên',
              icon: Icons.person_outline,
              hint: 'Nhập họ và tên...',
              validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập họ tên' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _usernameController,
              label: 'Username',
              icon: Icons.alternate_email,
              hint: 'Nhập username...',
              validator: (v) => v!.trim().isEmpty ? 'Vui lòng nhập username' : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _emailController,
              label: 'Email',
              icon: Icons.email_outlined,
              hint: 'Nhập email...',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v!.trim().isEmpty) return 'Vui lòng nhập email';
                if (!v.contains('@')) return 'Email không hợp lệ';
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _phoneController,
              label: 'Số điện thoại',
              icon: Icons.phone_outlined,
              hint: 'Nhập số điện thoại...',
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _websiteController,
              label: 'Website',
              icon: Icons.language_outlined,
              hint: 'Nhập website...',
            ),

            const SizedBox(height: 24),

            // Section: Địa chỉ
            _buildSectionLabel('Địa chỉ', Icons.location_on_outlined),
            const SizedBox(height: 12),
            _buildField(
              controller: _streetController,
              label: 'Đường',
              icon: Icons.signpost_outlined,
              hint: 'Nhập tên đường...',
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildField(
                    controller: _cityController,
                    label: 'Thành phố',
                    icon: Icons.location_city_outlined,
                    hint: 'Thành phố...',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildField(
                    controller: _zipcodeController,
                    label: 'Zipcode',
                    icon: Icons.pin_outlined,
                    hint: 'Zipcode...',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Section: Công ty
            _buildSectionLabel('Công ty', Icons.business_outlined),
            const SizedBox(height: 12),
            _buildField(
              controller: _companyController,
              label: 'Tên công ty',
              icon: Icons.corporate_fare_outlined,
              hint: 'Nhập tên công ty...',
            ),

            const SizedBox(height: 32),

            // Update button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdating ? null : _updateUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00796B),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: const Color(0xFF00796B).withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: const Color(0xFF00796B).withOpacity(0.4),
                ),
                child: _isUpdating
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_rounded, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Lưu thông tin',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF00796B)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF00796B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFF00796B).withOpacity(0.2),
          ),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF455A64),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 14, color: Color(0xFF1A2E2D)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF00796B), size: 20),
            filled: true,
            fillColor: const Color(0xFFF3FAF9),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00796B), width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE53935), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard() {
    return ScaleTransition(
      scale: _successAnim,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF00897B).withOpacity(0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00897B).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00897B).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF00897B),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Cập nhật thành công!',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF00897B),
                        ),
                      ),
                      Text(
                        'Dữ liệu mới sau khi update:',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: Color(0xFFE0F2F1)),
            const SizedBox(height: 12),

            // Updated data display
            _buildResultRow(Icons.tag, 'ID', '${_updatedUser!.id}'),
            _buildResultRow(Icons.person_outline, 'Họ tên', _updatedUser!.name),
            _buildResultRow(Icons.alternate_email, 'Username', _updatedUser!.username),
            _buildResultRow(Icons.email_outlined, 'Email', _updatedUser!.email),
            _buildResultRow(Icons.phone_outlined, 'Phone', _updatedUser!.phone),
            _buildResultRow(Icons.language_outlined, 'Website', _updatedUser!.website),
            _buildResultRow(Icons.location_on_outlined, 'Địa chỉ',
                '${_updatedUser!.street}, ${_updatedUser!.city}'),
            _buildResultRow(Icons.corporate_fare_outlined, 'Công ty',
                _updatedUser!.companyName),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: const Color(0xFF00796B)),
          const SizedBox(width: 8),
          SizedBox(
            width: 72,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A2E2D),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Color(0xFF455A64)),
            ),
          ),
        ],
      ),
    );
  }
}
