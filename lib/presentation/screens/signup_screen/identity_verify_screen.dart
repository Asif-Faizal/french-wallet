import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/router/router_const.dart';
import '../../widgets/shared/normal_appbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IdentityVerifyScreen extends StatefulWidget {
  const IdentityVerifyScreen({super.key});

  @override
  _IdentityVerifyScreenState createState() => _IdentityVerifyScreenState();
}

class _IdentityVerifyScreenState extends State<IdentityVerifyScreen> {
  final TextEditingController _idController = TextEditingController();
  final ValueNotifier<bool> _isButtonEnabled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _idController.addListener(_validateInput);
  }

  @override
  void dispose() {
    _idController.removeListener(_validateInput);
    _idController.dispose();
    _isButtonEnabled.dispose();
    super.dispose();
  }

  void _validateInput() {
    _isButtonEnabled.value = _idController.text.length == 12;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: NormalAppBar(text: ''),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height / 60),
              Text(
                'Identity Verification',
                style: theme.textTheme.displayLarge,
              ),
              SizedBox(height: size.height / 20),
              Text(
                'For registration we will verify your IDENTITYTYPE so kindly enter the required details and please approve the verification through the AADHAR',
                style: theme.textTheme.bodyLarge,
              ),
              SizedBox(height: size.height / 40),
              TextField(
                controller: _idController,
                maxLength: 12,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ID Number',
                  counterText: '',
                ),
              ),
              Spacer(),
              Text(
                'Your Identity Type is secure and will be transmitted through 128bit encryption.',
                style: theme.textTheme.bodySmall,
              ),
              SizedBox(height: size.height / 40),
              Center(
                child: ValueListenableBuilder<bool>(
                  valueListenable: _isButtonEnabled,
                  builder: (context, isEnabled, child) {
                    return NormalButton(
                      onPressed: isEnabled
                          ? () {
                              GoRouter.of(context)
                                  .pushNamed(AppRouteConst.uploadIdScreenRoute);
                            }
                          : null,
                      title: AppLocalizations.of(context)!.continue_text,
                      size: size,
                    );
                  },
                ),
              ),
              SizedBox(height: size.height / 40),
            ],
          ),
        ),
      ),
    );
  }
}
