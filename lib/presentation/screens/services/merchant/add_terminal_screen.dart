import 'dart:convert';

import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/router/router_const.dart';

class AddTerminalScreen extends StatefulWidget {
  final int storeId;

  AddTerminalScreen({required this.storeId});

  @override
  _AddTerminalScreenState createState() => _AddTerminalScreenState();
}

class _AddTerminalScreenState extends State<AddTerminalScreen> {
  final _formKey = GlobalKey<FormState>();
  final _locationController = TextEditingController();
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _modelController = TextEditingController();
  final _idController = TextEditingController();
  final _serialController = TextEditingController();
  late SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _initSharedPreferences();
  }

  Future<void> _initSharedPreferences() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _addTerminal() async {
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

    final url =
        Uri.parse('https://api-innovitegra.online/merchant/terminal/Add');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "termainal_loc": _locationController.text,
        "terminal_name": _nameController.text,
        "terminal_type": _typeController.text,
        "terminal_model": _modelController.text,
        "terminal_id": _idController.text,
        "terminal_serial": _serialController.text,
        "store_id": widget.storeId
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
        await _addTerminal();
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

    final url = Uri.parse('https://api-innovitegra.online/login/refresh_token');
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
      appBar: NormalAppBar(text: 'Add Terminal'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Store ID: ${widget.storeId}',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 16),
                _buildTextField(
                    controller: _locationController, label: 'Location'),
                _buildTextField(controller: _nameController, label: 'Name'),
                _buildTextField(controller: _typeController, label: 'Type'),
                _buildTextField(controller: _modelController, label: 'Model'),
                _buildTextField(controller: _idController, label: 'ID'),
                _buildTextField(controller: _serialController, label: 'Serial'),
                SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(15),
        child: NormalButton(
          size: MediaQuery.of(context).size,
          title: 'Add',
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _addTerminal();
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
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
