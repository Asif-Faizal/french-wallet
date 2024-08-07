import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ChildUsersScreen extends StatefulWidget {
  @override
  _ChildUsersScreenState createState() => _ChildUsersScreenState();
}

class _ChildUsersScreenState extends State<ChildUsersScreen> {
  List<Map<String, dynamic>> _childUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildUsers();
  }

  Future<void> _fetchChildUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jwt_token = prefs.getString('jwt_token');
    final String apiUrl = Config.list_chil_users;

    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $jwt_token',
        },
      );
      print(response.body);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['data'] != null) {
          setState(() {
            _childUsers = List<Map<String, dynamic>>.from(responseData['data']
                .map((user) => {
                      'message': user['message'],
                      'mobile_no': user['mobile_no']
                    }));
            _isLoading = false;
          });
        } else {
          setState(() {
            _errorMessage = 'No child users found';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  itemCount: _childUsers.length,
                  itemBuilder: (context, index) {
                    final user = _childUsers[index];
                    return Card(
                      shadowColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                      elevation: 3,
                      child: ListTile(
                        title: Text(user['message'] ?? ''),
                        subtitle: Text(user['mobile_no'] ?? ''),
                      ),
                    );
                  },
                ),
    );
  }
}
