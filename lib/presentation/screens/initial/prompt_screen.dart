import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/l10n.dart';
import '../../bloc/language/localization_bloc.dart';
import '../../widgets/prompt/cirlcleavatar_selector.dart';
import '../../widgets/shared/normal_button.dart';
import 'package:go_router/go_router.dart';

class PromptScreen extends StatefulWidget {
  const PromptScreen({super.key});

  @override
  _PromptScreenState createState() => _PromptScreenState();
}

class _PromptScreenState extends State<PromptScreen> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String? selectedUserType;

  Future<void> _storeData() async {
    if (selectedUserType != null) {
      final SharedPreferences prefs = await _prefs;
      prefs.setString('userType', selectedUserType!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          Text(
            AppLocalizations.of(context)!.select_language,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Theme.of(context).colorScheme.onBackground,
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(width: size.width / 40),
          DropdownButton<Locale>(
            elevation: 10,
            dropdownColor: Theme.of(context).colorScheme.surface,
            underline: Container(),
            value: context.read<LocalizationBloc>().state.locale,
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.read<LocalizationBloc>().add(
                      LocalizationChanged(newLocale),
                    );
              }
            },
            items: L10n.all.map((locale) {
              final languageCode = locale.languageCode;
              return DropdownMenuItem(
                value: locale,
                child: Text(
                  languageCode == 'en'
                      ? 'English'
                      : languageCode == 'ar'
                          ? 'Arabic'
                          : 'French',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              );
            }).toList(),
          ),
          SizedBox(width: size.width / 20),
        ],
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
                  CircleAvatarSelector(
                    userType: 'retail',
                    selectedUserType: selectedUserType,
                    onSelect: (userType) {
                      setState(() {
                        selectedUserType = userType;
                      });
                    },
                  ),
                  CircleAvatarSelector(
                    userType: 'merchant',
                    selectedUserType: selectedUserType,
                    onSelect: (userType) {
                      setState(() {
                        selectedUserType = userType;
                      });
                    },
                  ),
                  CircleAvatarSelector(
                    userType: 'agent',
                    selectedUserType: selectedUserType,
                    onSelect: (userType) {
                      setState(() {
                        selectedUserType = userType;
                      });
                    },
                  ),
                  CircleAvatarSelector(
                    userType: 'corporate',
                    selectedUserType: selectedUserType,
                    onSelect: (userType) {
                      setState(() {
                        selectedUserType = userType;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: size.height / 5),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
            bottom: size.height / 40,
            left: size.width / 15,
            right: size.width / 15),
        child: NormalButton(
          size: size,
          title: AppLocalizations.of(context)!.proceed,
          onPressed: selectedUserType != null
              ? () async {
                  print(selectedUserType);
                  await _storeData();
                  if (selectedUserType == 'corporate') {
                    GoRouter.of(context)
                        .pushNamed(AppRouteConst.corporatePromptRoute);
                  } else {
                    GoRouter.of(context)
                        // .pushNamed(AppRouteConst.loginRoute);
                        .pushNamed(AppRouteConst.coorporateHomeRoute);
                    // .pushNamed(AppRouteConst.loginOrSignUpRoute);
                  }
                }
              : null,
        ),
      ),
    );
  }
}
