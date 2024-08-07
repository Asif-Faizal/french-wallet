import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';

class MailOtpSheet extends StatefulWidget {
  const MailOtpSheet({
    Key? key,
    required this.number,
    required this.userType,
    required this.size,
    required this.navigateTo,
  }) : super(key: key);

  final String number;
  final String userType;
  final Size size;
  final String navigateTo;

  @override
  _MailOtpSheetState createState() => _MailOtpSheetState();
}

class _MailOtpSheetState extends State<MailOtpSheet> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (index) => TextEditingController());
    _focusNodes = List.generate(4, (index) => FocusNode());
  }

  @override
  void dispose() {
    for (int i = 0; i < 4; i++) {
      _controllers[i].dispose();
      _focusNodes[i].dispose();
    }
    super.dispose();
  }

  InputDecoration _getInputDecoration() {
    return InputDecoration(
        counterText: '',
        labelStyle: TextStyle(color: Colors.blue.shade300),
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
        ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${AppLocalizations.of(context)!.otp_sent} ${widget.number}',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: widget.size.height / 30),
            Text(
              AppLocalizations.of(context)!.enter_otp,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            SizedBox(height: widget.size.height / 80),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(4, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: _getInputDecoration(),
                    onChanged: (value) {
                      if (value.length == 1 && index < 3) {
                        _focusNodes[index].unfocus();
                        FocusScope.of(context)
                            .requestFocus(_focusNodes[index + 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: widget.size.height / 40),
            NormalButton(
              size: widget.size,
              title: AppLocalizations.of(context)!.verify_otp,
              onPressed: () {
                // String otp =
                //     _controllers.map((controller) => controller.text).join();
                GoRouter.of(context).pushNamed(widget.navigateTo);
              },
            ),
            SizedBox(height: widget.size.height / 20),
          ],
        ),
      ),
    );
  }

  // Future<void> verifyOtpMobile(String mobile, String otp) async {
  //   final Map<String, String> headers = {
  //     'X-Password': Config.password,
  //     'X-Username': Config.username,
  //     'Appversion': Config.appVersion,
  //     'Content-Type': 'application/json',
  //     'Deviceid': Config.deviceId,
  //   };

  //   final Map<String, String> body = {'mobile': mobile, 'otp': otp};

  //   try {
  //     final response = await http.post(
  //       Uri.parse(Config.verify_mobile_otp_url),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200) {
  //       final responseData = jsonDecode(response.body);
  //       final status = responseData["status"];
  //       final message = responseData["message"];

  //       if (kDebugMode) {
  //         print('Response body: $responseData');
  //       }

  //       if (status == 'Success') {
  //         GoRouter.of(context).pushNamed(widget.navigateTo);
  //       } else {
  //         Navigator.pop(context);
  //         ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //           content: Text(message),
  //           behavior: SnackBarBehavior.floating,
  //           backgroundColor: Colors.red,
  //         ));
  //       }
  //     } else {
  //       if (kDebugMode) {
  //         print('Failed with status code: ${response.statusCode}');
  //         print('Response body: ${response.body}');
  //       }
  //       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
  //         content: Text('Error fetching data'),
  //         behavior: SnackBarBehavior.floating,
  //         backgroundColor: Colors.red,
  //       ));
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       content: Text(e.toString()),
  //       behavior: SnackBarBehavior.floating,
  //       backgroundColor: Colors.red,
  //     ));
  //   }
  // }
}
