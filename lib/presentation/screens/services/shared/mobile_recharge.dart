import 'dart:convert';

import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/config/api_config.dart';
import '../../../../shared/country_code.dart';
import '../../../../shared/router/router_const.dart';
import '../../../widgets/shared/normal_appbar.dart';
import '../../../widgets/shared/normal_button.dart';

class MobileRecharge extends StatefulWidget {
  const MobileRecharge({super.key});

  @override
  State<MobileRecharge> createState() => _MobileRechargeState();
}

class _MobileRechargeState extends State<MobileRecharge> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _amount = TextEditingController();
  bool _isButtonEnabled = false;
  Iterable<Contact> _contacts = [];
  bool _contactsLoaded = false;

  final List<Map<String, String>> _countryCodes = CountryCode.countryCodes;
  String _selectedCountryDialCode = '+91';
  final billPaymentCode = '1001';
  static const appRefId = '123456789012';

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
      _contactsLoaded = true;
    });
  }

  Future<void> _sendContactsRequest(List<String> phoneNumbers) async {
    final url = Config.check_benificiary;

    final requestPayload = [
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
                    Text(
                      'Non-ePurse Users',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    SizedBox(height: 10),
                    ..._contacts.where((contact) {
                      final phoneNumber = contact.phones?.isNotEmpty == true
                          ? contact.phones!.first.value?.replaceAll(' ', '')
                          : null;
                      return phoneNumber != null &&
                          responseData['data'].every((userContact) =>
                              userContact['phoneNumber'] != phoneNumber);
                    }).map<Widget>((contact) {
                      final displayName = contact.displayName ?? '';
                      final phoneNumber = contact.phones?.isNotEmpty == true
                          ? contact.phones!.first.value?.replaceAll(' ', '')
                          : '';
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            displayName.isNotEmpty ? displayName[0] : '?',
                          ),
                        ),
                        title: Text(displayName),
                        subtitle: Text(phoneNumber ?? ''),
                        trailing: TextButton(
                          child: Text('Invite'),
                          onPressed: () {},
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            );
          },
        );
      } else if (responseData['status'] == 'Fail') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${responseData['message']}'),
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
          'phone': phoneNumber.substring(dialCode.length)
        };
      }
    }
    return {'dialCode': '', 'phone': phoneNumber};
  }

  void _submit() {
    _submitMobileRecharge(context, _phoneController.text, '1');
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: 'Recharge Mobile'),
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
                Container(
                  height: size.height / 15,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10))),
                    onPressed: _showCountryCodePicker,
                    child: Text(
                      _selectedCountryDialCode,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  flex: 3,
                  child: Container(
                    height: size.height / 15,
                    child: TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_contactsLoaded)
                  TextButton(
                    child: Text('Select from Contacts'),
                    onPressed: _showContactPicker,
                  )
                else
                  TextButton(
                    child: Text('Loading Contacts...'),
                    onPressed: null,
                  ),
              ],
            ),
            SizedBox(
              height: size.height / 60,
            ),
            TextField(
              controller: _amount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  label: Text('Enter Amount')),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: size,
          title: 'Recharge',
          onPressed: _isButtonEnabled ? _submit : null,
        ),
      ),
    );
  }

  void _showSnackBar(
      BuildContext context, String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _submitMobileRecharge(
      BuildContext context, String accountNumber, String amount) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');

    String? refreshToken = prefs.getString('refresh_token');
    print('JWT Token: $jwtToken');
    print('Refresh Token: $refreshToken');
    if (jwtToken == null || refreshToken == null) {
      _showSnackBar(
          context, 'Session expired. Please log in again.', Colors.red);
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken, context);
      if (jwtToken == null) {
        _showSnackBar(
            context, 'Session expired. Please log in again.', Colors.red);
        return;
      }
    }

    final response = await _makeApiRequest(jwtToken, accountNumber, amount);

    if (response['status_code'] == 5) {
      jwtToken = await _refreshToken(refreshToken, context);
      if (jwtToken != null) {
        final retryResponse =
            await _makeApiRequest(jwtToken, accountNumber, amount);
        _handleApiResponse(context, retryResponse);
      } else {
        _showSnackBar(
            context, 'Session expired. Please log in again.', Colors.red);
      }
    } else {
      _handleApiResponse(context, response);
    }
  }

  Future<Map<String, dynamic>> _makeApiRequest(
      String jwtToken, String accountNumber, String amount) async {
    final url = Uri.parse(Config.billing);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'amount': amount,
        'service_id': billPaymentCode,
        'account': accountNumber,
        'app_ref_id': appRefId,
      }),
    );

    return jsonDecode(response.body);
  }

  void _handleApiResponse(
      BuildContext context, Map<String, dynamic> responseBody) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userType = prefs.getString('userType');
    print(userType);
    print(responseBody);
    final String snackbarMessage =
        '${responseBody["message"]} ID:${responseBody["d_id"]}';
    if (responseBody['status'] == 'Success') {
      _showSnackBar(context, snackbarMessage, Colors.green);
      GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
    } else {
      _showSnackBar(context, 'Transaction Failed', Colors.red);
    }
  }

  Future<String?> _refreshToken(
      String refreshToken, BuildContext context) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('jwt_token', responseBody['jwt_token']);
      return responseBody['jwt_token'];
    } else {
      return null;
    }
  }
}
