import 'package:ewallet2/shared/config/api_config.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';

class AddStoreScreen extends StatefulWidget {
  @override
  _AddStoreScreenState createState() => _AddStoreScreenState();
}

class _AddStoreScreenState extends State<AddStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  late SharedPreferences _prefs;

  FocusNode _focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _addStore() async {
    final token = _prefs.getString('jwt_token');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Authentication token not found')),
      );
      return;
    }

    final url = Uri.parse(Config.add_store);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'store_name': _nameController.text,
        'store_location': _locationController.text,
        'store_city': _cityController.text,
      }),
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200) {
      if (responseBody['status'] == 'Success') {
        GoRouter.of(context).pushNamed(AppRouteConst.merchantStoreRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Text(responseBody['message'])),
        );
        Navigator.of(context).pop();
      } else if (responseBody['status_code'] == 5) {
        await _refreshToken();
        await _addStore();
      } else {
        GoRouter.of(context).pushNamed(AppRouteConst.merchantStoreRoute);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text(responseBody['message'])),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Failed to add store')),
      );
    }
  }

  Future<void> _refreshToken() async {
    final refreshToken = _prefs.getString('refresh_token');
    if (refreshToken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Refresh token not found')),
      );
      return;
    }

    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    final responseBody = jsonDecode(response.body);

    if (response.statusCode == 200 && responseBody['status'] == 'Success') {
      await _prefs.setString('jwt_token', responseBody['jwt_token']);
      await _prefs.setString('refresh_token', responseBody['refresh_token']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text('Failed to refresh token')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'Add Store'),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 30),
              _buildTextField(controller: _nameController, label: 'Name'),
              SizedBox(height: 10),
              _buildTextField(
                controller: _locationController,
                label: 'Location',
              ),
              SizedBox(height: 10),
              _buildTextField(controller: _cityController, label: 'Type'),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 15, left: 20, right: 20),
        child: NormalButton(
          size: MediaQuery.of(context).size,
          title: 'Add',
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _addStore();
            }
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: TextFormField(
        controller: controller,
        decoration: _getInputDecoration(label, _focusNode),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  InputDecoration _getInputDecoration(String labelText, FocusNode focusNode) {
    return InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Colors.blue.shade300),
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
}
