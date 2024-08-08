import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import '../../bloc/set_pin/set_pin_bloc.dart';
import '../../bloc/set_pin/set_pin_event.dart';
import '../../bloc/set_pin/set_pin_state.dart';

class SetTransactionPinScreen extends StatefulWidget {
  const SetTransactionPinScreen({Key? key}) : super(key: key);

  @override
  _SetTransactionPinScreenState createState() =>
      _SetTransactionPinScreenState();
}

class _SetTransactionPinScreenState extends State<SetTransactionPinScreen> {
  final List<TextEditingController> _pinControllers =
      List.generate(4, (index) => TextEditingController());
  final List<TextEditingController> _confirmPinControllers =
      List.generate(4, (index) => TextEditingController());

  final List<FocusNode> _pinFocusNodes =
      List.generate(4, (index) => FocusNode());
  final List<FocusNode> _confirmPinFocusNodes =
      List.generate(4, (index) => FocusNode());

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _checkPin() {
    String pin = _pinControllers.map((controller) => controller.text).join();
    String confirmPin =
        _confirmPinControllers.map((controller) => controller.text).join();
    if (pin.isEmpty || confirmPin.isEmpty) {
      _showSnackBar('Please enter both PINs.');
    } else if (pin != confirmPin) {
      _showSnackBar('PINs do not match.');
    } else {
      context
          .read<SetTransactionPinBloc>()
          .add(SubmitPinEvent(pin, confirmPin));
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return BlocProvider(
      create: (_) => SetTransactionPinBloc(),
      child: BlocListener<SetTransactionPinBloc, SetTransactionPinState>(
        listener: (context, state) {
          if (state is SetTransactionPinSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              content: Text(state.message),
            ));
            GoRouter.of(context)
                .pushNamed(AppRouteConst.completedAnimationRoute);
          } else if (state is SetTransactionPinFailure) {
            _showSnackBar(state.error);
          }
        },
        child: Scaffold(
          appBar: NormalAppBar(text: 'Set PIN'),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                const Text(
                  'Enter your 4-digit PIN:',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                _buildPinFields(_pinControllers, _pinFocusNodes),
                const SizedBox(height: 30),
                const Text(
                  'Confirm your 4-digit PIN:',
                  style: TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                _buildPinFields(_confirmPinControllers, _confirmPinFocusNodes),
                Spacer(),
                NormalButton(
                  onPressed: _checkPin,
                  title: 'Set PIN',
                  size: size,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPinFields(
      List<TextEditingController> controllers, List<FocusNode> focusNodes) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => _buildTextField(controllers[index], focusNodes, index),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, List<FocusNode> focusNodes, int index) {
    return SizedBox(
      width: 50,
      child: TextField(
        controller: controller,
        focusNode: focusNodes[index],
        textAlign: TextAlign.center,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < focusNodes.length - 1) {
              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
            }
          } else {
            if (index > 0) {
              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
            }
          }
        },
        decoration: _getInputDecoration(),
      ),
    );
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
      counterText: '',
      filled: true,
      fillColor: Colors.blue.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.blue.shade300, width: 0),
      ),
    );
  }
}
