import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OccupationIncomeDetailsScreen extends StatefulWidget {
  const OccupationIncomeDetailsScreen({super.key});

  @override
  State<OccupationIncomeDetailsScreen> createState() =>
      _OccupationIncomeDetailsScreenState();
}

class _OccupationIncomeDetailsScreenState
    extends State<OccupationIncomeDetailsScreen> {
  final TextEditingController _panNumberController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _tinNumberController = TextEditingController();
  String? _userType;
  String? _selectedCorporate;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String? _selectedOccupation;
  String? _selectedAnnualIncome;
  bool _isButtonEnabled = false;

  final List<String> _occupations = [
    'Salaried',
    'Self-Employed',
    'Business',
    'Student',
    'Retired',
    'Other'
  ];

  final List<String> _annualIncomes = [
    'Below 1 Lakh',
    '1 Lakh - 5 Lakhs',
    '5 Lakhs - 10 Lakhs',
    'Above 10 Lakhs'
  ];

  @override
  void initState() {
    super.initState();
    _retrieveData();
    _panNumberController.addListener(_updateButtonState);
    _businessNameController.addListener(_updateButtonState);
    _tinNumberController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _panNumberController.removeListener(_updateButtonState);
    _businessNameController.removeListener(_updateButtonState);
    _tinNumberController.removeListener(_updateButtonState);
    _panNumberController.dispose();
    _businessNameController.dispose();
    _tinNumberController.dispose();
    super.dispose();
  }

  void _retrieveData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userType = prefs.getString('userType') ?? '';
      _selectedCorporate = prefs.getString('corporateType') ?? '';
      print(_userType);
      print(_selectedCorporate);
      _updateButtonState(); // Ensure to update button state after retrieving data
    });
  }

  void _updateButtonState() {
    setState(() {
      if (_userType == 'corporate' && _selectedCorporate == 'business-owner') {
        _isButtonEnabled = _selectedOccupation != null &&
            _selectedAnnualIncome != null &&
            _businessNameController.text.isNotEmpty &&
            _tinNumberController.text.isNotEmpty &&
            _panNumberController.text.isNotEmpty;
      } else {
        _isButtonEnabled = _panNumberController.text.isNotEmpty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: NormalAppBar(text: 'Income Details'),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownRow('Occupation', _occupations, _selectedOccupation,
                  (value) {
                setState(() {
                  _selectedOccupation = value;
                  _updateButtonState();
                });
              }, theme, size),
              SizedBox(height: size.height / 60),
              _buildDropdownRow(
                  'Annual Income', _annualIncomes, _selectedAnnualIncome,
                  (value) {
                setState(() {
                  _selectedAnnualIncome = value;
                  _updateButtonState();
                });
              }, theme, size),
              SizedBox(height: size.height / 30),
              _buildTextFieldRow('PAN Number', _panNumberController, theme,
                  size, true, 'Enter PAN Number'),
              SizedBox(height: size.height / 60),
              if (_userType == 'corporate' &&
                  _selectedCorporate == 'business-owner')
                _buildTextFieldRow('Business Name', _businessNameController,
                    theme, size, true, 'Enter Business Name'),
              SizedBox(height: size.height / 60),
              if (_userType == 'corporate' &&
                  _selectedCorporate == 'business-owner')
                _buildTextFieldRow('TIN Number', _tinNumberController, theme,
                    size, true, 'Enter TIN Number'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
        child: NormalButton(
          size: size,
          title: 'Save',
          onPressed: _isButtonEnabled ? _saveForm : null,
        ),
      ),
    );
  }

  Widget _buildDropdownRow(
      String label,
      List<String> items,
      String? selectedItem,
      ValueChanged<String?> onChanged,
      ThemeData theme,
      Size size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<String>(
              value: selectedItem,
              onChanged: onChanged,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFieldRow(String label, TextEditingController controller,
      ThemeData theme, Size size, bool isRequired, String labelText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        height: size.height / 14,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            labelStyle: theme.textTheme.bodyMedium,
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  void _saveForm() {
    if (_selectedOccupation == null ||
        _selectedAnnualIncome == null ||
        _panNumberController.text.isEmpty ||
        (_userType == 'corporate' &&
            _selectedCorporate == 'business-owner' &&
            (_businessNameController.text.isEmpty ||
                _tinNumberController.text.isEmpty))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
    } else {
      GoRouter.of(context).pushNamed(AppRouteConst.politicallyExposedRoute);
    }
  }
}
