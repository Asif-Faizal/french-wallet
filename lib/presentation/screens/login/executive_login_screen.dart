import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ExecutiveLoginScreen extends StatefulWidget {
  const ExecutiveLoginScreen({super.key});

  @override
  State<ExecutiveLoginScreen> createState() => _ExecutiveLoginScreenState();
}

class _ExecutiveLoginScreenState extends State<ExecutiveLoginScreen> {
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _referenceNumberController =
      TextEditingController();
  bool _isButtonEnabled = false;

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _companyNameController.text.isNotEmpty &&
          _referenceNumberController.text.length == 14;
    });
  }

  @override
  void initState() {
    super.initState();
    _companyNameController.addListener(_updateButtonState);
    _referenceNumberController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height / 20,
            ),
            TextField(
              controller: _companyNameController,
              decoration: InputDecoration(
                labelText: 'Company Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              maxLength: 14,
              controller: _referenceNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Reference Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: NormalButton(
          size: size,
          title: 'Continue',
          onPressed: _isButtonEnabled
              ? () {
                  GoRouter.of(context).pushNamed(AppRouteConst.loginRoute);
                }
              : null,
        ),
      ),
    );
  }
}
