import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../shared/router/router_const.dart';
import '../../widgets/shared/otp_bottom_sheet.dart';

class EmailDetailsScreen extends StatefulWidget {
  const EmailDetailsScreen({super.key});

  @override
  State<EmailDetailsScreen> createState() => _EmailDetailsScreenState();
}

class _EmailDetailsScreenState extends State<EmailDetailsScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isButtonEnabled = false;
  String _userType = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_updateButtonState);
    _retrieveData();
  }

  @override
  void dispose() {
    _emailController.removeListener(_updateButtonState);
    _emailController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _emailController.text.isNotEmpty;
    });
  }

  bool _validateEmail(String email) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _retrieveData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userType = prefs.getString('userType') ?? 'default_value';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: NormalAppBar(text: 'Email Details'),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height / 60),
              Text('Add Email', style: theme.textTheme.headlineMedium),
              SizedBox(height: size.height / 60),
              _buildEmailRow('Email', _emailController, theme, size, true),
              Spacer(),
              NormalButton(
                size: size,
                title: 'Verify',
                onPressed: _isButtonEnabled ? _saveForm : null,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailRow(String label, TextEditingController controller,
      ThemeData theme, Size size, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: size.height / 14,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _saveForm() async {
    if (_validateEmail(_emailController.text)) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('email', _emailController.text);
      _showOtpBottomSheet(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid email address')),
      );
    }
  }

  void _showOtpBottomSheet(BuildContext context) {
    final size = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      builder: (BuildContext context) {
        return OtpBottomSheet(
          number: _emailController.text,
          userType: _userType,
          size: size,
          navigateTo: AppRouteConst.incomeDetailsRoute,
        );
      },
    );
  }
}
