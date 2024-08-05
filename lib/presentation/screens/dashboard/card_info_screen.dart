import 'package:ewallet2/presentation/bloc/sent_card_otp/sent_card_otp_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flip_card/flip_card.dart';
import 'package:local_auth/local_auth.dart';
import '../../bloc/sent_card_otp/sent_card_otp_bloc.dart';
import '../../bloc/sent_card_otp/sent_card_otp_event.dart';
import '../../bloc/verify_card_pin/verify_card_pin_bloc.dart';
import '../../bloc/verify_card_pin/verify_card_pin_event.dart';
import '../../bloc/verify_card_pin/verify_card_pin_state.dart';
import '../../widgets/shared/card.dart';

class CardInfoScreen extends StatefulWidget {
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
                    height: 68,
                    width: 64,
                    child: TextField(
                      textAlign: TextAlign.center,
                      controller: _pinControllers[index],
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
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: NormalButton(
                  size: MediaQuery.of(context).size,
                  title: 'Verify',
                  onPressed: () => _verifyPin(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _verifyPin(BuildContext context) {
    final pin = _pinControllers.map((controller) => controller.text).join();
    context.read<VerifyCardPinBloc>().add(VerifyPin(pin));
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text("Verifying..."),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<VerifyCardPinBloc, PinVerificationState>(
        listener: (context, state) {
          if (state is PinVerificationLoading) {
            _showLoadingDialog(context);
          } else if (state is PinVerificationSuccess) {
            _showSnackBar(state.message, Colors.green);
            Navigator.of(context).pop();
            context.read<SentCardOtpBloc>().add(SentCardOtp());
            //open another bottom sheet to change pin
            if (state is SentCardOtpLoading) {
              _showLoadingDialog(context);
            } else if (state is SentCardOtpSuccess) {
              _showSnackBar(state.message, Colors.green);
              Navigator.of(context).pop();
            } else if (state is SentCardOtpFailure) {
              Navigator.of(context).pop();
              _showSnackBar(state.message, Colors.red);
            } else if (state is SentCardOtpSessionExpired) {
              Navigator.of(context).pop();
              _showSnackBar('Session expired. Please login again.', Colors.red);
            }
          } else if (state is PinVerificationFailure) {
            Navigator.of(context).pop();
            _showSnackBar(state.message, Colors.red);
          } else if (state is PinVerificationSessionExpired) {
            Navigator.of(context).pop();
            _showSnackBar('Session expired. Please login again.', Colors.red);
          }
        },
        child: Scaffold(
          appBar: NormalAppBar(
            text: '',
          ),
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
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
          ),
        ));
  }
}
