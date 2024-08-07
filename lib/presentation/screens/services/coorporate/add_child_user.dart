import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../../../shared/country_code.dart';

class CreateChildUserScreen extends StatefulWidget {
  @override
  _CreateChildUserScreenState createState() => _CreateChildUserScreenState();
}

class _CreateChildUserScreenState extends State<CreateChildUserScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  FocusNode _nameFocusNode = FocusNode();
  FocusNode _numberFocusNode = FocusNode();
  final List<Map<String, String>> _countryCodes = CountryCode.countryCodes;
  String _selectedCountryDialCode = '+91';

  Future<void> _createChildUser() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jwt_token = prefs.getString('jwt_token');
    final String apiUrl = Config.add_user_child;
    final number = _selectedCountryDialCode + _numberController.text;
    print(number);
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $jwt_token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'user_name': _nameController.text,
          'mobile_no': number,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData["status"] == 'success') {
          GoRouter.of(context).pushNamed(AppRouteConst.viewChildCardRoute);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(responseData["message"]),
          ));
        }
        setState(() {
          _successMessage = responseData['message'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to create user';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showCountryCodePicker() async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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

  InputDecoration _getInputDecoration(String labelText, FocusNode focusNode) {
    return InputDecoration(
        hintText: labelText,
        hintStyle: TextStyle(color: Colors.blue.shade300),
        filled: true,
        fillColor: Colors.blue.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
        ),
        enabledBorder: focusNode.hasFocus
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue.shade300, width: 0),
              ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Enter details to create a\nChild User',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: _getInputDecoration('Name', _nameFocusNode),
              onTap: () {
                setState(() {});
              },
              onEditingComplete: () {
                setState(() {});
              },
            ),
            SizedBox(height: 15),
            Row(
              children: [
                GestureDetector(
                  onTap: _showCountryCodePicker,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      _selectedCountryDialCode,
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: TextField(
                    controller: _numberController,
                    focusNode: _numberFocusNode,
                    decoration:
                        _getInputDecoration('Mobile Number', _numberFocusNode),
                    keyboardType: TextInputType.phone,
                    onTap: () {
                      setState(() {});
                    },
                    onEditingComplete: () {
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Spacer(),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : NormalButton(
                    size: MediaQuery.of(context).size,
                    title: 'Create Child User',
                    onPressed: () {
                      _createChildUser();
                    })
          ],
        ),
      ),
    );
  }
}
