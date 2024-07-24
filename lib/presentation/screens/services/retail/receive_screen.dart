import 'dart:convert';
import 'package:ewallet2/shared/country_code.dart';
import 'package:go_router/go_router.dart';
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
      _isButtonEnabled = _phoneController.text.length >= 5;
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

  Future<void> _sendContactsRequest(List<String> phoneNumbers) async {
    final url = Config.check_benificiary;

    final requestPayload =
        // [
        //   {
        //     "phoneNumbers": [
        //       {"label": "mobile", "number": "+9651800407267864"},
        //       {"label": "mobile", "number": "+965 65840897"},
        //       {"label": "mobile", "number": "+9651800407267864"}
        //     ]
        //   },
        //   {
        //     "phoneNumbers": [
        //       {"label": "mobile", "number": "+919566036720"},
        //       {"label": "mobile", "number": "+919566036720"},
        //       {"label": "mobile", "number": "+919566036720"}
        //     ]
        //   },
        //   {"phoneNumbers": []}
        // ];

        [
      {
        "phoneNumbers": phoneNumbers.map((number) {
          return {"label": "mobile", "number": number};
        }).toList()
      },
    ];

    final requestBody = jsonEncode(requestPayload);
    print(requestBody);
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': Config.token
      },
      body: requestBody,
    );
    print(response.body);

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'Success' && responseData['data'] != null) {
        showModalBottomSheet(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          context: context,
          builder: (context) {
            return Padding(
              padding: EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ePurse Users',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    ...responseData['data'].map<Widget>((contact) {
                      final firstName = contact['firstName'] ?? '';
                      final lastName = contact['lastName'] ?? '';
                      final phoneNumber = contact['phoneNumber'] ?? '';
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            firstName.isNotEmpty
                                ? firstName[0]
                                : lastName.isNotEmpty
                                    ? lastName[0]
                                    : '?',
                          ),
                        ),
                        title: Text('$firstName $lastName'),
                        subtitle: Text(phoneNumber),
                        onTap: () {
                          final separatedPhone =
                              _separatePhoneAndDialCode(phoneNumber);
                          _phoneController.text = separatedPhone['phone']!;
                          setState(() {
                            _selectedCountryDialCode =
                                separatedPhone['dialCode']!;
                          });
                          Navigator.pop(context);
                        },
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _checkMobileForTransaction(String phoneNumber) async {
    final url = Config.check_mobile_for_transaction;

    final requestPayload = {"mobile_no": phoneNumber};

    final requestBody = jsonEncode(requestPayload);

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': Config.token
      },
      body: requestBody,
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['status'] == 'Success') {
        print(
            '########################################$phoneNumber######################################');
        GoRouter.of(context).go('/enterAmount/$phoneNumber');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Transaction failed: ${responseData['message']}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${response.statusCode}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
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
    Navigator.of(context).pop();

    List<String> phoneNumbers = [];

    for (final contact in _contacts) {
      if (contact.phones != null && contact.phones!.isNotEmpty) {
        for (final phone in contact.phones!) {
          final phoneNumber = phone.value?.replaceAll(' ', '') ?? '';
          phoneNumbers.add(phoneNumber);
        }
      }
    }

    if (phoneNumbers.isNotEmpty) {
      _sendContactsRequest(phoneNumbers);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please wait for some time to fetch the Contacts'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Map<String, String> _separatePhoneAndDialCode(String phoneNumber) {
    for (final country in _countryCodes) {
      final dialCode = country['dialCode']!;
      if (phoneNumber.startsWith(dialCode)) {
        return {
          'dialCode': dialCode,
          'phone': phoneNumber.substring(dialCode.length),
        };
      }
    }
    return {
      'dialCode': '+91', // Default to India if no match is found
      'phone': phoneNumber,
    };
  }

  void _submit() {
    final fullNumber = '$_selectedCountryDialCode${_phoneController.text}';
    _checkMobileForTransaction(fullNumber);
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
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Submit',
          onPressed: _isButtonEnabled ? _submit : null,
        ),
      ),
    );
  }
}
