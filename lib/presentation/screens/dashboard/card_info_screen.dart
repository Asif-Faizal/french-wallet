import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../../widgets/shared/card.dart';

class CardInfoScreen extends StatefulWidget {
  final bool isAuthenticated;
  final bool isBalanceVisible;
  final GlobalKey<FlipCardState> flipCardKey;
  CardInfoScreen(
      {super.key,
      required this.isAuthenticated,
      required this.isBalanceVisible,
      required this.flipCardKey});

  @override
  State<CardInfoScreen> createState() => _CardInfoScreenState();
}

class _CardInfoScreenState extends State<CardInfoScreen> {
  bool _isAuthenticated = false;

  bool _isBalanceVisible = false;

  final LocalAuthentication auth = LocalAuthentication();

  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();

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
            _isBalanceVisible = true; // Show balance when authenticated
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
        // Reset authentication when hiding balance
        _isAuthenticated = false;
      }
    });
  }

  void _flipCard() {
    if (_flipCardKey.currentState != null) {
      _flipCardKey.currentState?.toggleCard();
    }
  }

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
                isAuthenticated: widget.isAuthenticated,
                isBalanceVisible: widget.isBalanceVisible,
                flipCardKey: widget.flipCardKey,
              ),
              SizedBox(
                height: 10,
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
                        if (widget.isBalanceVisible) {
                          _toggleBalanceVisibility();
                        } else {
                          _auth();
                        }
                      },
                      icon: Icon(
                        widget.isBalanceVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ))
                ],
              ),
              SizedBox(
                height: 10,
              ),
              Divider(
                thickness: 1,
                color: Colors.blue.shade100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
