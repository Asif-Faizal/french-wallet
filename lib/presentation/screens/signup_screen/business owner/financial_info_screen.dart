import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinancialInfoScreen extends StatefulWidget {
  const FinancialInfoScreen({super.key});

  @override
  State<FinancialInfoScreen> createState() => _FinancialInfoScreenState();
}

class _FinancialInfoScreenState extends State<FinancialInfoScreen> {
  final TextEditingController _tinController = TextEditingController();
  final TextEditingController _panController = TextEditingController();
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();

  String? _selectedTurnover;
  bool _isButtonEnabled = false;

  final List<String> _turnoverOptions = [
    'Below 1 crore',
    '1-5 crore',
    '5-10 crore',
    'Above 10 crore'
  ];

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled =
          _tinController.text.length == 12 && _panController.text.length == 12;
    });
  }

  @override
  void initState() {
    super.initState();
    _tinController.addListener(_updateButtonState);
    _panController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _tinController.dispose();
    _panController.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Financial Info',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _tinController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'TIN Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _panController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'PAN Number',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Annual Turnover',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              value: _selectedTurnover,
              items: _turnoverOptions
                  .map((turnover) => DropdownMenuItem<String>(
                        value: turnover,
                        child: Text(turnover),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTurnover = value;
                });
              },
            ),
            SizedBox(height: size.height / 40),
            const Text(
              'Registered Office Address',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _buildingController,
              decoration: InputDecoration(
                labelText: 'Building',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
            TextField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Pincode',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: size.height / 40),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Continue',
          onPressed: _isButtonEnabled
              ? () async {
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.setString('tinNumber', _tinController.text);
                  await prefs.setString('turnover', _selectedTurnover!);
                  await prefs.setString(
                      'companyBuilding', _buildingController.text);
                  await prefs.setString('companyCity', _cityController.text);
                  await prefs.setString(
                      'companyPincode', _pincodeController.text);
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.businessInfoRoute);
                }
              : null,
        ),
      ),
    );
  }
}
