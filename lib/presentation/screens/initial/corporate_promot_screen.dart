import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../widgets/prompt/circlecorporate_selector.dart';
import '../../widgets/shared/normal_appbar.dart';
import '../../widgets/shared/normal_button.dart';

class CorporatePromptScreen extends StatefulWidget {
  const CorporatePromptScreen({super.key});

  @override
  State<CorporatePromptScreen> createState() => _CorporatePromptScreenState();
}

class _CorporatePromptScreenState extends State<CorporatePromptScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? selectedCorporate;

  Future<void> _storeData() async {
    if (selectedCorporate != null) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('corporateType', selectedCorporate!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: NormalAppBar(
        text: AppLocalizations.of(context)!.corporate,
      ),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height / 30, horizontal: size.width / 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wallet_membership_rounded,
                    size: size.height / 10,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SizedBox(width: size.width / 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INNOVITEGRA',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                      Text(
                        'WALLET',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height / 10),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.select_type_of_user_heading,
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            color: Theme.of(context).colorScheme.onBackground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: size.height / 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleCorporateSelector(
                    userType: 'business-owner',
                    selectedUserType: selectedCorporate,
                    onSelect: (userType) {
                      setState(() {
                        selectedCorporate = userType;
                      });
                    },
                  ),
                  CircleCorporateSelector(
                    userType: 'executive-officer',
                    selectedUserType: selectedCorporate,
                    onSelect: (userType) {
                      setState(() {
                        selectedCorporate = userType;
                      });
                    },
                  ),
                  CircleCorporateSelector(
                    userType: 'employee',
                    selectedUserType: selectedCorporate,
                    onSelect: (userType) {
                      setState(() {
                        selectedCorporate = userType;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: size.height / 5),
              NormalButton(
                size: size,
                title: AppLocalizations.of(context)!.proceed,
                onPressed: selectedCorporate != null
                    ? () async {
                        print(selectedCorporate);
                        _storeData();
                        GoRouter.of(context)
                            .pushNamed(AppRouteConst.loginOrSignUpRoute);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
