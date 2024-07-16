import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: 'Privacy Policy'),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Declaration of Correctness:',
                '''I, hereby declare that all the information provided by me for KYC verification in Innovitegra eWallet is true, accurate, and complete to the best of my knowledge. I understand that providing false or misleading information may result in the rejection of my application or termination of services.
              '''),
            _buildSection('Consent for KYC Verification and data usage:',
                '''By agreeing to this declaration, I consent to Innovitegra Solutions Private Limited conducting KYC verification checks using the information provided by me. I also acknowledge and agree that my personal data will be processed and used in accordance with Innovitegra's privacy policy.
              '''),
            _buildSectionWithLinks('Privacy policy and Terms of Use:', '''
              '''),
            _buildSection('Confirmation:',
                '''I confirm that I have read, understood, and agreed to the terms and conditions, privacy policy, and any other legal agreements governing the use of Innovitegra eWallet services.
              '''),
            SizedBox(height: size.height / 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: SizedBox(
          height: size.height / 7,
          child: Column(
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() {
                        _isChecked = value ?? false;
                      });
                    },
                  ),
                  Text('I have read and agree to the Privacy Policy',
                      style: theme.textTheme.bodyMedium),
                ],
              ),
              NormalButton(
                size: size,
                title: 'Accept',
                onPressed: _isChecked ? _navigateToNextScreen : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSectionWithLinks(String title, String content) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style:
              theme.textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: theme.textTheme.bodyMedium,
            children: [
              TextSpan(text: 'Please review our '),
              TextSpan(
                text: ' Privacy Policy ',
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _showPolicyDialog('Privacy Policy', '''
                    This is the privacy policy content. It explains how we collect, use, and protect your personal information.
                    ''');
                  },
              ),
              TextSpan(text: ' and '),
              TextSpan(
                text: ' Terms of Use ',
                style: TextStyle(
                  color: Colors.blue,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    _showPolicyDialog('Terms of Use', '''
                    These are the terms of use content. It explains the rules and regulations for using our service.
                    ''');
                  },
              ),
              TextSpan(
                text:
                    ' to understand how we collect, store, process, and share your personal data. This includes information about data security, sharing with third parties, and your rights regarding your personal information.',
              ),
            ],
          ),
        ),
        SizedBox(height: 8),
        Text(
          content,
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }

  void _navigateToNextScreen() {
    GoRouter.of(context).pushNamed(AppRouteConst.setPassCodeRoute);
  }

  void _showPolicyDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: Text(content),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
