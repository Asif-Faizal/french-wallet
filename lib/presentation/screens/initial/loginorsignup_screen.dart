import 'package:ewallet2/presentation/widgets/shared/normal_appbar.dart';
import 'package:ewallet2/presentation/widgets/shared/normal_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../../shared/router/router_const.dart';

class LoginOrSignupScreen extends StatefulWidget {
  const LoginOrSignupScreen({super.key});

  @override
  State<LoginOrSignupScreen> createState() => _LoginOrSignupScreenState();
}

class _LoginOrSignupScreenState extends State<LoginOrSignupScreen> {
  String _userType = '';
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _retrieveData();
  }

  Future<void> _retrieveData() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userType = prefs.getString('userType') ?? 'default_value';
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final List<String> carouselImages = [
      'https://as1.ftcdn.net/v2/jpg/02/42/76/76/1000_F_242767680_DmkpQt7tMDRbG0dOy5194CAkXQNvQ9lT.jpg',
      'https://as2.ftcdn.net/v2/jpg/01/24/30/89/1000_F_124308988_7Ps8fE68TGdwYhDYGsgxwDo0CyFEYIHV.jpg',
    ];

    return Scaffold(
      appBar: const NormalAppBar(text: ''),
      body: SizedBox(
        width: size.width,
        height: size.height,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: size.height / 30,
            horizontal: size.width / 20,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: size.height / 30),
              Text(
                AppLocalizations.of(context)!.welcome_to,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: size.height / 10),
              Text(
                '${AppLocalizations.of(context)!.please_login_signup} $_userType',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              SizedBox(height: size.height / 20),
              Text(
                AppLocalizations.of(context)!.already_user,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: size.height / 80),
              NormalButton(
                size: size,
                title: AppLocalizations.of(context)!.login,
                onPressed: () {
                  GoRouter.of(context).pushNamed(AppRouteConst.loginRoute);
                },
              ),
              SizedBox(height: size.height / 30),
              Text(
                AppLocalizations.of(context)!.new_to,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: size.height / 80),
              NormalButton(
                size: size,
                title: AppLocalizations.of(context)!.sign_in,
                onPressed: () {
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.verifyNumberRoute);
                },
              ),
              SizedBox(height: size.height / 8),
              CarouselSlider(
                options: CarouselOptions(
                  height: size.height / 10,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 1),
                  enlargeCenterPage: true,
                  enableInfiniteScroll: true,
                ),
                items: carouselImages.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: const EdgeInsets.symmetric(horizontal: 5.0),
                        decoration: const BoxDecoration(),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
