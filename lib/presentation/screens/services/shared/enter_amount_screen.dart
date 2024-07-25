import 'package:ewallet2/shared/config/api_config.dart';
import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EnterAmountPage extends StatefulWidget {
  const EnterAmountPage({super.key, required this.phoneNumber});
  final String phoneNumber;

  @override
  _EnterAmountPageState createState() => _EnterAmountPageState();
}

class _EnterAmountPageState extends State<EnterAmountPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isButtonEnabled = false;
  String? _selectedItems;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _amountController.addListener(_validateAmount);
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedItems = prefs.getString('selected_value');
    });
  }

  @override
  void dispose() {
    _amountController.removeListener(_validateAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _validateAmount() {
    setState(() {
      _isButtonEnabled = _amountController.text.isNotEmpty;
    });
  }

  String _getButtonTitle() {
    if (_selectedItems == 'Send') {
      return 'Pay';
    } else if (_selectedItems == 'Receive') {
      return 'Request';
    } else {
      return 'Proceed';
    }
  }

  Future<void> _makeSendRequest(String pin) async {
    final url = Config.sent_money;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': Config.token,
    };

    final body = jsonEncode({
      'mobile': widget.phoneNumber,
      'currency': 'KWD',
      'amount': double.tryParse(_amountController.text) ?? 0.0,
      'user_pin': pin,
      'remark': 'Test transaction',
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      print(body);
      print(
          '==================================SENDING MONEY==============================');
      print(responseData);
      final remark = responseData['remark'];
      final status = responseData['status'];
      print('Status: $status');

      if (response.statusCode == 200) {
        if (status == 'Fail') {
          GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(remark),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (status == 'Success') {
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
        } else {}
      } else {
        GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request failed: ${response.statusCode}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  Future<void> _makeReceiveRequest(String pin) async {
    final url = Config.add_request;
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': Config.token,
    };

    final body = jsonEncode({
      "mobile_no": widget.phoneNumber,
      "currency": "KWD",
      "amount": double.tryParse(_amountController.text) ?? 0.0,
      "user_pin": pin
    });

    try {
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);
      final responseData = jsonDecode(response.body);
      print(body);
      print(
          '==================================REQUESTING MONEY==============================');
      print(responseData);
      final remark = responseData['remark'];
      final status = responseData['status'];
      print('Status: $status');

      if (response.statusCode == 200) {
        if (status == 'Fail') {
          GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(remark),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ));
        } else if (status == 'Success') {
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(remark),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ));
        }
      } else {
        GoRouter.of(context).pushNamed(AppRouteConst.errorAnimationRoute);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Request failed: ${response.statusCode}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _handleSubmit() {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      isScrollControlled: true,
      builder: (BuildContext context) {
        return TransactionPinBottomSheet(
          onPinEntered: (String pin) {
            if (_selectedItems == 'Send') {
              _makeSendRequest(pin);
            } else if (_selectedItems == 'Receive') {
              _makeReceiveRequest(pin);
            }
          },
          buttonTitle: _getButtonTitle(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: widget.phoneNumber),
      body: Padding(
        padding: EdgeInsets.all(size.width / 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: size.height / 10),
            Text(
              'Enter the Amount',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            SizedBox(height: size.height / 20),
            TextField(
              textAlign: TextAlign.center,
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(fontSize: 32),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefix: Icon(Icons.attach_money),
                contentPadding: EdgeInsets.symmetric(
                  vertical: size.height / 60,
                  horizontal: size.width / 40,
                ),
              ),
            ),
            Spacer(),
            NormalButton(
              size: size,
              title: _getButtonTitle(),
              onPressed: _isButtonEnabled ? _handleSubmit : null,
            ),
            SizedBox(height: size.height / 80),
          ],
        ),
      ),
    );
  }
}

class TransactionPinBottomSheet extends StatefulWidget {
  final Function(String) onPinEntered;
  final String buttonTitle;

  TransactionPinBottomSheet(
      {required this.onPinEntered, required this.buttonTitle});

  @override
  _TransactionPinBottomSheetState createState() =>
      _TransactionPinBottomSheetState();
}

class _TransactionPinBottomSheetState extends State<TransactionPinBottomSheet> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String _enteredPin = '';
  bool _isButtonEnabled = false;
  String? _selectedItems;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNodes[0]);
    });
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedItems = prefs.getString('selected_value');
      print(
          '@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@$_selectedItems@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@');
    });
  }

  void _handlePinInput() {
    _enteredPin = _pinControllers.map((controller) => controller.text).join();
    setState(() {
      _isButtonEnabled = _enteredPin.length == 4;
    });
  }

  @override
  void dispose() {
    _pinControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SingleChildScrollView(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Enter Transaction PIN',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: size.height / 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return Container(
                  width: size.width / 10,
                  height: size.height / 10,
                  child: TextField(
                    controller: _pinControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    maxLength: 1,
                    obscureText: true,
                    style: TextStyle(fontSize: 24),
                    onChanged: (value) {
                      if (value.isNotEmpty) {
                        if (index < 3) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index + 1]);
                        }
                      } else if (value.isEmpty) {
                        if (index > 0) {
                          FocusScope.of(context)
                              .requestFocus(_focusNodes[index - 1]);
                        }
                      }
                      _handlePinInput();
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: size.height / 15),
            NormalButton(
              size: MediaQuery.of(context).size,
              title: widget.buttonTitle,
              onPressed: _isButtonEnabled
                  ? () {
                      widget.onPinEntered(_enteredPin);
                      Navigator.of(context).pop();
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
