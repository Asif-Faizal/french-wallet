import 'package:ewallet2/presentation/bloc/change_card_pin/change_card_pin_bloc.dart';
import 'package:ewallet2/presentation/bloc/change_card_pin/change_card_pin_event.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/router/router_const.dart';
import '../../bloc/change_card_pin/change_card_pin_state.dart';

class ChangeCardPin extends StatefulWidget {
  const ChangeCardPin({Key? key}) : super(key: key);

  @override
  State<ChangeCardPin> createState() => _ChangeCardPinState();
}

class _ChangeCardPinState extends State<ChangeCardPin> {
  final _formKey = GlobalKey<FormState>();
  final _otpControllers = List<TextEditingController>.generate(
      4, (index) => TextEditingController());
  final _otpFocusNodes = List<FocusNode>.generate(4, (index) => FocusNode());
  final _newPinControllers = List<TextEditingController>.generate(
      4, (index) => TextEditingController());
  final _newPinFocusNodes = List<FocusNode>.generate(4, (index) => FocusNode());
  final _confirmPinControllers = List<TextEditingController>.generate(
      4, (index) => TextEditingController());
  final _confirmPinFocusNodes =
      List<FocusNode>.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    _otpControllers.forEach((controller) => controller.dispose());
    _otpFocusNodes.forEach((focusNode) => focusNode.dispose());
    _newPinControllers.forEach((controller) => controller.dispose());
    _newPinFocusNodes.forEach((focusNode) => focusNode.dispose());
    _confirmPinControllers.forEach((controller) => controller.dispose());
    _confirmPinFocusNodes.forEach((focusNode) => focusNode.dispose());
    super.dispose();
  }

  String _getPinFromControllers(List<TextEditingController> controllers) {
    return controllers.map((controller) => controller.text).join();
  }

  bool _validatePin(String newPin, String confirmPin) {
    if (newPin.length != 4 || confirmPin.length != 4) {
      return false;
    }
    if (newPin != confirmPin) {
      return false;
    }
    return true;
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final newPin = _getPinFromControllers(_newPinControllers);
      final confirmPin = _getPinFromControllers(_confirmPinControllers);

      if (_validatePin(newPin, confirmPin)) {
        _changePin(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.red,
              content: Text('PINs do not match or are invalid')),
        );
      }
    }
  }

  void _changePin(BuildContext context) {
    final pin =
        _confirmPinControllers.map((controller) => controller.text).join();
    final otp = _otpControllers.map((controller) => controller.text).join();
    context.read<ChangeCardPinBloc>().add(ChangePin(pin, otp));
  }

  Widget _buildPinInputSection(
    String label,
    List<TextEditingController> controllers,
    List<FocusNode> focusNodes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List<Widget>.generate(4, (index) {
            return SizedBox(
              width: 50,
              child: TextFormField(
                controller: controllers[index],
                focusNode: focusNodes[index],
                decoration: InputDecoration(
                    counterText: '', border: OutlineInputBorder()),
                maxLength: 1,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter digit';
                  }
                  return null;
                },
                onChanged: (value) {
                  if (value.isNotEmpty && index < 3) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  } else if (value.isEmpty && index > 0) {
                    FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                  }
                },
              ),
            );
          }),
        ),
      ],
    );
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
    return BlocListener<ChangeCardPinBloc, ChangeCardPinState>(
      listener: (context, state) {
        if (state is ChangeCardPinLoading) {
          print('Loading...');
          _showLoadingDialog(context);
        } else if (state is ChangeCardPinSuccess) {
          print('Success...');
          _showSnackBar(state.message, Colors.green);
          GoRouter.of(context).pushNamed(AppRouteConst.completedAnimationRoute);
          Navigator.of(context).pop();
        } else if (state is ChangeCardPinFailure) {
          print('Failed...');
          Navigator.of(context).pop();
          _showSnackBar(state.message, Colors.red);
        } else if (state is ChangeCardPinSessionExpired) {
          Navigator.of(context).pop();
          _showSnackBar('Session expired. Please login again.', Colors.red);
        }
      },
      child: Scaffold(
        appBar: NormalAppBar(text: ''),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _buildPinInputSection(
                    'Enter the OTP sent to your Registered Mobile Number',
                    _otpControllers,
                    _otpFocusNodes),
                SizedBox(height: 16),
                _buildPinInputSection(
                    'New PIN', _newPinControllers, _newPinFocusNodes),
                SizedBox(height: 16),
                _buildPinInputSection('Confirm New PIN', _confirmPinControllers,
                    _confirmPinFocusNodes),
                Spacer(),
                NormalButton(
                  size: MediaQuery.of(context).size,
                  title: 'Change',
                  onPressed: _submitForm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
