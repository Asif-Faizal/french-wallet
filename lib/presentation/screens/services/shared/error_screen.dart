import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ErrorAnimationScreen extends StatefulWidget {
  @override
  _ErrorAnimationScreenState createState() => _ErrorAnimationScreenState();
}

class _ErrorAnimationScreenState extends State<ErrorAnimationScreen>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late AnimationController _controller;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _getUser();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen(_userType);
      }
    });
  }

  Future<void> _getUser() async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      _userType = prefs.getString('userType');
    });
    print(
        '############################################$_userType#######################################');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToNextScreen(String? userType) {
    if (userType == 'RETAIL' || userType == 'retail') {
      GoRouter.of(context).pushNamed(AppRouteConst.retailHomeRoute);
    } else if (userType == 'AGENT' || userType == 'agent') {
      GoRouter.of(context).pushNamed(AppRouteConst.agentHomeRoute);
    } else if (userType == 'MERCHANT' || userType == 'merchant') {
      GoRouter.of(context).pushNamed(AppRouteConst.merchantHomeRoute);
    } else if (userType == 'COORPORATE' || userType == 'coorporate') {
      GoRouter.of(context).pushNamed(AppRouteConst.coorporateHomeRoute);
    } else {
      GoRouter.of(context).pushNamed(AppRouteConst.promptRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.network(
          'https://lottie.host/e37be855-49a3-4488-be3a-2c07042a8255/HQyJtBD6lK.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller
              ..duration = composition.duration
              ..forward();
          },
        ),
      ),
    );
  }
}
