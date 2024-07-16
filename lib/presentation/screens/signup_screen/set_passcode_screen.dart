import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SetPasscodeScreen extends StatefulWidget {
  const SetPasscodeScreen({Key? key}) : super(key: key);

  @override
  _SetPasscodeScreenState createState() => _SetPasscodeScreenState();
}

class _SetPasscodeScreenState extends State<SetPasscodeScreen> {
  final List<TextEditingController> _passcodeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<TextEditingController> _confirmPasscodeControllers =
      List.generate(6, (index) => TextEditingController());

  final List<FocusNode> _passcodeFocusNodes =
      List.generate(6, (index) => FocusNode());
  final List<FocusNode> _confirmPasscodeFocusNodes =
      List.generate(6, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _passcodeControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPasscodeControllers) {
      controller.dispose();
    }
    for (var node in _passcodeFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPasscodeFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _setPasscode() {
    String passcode =
        _passcodeControllers.map((controller) => controller.text).join();
    String confirmPasscode =
        _confirmPasscodeControllers.map((controller) => controller.text).join();

    if (passcode.isEmpty || confirmPasscode.isEmpty) {
      _showSnackBar('Please enter both passcodes.');
    } else if (passcode != confirmPasscode) {
      _showSnackBar('Passcodes do not match.');
    } else {
      // Handle the passcode setting logic
      _showSnackBar('Passcode set successfully.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildPasscodeFields(List<TextEditingController> controllers,
      List<FocusNode> focusNodes, double fieldHeight) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            width: 40,
            height: fieldHeight,
            child: TextField(
              obscureText: true,
              obscuringCharacter: '*',
              controller: controllers[index],
              focusNode: focusNodes[index],
              keyboardType: TextInputType.number,
              textInputAction:
                  index == 5 ? TextInputAction.done : TextInputAction.next,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
              maxLength: 1,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                if (value.isNotEmpty && index < 5) {
                  FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                } else if (value.isNotEmpty && index == 5) {
                  FocusScope.of(context)
                      .requestFocus(_confirmPasscodeFocusNodes[0]);
                }
                if (value.isEmpty && index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                }
              },
              decoration: InputDecoration(
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: size.height / 60),
            Text(
              'Set a PIN for accessing your eWallet securely',
              style: theme.textTheme.headlineMedium,
            ),
            SizedBox(height: size.height / 20),
            Text('Enter Passcode', style: theme.textTheme.bodyMedium),
            SizedBox(height: size.height / 40),
            _buildPasscodeFields(
                _passcodeControllers, _passcodeFocusNodes, size.height / 16),
            SizedBox(height: size.height / 20),
            Text('Confirm Passcode', style: theme.textTheme.bodyMedium),
            SizedBox(height: size.height / 40),
            _buildPasscodeFields(_confirmPasscodeControllers,
                _confirmPasscodeFocusNodes, size.height / 16),
            SizedBox(height: size.height / 20),
            const Spacer(),
            NormalButton(
                size: size, title: 'Set Passcode', onPressed: _setPasscode),
          ],
        ),
      ),
    );
  }
}
