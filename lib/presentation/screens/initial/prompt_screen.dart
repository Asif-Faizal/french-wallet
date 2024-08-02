import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      appBar: NormalAppBar(text: ''),
      body: SizedBox(
        height: size.height,
        width: size.width,
        child: Padding(
          padding: EdgeInsets.symmetric(
              vertical: size.height / 30, horizontal: size.width / 20),
          child: Column(
            children: [
              SizedBox(
                height: size.height / 8,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.wallet_membership_rounded,
                    size: size.height / 20,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  SizedBox(width: size.width / 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ePurse',
                        style: Theme.of(context)
                            .textTheme
                            .headlineLarge!
                            .copyWith(
                              color: Theme.of(context).colorScheme.onBackground,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: size.height / 8),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                        AppLocalizations.of(context)!
                            .select_type_of_user_heading,
                        style: GoogleFonts.manrope()),
                  ],
                ),
              ),
              SizedBox(height: size.height / 20),
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
                        .pushNamed(AppRouteConst.verifyNumberRoute);
                  } else {
                    if (selectedUserType == 'retail') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userType', selectedUserType!);
                    } else if (selectedUserType == 'merchant') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userType', selectedUserType!);
                    } else if (selectedUserType == 'agent') {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('userType', selectedUserType!);
                    }
                    GoRouter.of(context)
                        // .pushNamed(AppRouteConst.loginRoute);
                        .pushNamed(AppRouteConst.retailHomeRoute);
                    // .pushNamed(AppRouteConst.sentOtpSignInRoute);
                  }
                }
              : null,
        ),
      ),
    );
  }
}
