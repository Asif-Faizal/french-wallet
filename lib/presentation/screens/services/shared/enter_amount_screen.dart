import 'package:flutter/material.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnterAmountPage extends StatefulWidget {
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
      return 'Proceed';
    } else if (_selectedItems == 'Receive') {
      return 'Request';
    } else {
      return 'Proceed';
    }
  }

  void _handleSubmit() {
    if (_selectedItems == 'Send') {
      showModalBottomSheet(
        context: context,
        isDismissible: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
        ),
        isScrollControlled: true,
        builder: (BuildContext context) {
          return TransactionPinBottomSheet(onPinEntered: (String pin) {
            // Handle the entered PIN here
            print("Entered PIN: $pin");
          });
        },
      );
    } else if (_selectedItems == 'Receive') {
      GoRouter.of(context).pushNamed(AppRouteConst.coorporateHomeRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: NormalAppBar(text: ''),
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
                  vertical: size.height / 30,
                  horizontal: size.width / 20,
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

  TransactionPinBottomSheet({required this.onPinEntered});

  @override
  _TransactionPinBottomSheetState createState() =>
      _TransactionPinBottomSheetState();
}

class _TransactionPinBottomSheetState extends State<TransactionPinBottomSheet> {
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
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
    });
  }

  void _handlePinInput() {
    _enteredPin = _pinControllers.map((controller) => controller.text).join();
    setState(() {
      _isButtonEnabled = _enteredPin.length == 6;
    });
    print(
        '###########################${_selectedItems ?? "No selected items"}##########################');
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
              children: List.generate(6, (index) {
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
                      if (value.isNotEmpty && index < 5) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      } else if (value.isEmpty && index > 0) {
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index - 1]);
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
              title: 'Pay',
              onPressed: _isButtonEnabled
                  ? () {
                      widget.onPinEntered(_enteredPin);
                      Navigator.of(context).pop();
                      GoRouter.of(context)
                          .pushNamed(AppRouteConst.completedAnimationRoute);
                    }
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
