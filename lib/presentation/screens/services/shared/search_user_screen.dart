import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:go_router/go_router.dart';

import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import '../../../../shared/router/router_const.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final TextEditingController _phoneController = TextEditingController();
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'FR');
  String? _selectedWalletType;
  bool _isButtonEnabled = false;

  final List<String> _walletTypes = [
    'Type 1',
    'Type 2',
    'Type 3',
  ];

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validateInputs);
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validateInputs);
    _phoneController.dispose();
    super.dispose();
  }

  void _validateInputs() {
    setState(() {
      _isButtonEnabled =
          _phoneController.text.length == 10 && _selectedWalletType != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height / 30,
          horizontal: size.width / 20,
        ),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              value: _selectedWalletType,
              hint: Text('Select wallet type'),
              items: _walletTypes.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWalletType = newValue;
                });
                _validateInputs();
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
            ),
            SizedBox(height: size.height / 30),
            Row(
              children: [
                Expanded(
                  child: InternationalPhoneNumberInput(
                    onInputChanged: (PhoneNumber number) {
                      setState(() {
                        _phoneNumber = number;
                      });
                    },
                    selectorConfig: const SelectorConfig(
                      selectorType: PhoneInputSelectorType.DROPDOWN,
                    ),
                    ignoreBlank: false,
                    autoValidateMode: AutovalidateMode.disabled,
                    initialValue: _phoneNumber,
                    textFieldController: _phoneController,
                    formatInput: false,
                    keyboardType: const TextInputType.numberWithOptions(
                        signed: true, decimal: true),
                    inputDecoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintText: AppLocalizations.of(context)!.mobile_number,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: NormalButton(
          onPressed: _isButtonEnabled
              ? () {
                  _showAlertDialog(
                    'Username',
                    _phoneController.text,
                  );
                }
              : null,
          size: size,
          title: 'Search',
        ),
      ),
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                child: Icon(Icons.person),
              ),
              SizedBox(
                width: 10,
              ),
              Text(title),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(context).pushNamed(AppRouteConst.enterAmountRoute);
              },
            ),
          ],
        );
      },
    );
  }
}
