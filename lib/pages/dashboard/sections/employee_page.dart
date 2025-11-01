import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kronopunch/pages/dashboard/sections/emplyee%20widget/image_picker.dart';
import 'package:kronopunch/pages/dashboard/sections/emplyee%20widget/shrimmer.dart';
import 'dart:io';
import 'package:kronopunch/services/firebase_emp_services.dart';

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  final _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _joiningDateController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedDepartment = 'Sales';
  String _selectedRole = 'Employee';
  String? _profileImageUrl;
  File? _selectedImageFile;

  bool _showAddEmployeeForm = false;
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isImageUploading = false;
  String? _editingEmployeeId;

  List<Map<String, dynamic>> _employees = [];
  final List<String> _departments = ['Sales', 'HR', 'Tech', 'Marketing', 'Finance', 'Operations'];
  final List<String> _roles = ['Employee', 'HR', 'Manager', 'Admin'];

  Map<String, int> _stats = {
    'total': 0,
    'present': 0,
    'onLeave': 0,
    'departments': 0,
  };

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _loadStats();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final employees = await FirebaseEmployeeService.loadEmployees();
      setState(() {
        _employees = employees;
      });
    } catch (e) {
      _showErrorSnackBar('Failed to load employees');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadStats() async {
    try {
      final stats = await FirebaseEmployeeService.getEmployeeStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      log('Error loading stats: $e');
    }
  }

  Future<void> _addEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _profileImageUrl;

      // Upload image if new file is selected
      if (_selectedImageFile != null) {
        setState(() {
          _isImageUploading = true;
        });
        
        final fileName = 'employee_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await FirebaseEmployeeService.uploadImage(
          _selectedImageFile!, 
          fileName
        );
        
        setState(() {
          _isImageUploading = false;
        });
      }

      final employeeData = {
        'name': _nameController.text.trim(),
        'department': _selectedDepartment,
        'position': _positionController.text.trim(),
        'contact': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'joiningDate': _joiningDateController.text.trim(),
        'place': _placeController.text.trim(),
        'gender': _selectedGender,
        'password': _passwordController.text.trim(),
        'role': _selectedRole,
        'avatar': imageUrl ?? 'https://i.pravatar.cc/150?img=${_employees.length + 1}',
        'status': 'Present',
      };
 
      await FirebaseEmployeeService.addEmployee(employeeData);

      _showSuccessSnackBar('Employee added successfully!');
      _cancelForm();
      await _loadEmployees();
      await _loadStats();
    } catch (e) {
      log(e.toString());
      _showErrorSnackBar('Failed to add employee');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String? imageUrl = _profileImageUrl;

      // Upload new image if selected
      if (_selectedImageFile != null) {
        setState(() {
          _isImageUploading = true;
        });
        
        final fileName = 'employee_${DateTime.now().millisecondsSinceEpoch}.jpg';
        imageUrl = await FirebaseEmployeeService.uploadImage(
          _selectedImageFile!, 
          fileName
        );
        
        setState(() {
          _isImageUploading = false;
        });
      }

      final employeeData = {
        'name': _nameController.text.trim(),
        'department': _selectedDepartment,
        'position': _positionController.text.trim(),
        'contact': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        'joiningDate': _joiningDateController.text.trim(),
        'place': _placeController.text.trim(),
        'gender': _selectedGender,
        'role': _selectedRole,
        'avatar': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Only update password if it's not empty
      if (_passwordController.text.isNotEmpty) {
        employeeData['password'] = _passwordController.text.trim();
      }

      await FirebaseEmployeeService.updateEmployee(_editingEmployeeId!, employeeData);

      _showSuccessSnackBar('Employee updated successfully!');
      _cancelForm();
      await _loadEmployees();
      await _loadStats();
    } catch (e) {
      _showErrorSnackBar('Failed to update employee');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployee(String employeeId) async {
    try {
      await FirebaseEmployeeService.deleteEmployee(employeeId);
      _showSuccessSnackBar('Employee deleted successfully!');
      await _loadEmployees();
      await _loadStats();
    } catch (e) {
      _showErrorSnackBar('Failed to delete employee');
    }
  }

  Future<void> _changeProfileImage() async {
    try {
      final File? imageFile = await ImagePickerService.showImageSourceDialog(context);
      
      if (imageFile != null) {
        setState(() {
          _selectedImageFile = imageFile;
          _profileImageUrl = null;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image');
    }
  }

  void _editEmployee(Map<String, dynamic> employee) {
    setState(() {
      _showAddEmployeeForm = true;
      _isEditing = true;
      _editingEmployeeId = employee['id'];
      _selectedImageFile = null;
      
      // Fill form with employee data
      _nameController.text = employee['name'] ?? '';
      _phoneController.text = employee['contact'] ?? '';
      _emailController.text = employee['email'] ?? '';
      _joiningDateController.text = employee['joiningDate'] ?? '';
      _placeController.text = employee['place'] ?? '';
      _positionController.text = employee['position'] ?? '';
      _employeeIdController.text = employee['customEmployeeId'] ?? employee['documentId'] ?? '';
      _passwordController.text = employee['password'] ?? '';
      _selectedGender = employee['gender'] ?? 'Male';
      _selectedDepartment = employee['department'] ?? 'Sales';
      _selectedRole = employee['role'] ?? 'Employee';
      _profileImageUrl = employee['avatar'];
    });
  }

  void _showEmployeeForm() {
    setState(() {
      _showAddEmployeeForm = true;
      _isEditing = false;
      _clearForm();
    });
  }

  void _cancelForm() {
    setState(() {
      _showAddEmployeeForm = false;
      _clearForm();
    });
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    _joiningDateController.clear();
    _placeController.clear();
    _positionController.clear();
    _employeeIdController.clear();
    _passwordController.clear();
    _selectedGender = 'Male';
    _selectedDepartment = 'Sales';
    _selectedRole = 'Employee';
    _profileImageUrl = null;
    _selectedImageFile = null;
    _isEditing = false;
    _editingEmployeeId = null;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _joiningDateController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  List<Map<String, dynamic>> get _filteredEmployees {
    if (_searchController.text.isEmpty) {
      return _employees;
    }
    
    final query = _searchController.text.toLowerCase();
    return _employees.where((employee) {
      final name = (employee['name'] ?? '').toString().toLowerCase();
      final department = (employee['department'] ?? '').toString().toLowerCase();
      final position = (employee['position'] ?? '').toString().toLowerCase();
      final employeeId = ((employee['customEmployeeId'] ?? employee['documentId'] ?? '')).toString().toLowerCase();
      final email = (employee['email'] ?? '').toString().toLowerCase();
      
      return name.contains(query) ||
          department.contains(query) ||
          position.contains(query) ||
          employeeId.contains(query) ||
          email.contains(query);
    }).toList();
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 12, left: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Icon(Icons.lock_outline, color: Colors.indigo.shade500),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (!_isEditing && (value == null || value.isEmpty)) {
          return 'Please enter password';
        }
        return null;
      },
    );
  }

  Widget _buildFormField(String label, TextEditingController controller, 
      IconData icon, TextInputType keyboardType, {VoidCallback? onTap, bool readOnly = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 12, left: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Icon(icon, color: Colors.indigo.shade500),
        ),
        filled: true,
        fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onTap: onTap,
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, IconData icon) {
    return DropdownButtonFormField<String>(
      value: value.isNotEmpty ? value : null,
      style: TextStyle(
        color: Colors.grey.shade800,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: Colors.grey.shade600,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Container(
          margin: const EdgeInsets.only(right: 12, left: 8),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          child: Icon(icon, color: Colors.indigo.shade500),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.indigo.shade400, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          if (label == 'Gender') _selectedGender = value!;
          else if (label == 'Department') _selectedDepartment = value!;
          else if (label == 'Role') _selectedRole = value!;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select $label';
        }
        return null;
      },
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
      icon: Icon(Icons.arrow_drop_down, color: Colors.indigo.shade500),
      hint: Text(
        'Select $label',
        style: TextStyle(color: Colors.grey.shade500),
      ),
    );
  }

  Widget _buildMobileFormFields() {
    return Column(
      children: [
        _buildFormField('Full Name', _nameController, Icons.person_outline, TextInputType.name),
        const SizedBox(height: 16),
        _buildFormField('Phone Number', _phoneController, Icons.phone_iphone, TextInputType.phone),
        const SizedBox(height: 16),
        _buildFormField('Email Address', _emailController, Icons.email_outlined, TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildFormField('Joining Date', _joiningDateController, Icons.calendar_month_outlined, TextInputType.datetime,
            onTap: () => _selectDate(context)),
        const SizedBox(height: 16),
        _buildFormField('Place', _placeController, Icons.location_on_outlined, TextInputType.streetAddress),
        const SizedBox(height: 16),
        _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'], Icons.female_outlined),
        const SizedBox(height: 16),
        _buildDropdown('Department', _selectedDepartment, _departments, Icons.business_center_outlined),
        const SizedBox(height: 16),
        _buildFormField('Position', _positionController, Icons.work_outline, TextInputType.text),
        const SizedBox(height: 16),
        _buildFormField('Employee ID', _employeeIdController, Icons.badge_outlined, TextInputType.text,
           ),
        const SizedBox(height: 16),
        _buildDropdown('Role', _selectedRole, _roles, Icons.admin_panel_settings_outlined),
      ],
    );
  }

  Widget _buildDesktopFormFields(double width) {
    final bool useSingleColumn = width < 1000;
    
    if (useSingleColumn) {
      return Column(
        children: [
          _buildFormField('Full Name', _nameController, Icons.person_outline, TextInputType.name),
          const SizedBox(height: 16),
          _buildFormField('Phone Number', _phoneController, Icons.phone_iphone, TextInputType.phone),
          const SizedBox(height: 16),
          _buildFormField('Email Address', _emailController, Icons.email_outlined, TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildFormField('Joining Date', _joiningDateController, Icons.calendar_month_outlined, TextInputType.datetime,
              onTap: () => _selectDate(context)),
          const SizedBox(height: 16),
          _buildFormField('Place', _placeController, Icons.location_on_outlined, TextInputType.streetAddress),
          const SizedBox(height: 16),
          _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'], Icons.female_outlined),
          const SizedBox(height: 16),
          _buildDropdown('Department', _selectedDepartment, _departments, Icons.business_center_outlined),
          const SizedBox(height: 16),
          _buildFormField('Position', _positionController, Icons.work_outline, TextInputType.text),
          const SizedBox(height: 16),
          _buildFormField('Employee ID', _employeeIdController, Icons.badge_outlined, TextInputType.text,
              ),
          const SizedBox(height: 16),
          _buildDropdown('Role', _selectedRole, _roles, Icons.admin_panel_settings_outlined),
        ],
      );
    } else {
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFormField('Full Name', _nameController, Icons.person_outline, TextInputType.name)),
              const SizedBox(width: 20),
              Expanded(child: _buildFormField('Phone Number', _phoneController, Icons.phone_iphone, TextInputType.phone)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildFormField('Email Address', _emailController, Icons.email_outlined, TextInputType.emailAddress)),
              const SizedBox(width: 20),
              Expanded(child: _buildPasswordField()),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildFormField('Joining Date', _joiningDateController, Icons.calendar_month_outlined, TextInputType.datetime,
                  onTap: () => _selectDate(context))),
              const SizedBox(width: 20),
              Expanded(child: _buildFormField('Place', _placeController, Icons.location_on_outlined, TextInputType.streetAddress)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdown('Gender', _selectedGender, ['Male', 'Female', 'Other'], Icons.female_outlined)),
              const SizedBox(width: 20),
              Expanded(child: _buildDropdown('Department', _selectedDepartment, _departments, Icons.business_center_outlined)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildFormField('Position', _positionController, Icons.work_outline, TextInputType.text)),
              const SizedBox(width: 20),
              Expanded(child: _buildFormField('Employee ID', _employeeIdController, Icons.badge_outlined, TextInputType.text,
                 )),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(child: _buildDropdown('Role', _selectedRole, _roles, Icons.admin_panel_settings_outlined)),
              const SizedBox(width: 20),
              Expanded(child: Container()),
            ],
          ),
        ],
      );
    }
  }

  Widget _buildImageSection() {
    return Container(
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 220,
            height: 190,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.indigo.shade100,
            ),
            child: _isImageUploading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _selectedImageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          _selectedImageFile!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      )
                    : _profileImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              _profileImageUrl!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.indigo.shade300,
                                );
                              },
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60,
                            color: Colors.indigo.shade300,
                          ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _changeProfileImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade50,
                foregroundColor: Colors.indigo.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.indigo.shade200, width: 1.5),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.camera_alt, size: 20),
              label: const Text(
                'Add Photo',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'JPG, PNG or GIF. Max 5MB',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      children: [
        _buildImageSection(),
        const SizedBox(height: 32),
        _buildMobileFormFields(),
      ],
    );
  }

  Widget _buildDesktopLayout(double width) {
    if (width >= 1100) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(width: 32),
          Expanded(
            child: _buildDesktopFormFields(width),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(height: 32),
          _buildDesktopFormFields(width),
        ],
      );
    }
  }

  Widget _buildEmployeeForm(BuildContext context, bool isMobile) {
    final width = MediaQuery.of(context).size.width;

    return Card(
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _isEditing ? Icons.edit : Icons.person_add_alt_1,
                              color: Colors.indigo.shade700,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _isEditing ? 'Edit Employee' : 'Add New Employee',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.indigo.shade900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: _cancelForm,
                          icon: Icon(Icons.close, color: Colors.grey.shade700),
                          tooltip: 'Close',
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 28),

                // Main Content - Image on side and form fields
                isMobile ? _buildMobileLayout() : _buildDesktopLayout(width),

                const SizedBox(height: 32),

                // Action Buttons
                Container(
                  padding: const EdgeInsets.only(top: 20),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade300, width: 1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: _cancelForm,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.indigo.shade600,
                              Colors.purple.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.indigo.shade300,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isImageUploading) ? null : (_isEditing ? _updateEmployee : _addEmployee),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 25),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: _isLoading || _isImageUploading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  _isEditing ? 'Update Employee' : 'Add Employee',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Employees Overview 👨‍💼",
          style: TextStyle(
            fontSize: 20, 
            fontWeight: FontWeight.bold, 
            color: Colors.grey.shade800
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage employee details, attendance, and department assignments",
          style: TextStyle(
            color: Colors.grey.shade600, 
            fontSize: 14
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(double width) {
    final isMobile = width < 600;
    int crossAxisCount;
    
    if (width >= 1200) {
      crossAxisCount = 4;
    } else if (width >= 1000) {
      crossAxisCount = 3;
    } else if (width >= 900) {
      crossAxisCount = 2;
    } else {
      crossAxisCount = 2;
    }

    if (_isLoading && _employees.isEmpty) {
      return ShimmerLoading.summaryGridShimmer(count: crossAxisCount);
    }

    final summary = [
      {'title': 'Total Employees', 'value': _stats['total'].toString(), 'icon': Icons.people_alt},
      {'title': 'Present Today', 'value': _stats['present'].toString(), 'icon': Icons.access_time},
      {'title': 'On Leave', 'value': _stats['onLeave'].toString(), 'icon': Icons.beach_access},
      {'title': 'Departments', 'value': _stats['departments'].toString(), 'icon': Icons.apartment},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isMobile ? 10 : 15,
      mainAxisSpacing: isMobile ? 10 : 15,
      childAspectRatio: crossAxisCount == 2 ? 2.5 : (isMobile ? 1.6 : 2.0),
      children: summary.map((item) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  child: Icon(
                    item['icon'] as IconData,
                    color: Colors.indigo.shade700, 
                    size: isMobile ? 22 : 26
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item['title'] as String,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: isMobile ? 12 : 14,
                        ),
                      ),
                      Text(
                        item['value'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: isMobile ? 16 : 18
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSearchAndAdd(BuildContext context, bool isMobile) {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: "Search employee by name, department, email or ID",
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (v) => setState(() {}),
        ),
        if (!isMobile) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Wrap(
                  spacing: 12,
                  children: [
                    _buildActionButton(
                      'Add Employee', 
                      Icons.add, 
                      Colors.indigo.shade700, 
                      () => _showEmployeeForm()
                    ),
                    _buildActionButton(
                      'Refresh', 
                      Icons.refresh, 
                      Colors.green.shade700, 
                      () => _loadEmployees()
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else if (isMobile) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Employee', 
                  Icons.add, 
                  Colors.indigo.shade700, 
                  () => _showEmployeeForm()
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'Refresh', 
                  Icons.refresh, 
                  Colors.green.shade700, 
                  () => _loadEmployees()
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: Icon(icon, color: Colors.white, size: 18),
      label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 14)),
    );
  }

  Widget _buildEmployeeTable(BuildContext context, double width) {
    final filteredEmployees = _filteredEmployees;

    if (_isLoading) {
      return ShimmerLoading.employeeTableShimmer(count: 5);
    }

    if (filteredEmployees.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResultsFound();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), 
            blurRadius: 8, 
            offset: const Offset(0, 3)
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: width - 300),
          child: DataTable(
            columnSpacing: 24,
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade50),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            dataRowHeight: 70,
            border: TableBorder(
              horizontalInside: BorderSide(color: Colors.grey.shade100),
              borderRadius: BorderRadius.circular(16),
            ),
            columns: const [
              DataColumn(label: Text('Employee')),
              DataColumn(label: Text('Department')),
              DataColumn(label: Text('Status')),
              DataColumn(label: Text('Contact')),
              DataColumn(label: Text('Actions')),
            ],
            rows: filteredEmployees.map((e) {
              final statusColor = _getStatusColor(e['status'] ?? 'Present');
              return DataRow(
                cells: [
                  DataCell(
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: (e['avatar'] != null && e['avatar'].toString().isNotEmpty) 
                              ? NetworkImage(e['avatar'].toString()) 
                              : null,
                          radius: 20,
                          child: (e['avatar'] == null || e['avatar'].toString().isEmpty)
                              ? Icon(Icons.person, color: Colors.grey.shade400)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              e['name'] ?? '', 
                              style: const TextStyle(fontWeight: FontWeight.w600)
                            ),
                            const SizedBox(height: 3),
                            Text(
                              e['position'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              e['customEmployeeId'] ?? e['documentId'] ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  ),
                  DataCell(Text(e['department'] ?? '')),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8)
                      ),
                      child: Text(
                        e['status'] ?? 'Present',
                        style: TextStyle(
                          color: statusColor, 
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    )
                  ),
                  DataCell(Text(e['contact'] ?? '')),
                  DataCell(
                    Row(
                      children: [
                        _buildTableButton('Edit', Icons.edit, () => _editEmployee(e)),
                        const SizedBox(width: 8),
                        _buildTableButton('Delete', Icons.delete, () => _confirmDeleteEmployee(e)),
                      ],
                    )
                  ),
                ]
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeListMobile(BuildContext context) {
    final filteredEmployees = _filteredEmployees;

    if (_isLoading) {
      return ShimmerLoading.employeeListShimmer(count: 5);
    }

    if (filteredEmployees.isEmpty && _searchController.text.isNotEmpty) {
      return _buildNoResultsFound();
    }

    return Column(
      children: filteredEmployees.map((employee) {
        final statusColor = _getStatusColor(employee['status'] ?? 'Present');
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: (employee['avatar'] != null && employee['avatar'].toString().isNotEmpty) 
                          ? NetworkImage(employee['avatar'].toString()) 
                          : null,
                      radius: 24,
                      child: (employee['avatar'] == null || employee['avatar'].toString().isEmpty)
                          ? Icon(Icons.person, color: Colors.grey.shade400)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            employee['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            employee['position'] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            employee['customEmployeeId'] ?? employee['documentId'] ?? '',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        employee['status'] ?? 'Present',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildTableButton('Edit', Icons.edit, () => _editEmployee(employee)),
                    const SizedBox(width: 8),
                    _buildTableButton('Delete', Icons.delete, () => _confirmDeleteEmployee(employee)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTableButton(String text, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: text == 'Edit' 
            ? const Color(0xFF1A237E).withOpacity(0.1)
            : const Color(0xFF1A237E),
        foregroundColor: text == 'Edit' ? const Color(0xFF1A237E) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      icon: Icon(icon, size: 16),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 12, 
          color: text == 'Edit' ? const Color(0xFF1A237E) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: [
        ShimmerLoading.summaryGridShimmer(count: 4),
        const SizedBox(height: 20),
        ShimmerLoading.employeeListShimmer(count: 5),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Employees Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first employee to get started',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _showEmployeeForm,
            icon: const Icon(Icons.add),
            label: const Text('Add Employee'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search terms',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Present':
        return Colors.green;
      case 'On Leave':
        return Colors.orange;
      case 'Late':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  void _confirmDeleteEmployee(Map<String, dynamic> employee) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: Text('Are you sure you want to delete ${employee['name'] ?? 'this employee'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _deleteEmployee(employee['id']);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Padding(
      padding: EdgeInsets.only(
        top: 0,
        right: isMobile ? 16 : 30,
        left: isMobile ? 16 : 30,
        bottom: 0,
      ),
      child: Stack(
        children: [
          ListView(
            children: [              const SizedBox(height: 20),

              _buildHeader(context),
              const SizedBox(height: 20),
              _buildSummaryCards(width),
              const SizedBox(height: 20),
              _buildSearchAndAdd(context, isMobile),
              const SizedBox(height: 20),
              
              // Show form or employee list
              if (_showAddEmployeeForm)
                _buildEmployeeForm(context, isMobile)
              else if (_isLoading && _employees.isEmpty)
                _buildLoadingState()
              else if (_employees.isEmpty)
                _buildEmptyState()
              else if (isMobile) 
                _buildEmployeeListMobile(context)
              else
                _buildEmployeeTable(context, width),              const SizedBox(height: 20),

            ],
          ),
          
          if (_isLoading && _showAddEmployeeForm) 
            _buildLoadingOverlay(),
        ],
      ),
    );
  }
}