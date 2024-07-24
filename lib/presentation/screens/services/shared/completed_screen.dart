import 'package:audioplayers/audioplayers.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompletedAnimationScreen extends StatefulWidget {
  @override
  _CompletedAnimationScreenState createState() =>
      _CompletedAnimationScreenState();
}

class _CompletedAnimationScreenState extends State<CompletedAnimationScreen>
    with SingleTickerProviderStateMixin {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late AnimationController _controller;
  String? _userType;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _getUser();
    playSound();
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToNextScreen(_userType);
      }
    });
  }

  void playSound() async {
    final player = AudioPlayer();
    try {
      await Future.delayed(Duration(seconds: 1));
      await player.play(AssetSource("Coin.mp3"));
    } catch (e) {
      print("Error playing sound: $e");
    }
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
    if (userType == 'retail') {
      GoRouter.of(context).pushNamed(AppRouteConst.retailHomeRoute);
    } else if (userType == 'agent') {
      GoRouter.of(context).pushNamed(AppRouteConst.agentHomeRoute);
    } else if (userType == 'merchant') {
      // Uncomment and add route if needed
      // GoRouter.of(context).pushNamed(AppRouteConst.merchantHomeRoute);
    } else if (userType == 'coorporate') {
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
          'https://lottie.host/17805e6e-e2ce-4705-bad7-2acd1a815f73/9uOgrM0U2C.json',
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
