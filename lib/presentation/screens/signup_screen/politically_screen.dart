import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';

class PoliticallyExposedScreen extends StatefulWidget {
  const PoliticallyExposedScreen({super.key});

  @override
  State<PoliticallyExposedScreen> createState() =>
      _PoliticallyExposedScreenState();
}

class _PoliticallyExposedScreenState extends State<PoliticallyExposedScreen> {
  bool _isPoliticallyExposed = false;
  String _politicianName = '';
  String _nationality = '';
  String _position = '';
  final TextEditingController _politicianNameController =
      TextEditingController();
  final TextEditingController _nationalityController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Politically exposed person?',
                style: theme.textTheme.headlineMedium,
              ),
              Row(
                children: [
                  Radio(
                    value: false,
                    groupValue: _isPoliticallyExposed,
                    onChanged: (value) {
                      setState(() {
                        _isPoliticallyExposed = value ?? false;
                      });
                    },
                  ),
                  Text('No', style: theme.textTheme.bodyLarge),
                  Radio(
                    value: true,
                    groupValue: _isPoliticallyExposed,
                    onChanged: (value) {
                      setState(() {
                        _isPoliticallyExposed = value ?? false;
                      });
                    },
                  ),
                  Text('Yes', style: theme.textTheme.bodyLarge),
                ],
              ),
              SizedBox(height: size.height / 40),
              if (_isPoliticallyExposed)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextFieldRow('Name of Politician',
                        _politicianNameController, theme, size, true),
                    SizedBox(height: size.height / 60),
                    _buildTextFieldRow('Nationality', _nationalityController,
                        theme, size, true),
                    SizedBox(height: size.height / 60),
                    _buildTextFieldRow(
                        'Position', _positionController, theme, size, true),
                    SizedBox(height: size.height / 60),
                    _buildTextFieldRow(
                        'Relation', _positionController, theme, size, true),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: NormalButton(
          size: size,
          title: 'Save',
          onPressed: _saveForm,
        ),
      ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller,
      ThemeData theme, Size size, bool isRequired) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: theme.textTheme.bodyMedium,
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  void _saveForm() {
    _politicianName = _politicianNameController.text.trim();
    _nationality = _nationalityController.text.trim();
    _position = _positionController.text.trim();

    if (_isPoliticallyExposed) {
      if (_politicianName.isEmpty ||
          _nationality.isEmpty ||
          _position.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please fill in all fields')),
        );
      } else {
        GoRouter.of(context).pushNamed(AppRouteConst.privacyPolicyRoute);
      }
    } else {
      GoRouter.of(context).pushNamed(AppRouteConst.privacyPolicyRoute);
    }
  }

  @override
  void dispose() {
    _politicianNameController.dispose();
    _nationalityController.dispose();
    _positionController.dispose();
    super.dispose();
  }
}
