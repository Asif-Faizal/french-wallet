import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeScreen extends StatefulWidget {
  @override
  _QRCodeScreenState createState() => _QRCodeScreenState();
}

class _QRCodeScreenState extends State<QRCodeScreen> {
  String? qrCodeUrl;
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchQRCode();
  }

  Future<void> _fetchQRCode() async {
    const String url = Config.get_user_qr;
    const String deviceId = Config.deviceId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? bearerToken = prefs.getString('jwt_token');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Deviceid': deviceId,
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response body');
        }

        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'Fail' &&
            responseData['status_code'] == 5) {
          // Token expired, refresh token
          await _refreshToken();
          // Retry fetching the QR code
          await _fetchQRCode();
        } else {
          setState(() {
            qrCodeUrl = responseData['qr_code'];
            isLoading = false;
          });
        }
      } else {
        throw Exception('Failed to load QR code');
      }
    } catch (error) {
      print('Error fetching QR code: $error');
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshToken() async {
    const String refreshUrl = Config.refresh_token;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? refreshToken = prefs.getString('refresh_token');

    try {
      final response = await http.post(
        Uri.parse(refreshUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'refresh_token': refreshToken,
        }),
      );

      print('Refresh token response status: ${response.statusCode}');
      print('Refresh token response body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty refresh token response body');
        }

        final Map<String, dynamic> responseData = json.decode(response.body);
        final String newAccessToken = responseData['jwt_token'];
        final String newRefreshToken = responseData['refresh_token'];

        await prefs.setString('jwt_token', newAccessToken);
        await prefs.setString('refresh_token', newRefreshToken);
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (error) {
      print('Error refreshing token: $error');
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : qrCodeUrl != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scan the QR code to Pay',
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 20),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Image.network(
                            qrCodeUrl!,
                            loadingBuilder: (context, child, progress) {
                              return progress == null
                                  ? child
                                  : CircularProgressIndicator();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Text(errorMessage.isNotEmpty
                    ? errorMessage
                    : 'Failed to load QR code'),
      ),
    );
  }
}
