import 'dart:convert';
import 'package:ewallet2/shared/country_code.dart';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import '../../../../shared/config/api_config.dart';

class RetailReceiveScreen extends StatefulWidget {
  const RetailReceiveScreen({super.key});

  @override
  State<RetailReceiveScreen> createState() => _RetailReceiveScreenState();
}

class _RetailReceiveScreenState extends State<RetailReceiveScreen> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isButtonEnabled = false;
  Iterable<Contact> _contacts = [];

  final List<Map<String, String>> _countryCodes = CountryCode.countryCodes;
  String _selectedCountryCode = 'IN';
  String _selectedCountryDialCode = '+91';

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
    _requestContactPermission();
  }

  @override
  void dispose() {
    _phoneController.removeListener(_validatePhoneNumber);
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    setState(() {
      _isButtonEnabled = _phoneController.text.length >= 10;
    });
  }

  void _showCountryCodePicker() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text('Select Country Code'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _countryCodes.map((country) {
                return ListTile(
                  leading: Text(
                    country['flag']!,
                    style: TextStyle(fontSize: 24),
                  ),
                  title: Text('${country['name']} (${country['dialCode']})'),
                  onTap: () {
                    setState(() {
                      _selectedCountryCode = country['code']!;
                      _selectedCountryDialCode = country['dialCode']!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestContactPermission() async {
    final permissionStatus = await Permission.contacts.request();
    if (permissionStatus.isGranted) {
      _loadContacts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching Contacts'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _loadContacts() async {
    final contacts = await ContactsService.getContacts();
    setState(() {
      _contacts = contacts;
    });
  }

  void _showContactPicker() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text('Loading Contacts'),
          content: CircularProgressIndicator(),
        );
      },
    );

    // Fetch contacts
    await _requestContactPermission();

    // Close the loading indicator
    Navigator.of(context).pop();

    // Show the bottom sheet with the contacts
    showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      context: context,
      builder: (context) {
        return Column(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (context, index) {
                  final contact = _contacts.elementAt(index);
                  return ListTile(
                    leading:
                        (contact.avatar != null && contact.avatar!.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar!),
                              )
                            : CircleAvatar(child: Text(contact.initials())),
                    title: Text(contact.displayName ?? ''),
                    subtitle:
                        contact.phones != null && contact.phones!.isNotEmpty
                            ? Text(contact.phones!.first.value ?? '')
                            : null,
                    onTap: () {
                      if (contact.phones != null &&
                          contact.phones!.isNotEmpty) {
                        final phoneNumber = contact.phones!.first.value ?? '';
                        _phoneController.text = phoneNumber;
                        separatePhoneAndDialCode(
                            phoneNumber); // Update country code
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void separatePhoneAndDialCode(String phoneNumber) {
    Map<String, String> foundedCountry = {};
    for (var country in _countryCodes) {
      String dialCode = country["dialCode"] ?? '';
      if (phoneNumber.startsWith(dialCode)) {
        foundedCountry = country;
        break;
      }
    }

    if (foundedCountry.isNotEmpty) {
      var dialCode = foundedCountry["dialCode"]!;
      var newPhoneNumber = phoneNumber.substring(dialCode.length);
      setState(() {
        _selectedCountryCode = foundedCountry["code"]!;
        _selectedCountryDialCode = dialCode;
        _phoneController.text = newPhoneNumber;
      });
      print({'dialCode': dialCode, 'newPhoneNumber': newPhoneNumber});
    }
  }

  Future<void> _sendHardcodedRequest() async {
    final url = Config.check_benificiary;

    final requestPayload = [
      {
        "phoneNumbers": [
          {"label": "mobile", "number": "+9651800407267864"},
          {"label": "mobile", "number": "+965 65840897"},
          {"label": "mobile", "number": "+9651800407267864"}
        ]
      },
    ];

    final requestBody = jsonEncode(requestPayload);

    print('Request URL: $url');
    print('Request Headers: ${{
      'Content-Type': 'application/json',
      'Deviceid': Config.deviceId,
      'Authorization': Config.token
    }}');
    print('Request Body: $requestBody');

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': Config.token
      },
      body: requestBody,
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: 'Receive Money'),
      body: Padding(
        padding: EdgeInsets.symmetric(
          vertical: size.height / 60,
          horizontal: size.width / 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 20),
            Text(
              'Enter Phone Number',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: size.height / 40),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: _showCountryCodePicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Text(
                            _selectedCountryDialCode,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                      hintText: 'Phone Number',
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _showContactPicker,
                  child: Text(
                    'Select from Contacts',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            Spacer(),
            ElevatedButton(
                onPressed: _sendHardcodedRequest, child: Text('test')),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Submit',
          onPressed: _isButtonEnabled ? () {} : null,
        ),
      ),
    );
  }
}
