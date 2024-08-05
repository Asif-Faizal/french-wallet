import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../shared/config/api_config.dart';
import '../../widgets/shared/card.dart';

class CardInfoScreen extends StatefulWidget {
  CardInfoScreen({
    super.key,
  });

  @override
  State<CardInfoScreen> createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen> {
  bool _isCardFrozen = false;
  bool _isAuthenticated = false;
  bool _isBalanceVisible = false;
  String? _cardId;
  final LocalAuthentication auth = LocalAuthentication();
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  final List<TextEditingController> _pinControllers =
      List.generate(4, (index) => TextEditingController());

  void _showSnackBar(String message, Color backgroundColor) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  Future<void> _auth() async {
    try {
      final bool canAuth = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (canAuth && isDeviceSupported) {
        final bool didAuth = await auth.authenticate(
          localizedReason: 'Please Authenticate to show Card Details',
          options: AuthenticationOptions(biometricOnly: true),
        );
        setState(() {
          _isAuthenticated = didAuth;
          if (_isAuthenticated) {
            _isBalanceVisible = true;
          }
        });
      } else {
        _showSnackBar('Biometric authentication is not available', Colors.red);
      }
    } catch (e) {
      print(e);
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      if (!_isBalanceVisible) {
        _isAuthenticated = false;
      }
    });
  }

  void _flipCard() {
    if (_flipCardKey.currentState != null) {
      _flipCardKey.currentState?.toggleCard();
    }
  }

  void _toggleCardFreeze(bool value) {
    setState(() {
      _isCardFrozen = value;
    });
    _showSnackBar(
      _isCardFrozen ? 'Card is frozen' : 'Card is unfrozen',
      Colors.blue,
    );
  }

  void _showChangePinBottomSheet() {
    print(_cardId);
    showModalBottomSheet(
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      context: context,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 10),
              Text(
                'Enter Current PIN',
                style: TextStyle(color: Colors.black, fontSize: 26),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 50,
                    child: TextField(
                      controller: _pinControllers[index],
                      obscureText: true,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  );
                }),
              ),
              SizedBox(height: 20),
              NormalButton(
                  size: MediaQuery.of(context).size,
                  title: 'Verify',
                  onPressed: _verifyPin),
              SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Future<void> _verifyPin() async {
    final String cardPin =
        _pinControllers.map((controller) => controller.text).join();
    if (cardPin.length != 4) {
      _showSnackBar('Please enter a valid 4-digit PIN', Colors.red);
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final cardUid = prefs.getString('cardId');
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (cardUid == null) {
      _showSnackBar('Card ID not found', Colors.red);
      return;
    }

    if (jwtToken == null || refreshToken == null) {
      _showSnackBar('Session expired. Please log in again.', Colors.red);
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        _showSnackBar('Session expired. Please log in again.', Colors.red);
        return;
      }
    }

    final url = Uri.parse(Config.verify_card_pin);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
      body: jsonEncode({
        'card_uid': cardUid,
        'card_pin': cardPin,
      }),
    );

    final responseData = jsonDecode(response.body);
    final status = responseData["status"];
    final message = responseData["message"];
    final status_code = responseData['status_code'];

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      if (status == 'Success') {
        _showSnackBar(message, Colors.green);
      } else if (status == 'Fail' && status_code == 5) {
        jwtToken = await _refreshToken(refreshToken);
        if (jwtToken != null) {
          // Retry the PIN verification request with the new token
          final retryResponse = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Deviceid': Config.deviceId,
              'Authorization': 'Bearer $jwtToken'
            },
            body: jsonEncode({
              'card_uid': cardUid,
              'card_pin': cardPin,
            }),
          );

          final retryResponseData = jsonDecode(retryResponse.body);
          final retryStatus = retryResponseData["status"];
          final retryMessage = retryResponseData["message"];

          if (retryResponse.statusCode == 200) {
            if (retryStatus == 'Success') {
              _showSnackBar(retryMessage, Colors.green);
            } else {
              _showSnackBar(retryMessage, Colors.red);
            }
          } else {
            _showSnackBar('Failed to verify PIN', Colors.red);
          }
        } else {
          _showSnackBar('Session expired. Please log in again.', Colors.red);
        }
      } else {
        _showSnackBar(message, Colors.red);
      }
    } else {
      print('Error: ${response.body}');
      _showSnackBar('Failed to verify PIN', Colors.red);
    }

    Navigator.pop(context);
  }

  Future<String?> _refreshToken(String refreshToken) async {
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
      final jwtToken = responseBody['jwt_token'];
      final newRefreshToken = responseBody['refresh_token'];
      if (jwtToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', jwtToken);
        prefs.setString('refresh_token', newRefreshToken);
        return jwtToken;
      } else {
        throw Exception('Session TimedOut please Login again');
      }
    }
    return null;
  }

  @override
  void initState() {
    _getCardId();
    super.initState();
  }

  void _getCardId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _cardId = prefs.getString('cardId');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              WalletCard(
                isAuthenticated: _isAuthenticated,
                isBalanceVisible: _isBalanceVisible,
                flipCardKey: _flipCardKey,
              ),
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: _showChangePinBottomSheet,
                      child: Text(
                        'Change PIN',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                            color: Colors.blue.shade800,
                            onPressed: _flipCard,
                            icon: Icon(Icons.flip)),
                        IconButton(
                            color: Colors.blue.shade800,
                            onPressed: () {
                              if (_isBalanceVisible) {
                                _toggleBalanceVisibility();
                              } else {
                                _auth();
                              }
                            },
                            icon: Icon(
                              _isBalanceVisible
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: Colors.blue.shade100,
              ),
              SizedBox(
                height: 20,
              ),
              SizedBox(
                height: 30,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _isCardFrozen ? 'Card is Active' : 'Card is Frozen',
                      style: TextStyle(color: Colors.black, fontSize: 20),
                    ),
                    Switch(
                      value: _isCardFrozen,
                      onChanged: _toggleCardFreeze,
                      trackOutlineWidth: WidgetStatePropertyAll(0),
                      activeColor: Colors.green,
                      activeTrackColor: Colors.green.shade200,
                      inactiveThumbColor: Colors.red,
                      inactiveTrackColor: Colors.red.shade200,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextButton(
            onPressed: () {},
            child: Text(
              'Report Card Stolen / Lost',
              style: TextStyle(
                  color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
            )),
      ),
    );
  }
}
