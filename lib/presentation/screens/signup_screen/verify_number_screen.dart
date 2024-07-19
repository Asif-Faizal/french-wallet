import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/shared/normal_appbar.dart';

class VerifyNumber extends StatelessWidget {
  const VerifyNumber({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const NormalAppBar(
        text: '',
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height / 60),
              Center(
                child: Icon(
                  Icons.message,
                  size: 48,
                  color: theme.colorScheme.primary,
                ),
              ),
              SizedBox(height: size.height / 60),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.verify_number_heading,
                  style: theme.textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: size.height / 3.1),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.sms_charges,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
              ),
              Center(
                child: Text(
                  AppLocalizations.of(context)!.thanks_for_using,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.start,
                ),
              ),
              const Spacer(),
              Text(
                AppLocalizations.of(context)!.click_to_verify,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: size.height / 80,
              ),
              Center(
                child: NormalButton(
                  size: size,
                  title: AppLocalizations.of(context)!.continue_text,
                  onPressed: () {
                    GoRouter.of(context)
                        .pushNamed(AppRouteConst.sentOtpSignInRoute);
                  },
                ),
              ),
              SizedBox(height: size.height * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}
