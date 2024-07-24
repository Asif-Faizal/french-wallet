import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    const String bearerToken =
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJVZGlkIjoiOTg2dDUzNDY2NjU4NzY0NTM0MjM0NTI0MzI3MzQ4NTM0NTMzMTM0MzU3Njg5NTMyMyIsIkN1c3RvbWVySUQiOiIyNjEiLCJleHAiOjE3MjE3MzMwMTksImlzcyI6IkFaZVdhbGxldCJ9.RefqkNJyGkRpLGHWejowJfQvZtG_vy0M4x1eznid2h0';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Deviceid': deviceId,
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          qrCodeUrl = responseData['qr_code'];
          isLoading = false;
        });
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

  void _confirmTransaction() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Transaction'),
          content: Text('Do you want to proceed with this transaction?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Proceed with the transaction logic
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: 'QR Code Payment'),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator()
            : qrCodeUrl != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Scan the QR code for payment',
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
