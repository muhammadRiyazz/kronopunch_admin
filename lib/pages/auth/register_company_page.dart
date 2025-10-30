import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kronopunch/pages/dashboard/layout/main_layout.dart';
import '../../services/firebase_service.dart';
import '../../models/company_model.dart';

class RegisterCompanyPage extends StatefulWidget {
  const RegisterCompanyPage({super.key});

  @override
  State<RegisterCompanyPage> createState() => _RegisterCompanyPageState();
}

class _RegisterCompanyPageState extends State<RegisterCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final _companyName = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _phone = TextEditingController();
  final _altPhone = TextEditingController();
  final _state = TextEditingController();
  final _district = TextEditingController();
  final _address = TextEditingController();
  final _description = TextEditingController();

  bool _loading = false;
  bool _obscure = true;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final company = Company(
        password: _password.text.trim(),
        companyName: _companyName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        altPhone: _altPhone.text.trim().isEmpty ? null : _altPhone.text.trim(),
        state: _state.text.trim(),
        district: _district.text.trim(),
        address: _address.text.trim(),
        description: _description.text.trim().isEmpty ? null : _description.text.trim(),
        companyCode: '',
        createdAt: DateTime.now(),
      );

      await FirebaseService.registerCompany(
        email: _email.text.trim(),
        company: company,
      );

      final snapshot = await FirebaseFirestore.instance
          .collection('companies')
          .where('email', isEqualTo: _email.text.trim())
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final savedCompany = Company.fromMap(
          snapshot.docs.first.data(),
          snapshot.docs.first.id,
        );

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainLayout()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: SafeArea(
        child: isWide
            ? Row(
                children: [
                  // 🔹 Left image/gradient
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF5B2CFF), Color(0xFFE91E63)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Create Your Company",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 38,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Set up your KronoPunch account and manage your team, attendance, and more — all in one place.",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 🔹 Right form
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(40),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 500),
                          child: _buildForm(),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            // 🔹 Mobile Layout
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    const Text(
                      "Register Company",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5B2CFF),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Create your company account and start managing employees easily.",
                      style: TextStyle(color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _buildForm(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _inputField("Company Name", _companyName, Icons.business),
          _inputField("Email", _email, Icons.email),
          _passwordField(),
          _inputField("Phone", _phone, Icons.phone),
          _inputField("Alternative Phone (optional)", _altPhone, Icons.phone_android),
          _inputField("State", _state, Icons.map),
          _inputField("District", _district, Icons.location_city),
          _inputField("Address", _address, Icons.home),
          _inputField("Description (optional)", _description, Icons.info_outline),
          const SizedBox(height: 20),

          // 🔹 Register Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _loading ? null : _register,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'Register Company',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔹 Back to Login
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "← Already have an account? Login",
              style: TextStyle(color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(String label, TextEditingController controller, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.isEmpty ? 'Enter $label' : null,
      ),
    );
  }

  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: _password,
        obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Password',
          prefixIcon: const Icon(Icons.lock),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
      ),
    );
  }
}
