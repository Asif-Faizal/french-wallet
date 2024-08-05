import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:math' as math;
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet/wallet_event.dart';
import '../../../bloc/wallet/wallet_state.dart';

class RetailHomeScreen extends StatefulWidget {
  const RetailHomeScreen({super.key});

  @override
  State<RetailHomeScreen> createState() => _RetailHomeScreenState();
}

class _RetailHomeScreenState extends State<RetailHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isAuthenticated = false;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    context.read<WalletBloc>().add(FetchWalletDetails());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    print(message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  void _flipCard() {
    if (_controller.status != AnimationStatus.forward) {
      if (_isFront) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isFront = !_isFront;
    }
  }

  void _showServiceListBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return Container(
          padding: const EdgeInsets.all(20),
          height: size.height * 0.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                'All Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade800,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      leading: Icon(Icons.phone_android),
                      title: Text('Mobile Recharge'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.tv),
                      title: Text('DTH Recharge'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.electric_car),
                      title: Text('Electricity Bill'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.water),
                      title: Text('Water Bill'),
                      onTap: () {},
                    ),
                    ListTile(
                      leading: Icon(Icons.satellite),
                      title: Text('Broadband Bill'),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _auth() async {
    try {
      final bool canAuth = await auth.canCheckBiometrics;
      final bool isDeviceSupported = await auth.isDeviceSupported();

      if (canAuth && isDeviceSupported) {
        final bool didAuth = await auth.authenticate(
          localizedReason: 'Please Authenticate to show Card Details',
          options: AuthenticationOptions(biometricOnly: true),
        );
        setState(() {
          _isAuthenticated = didAuth;
        });
      } else {
        _showSnackBar('Biometric authentication is not available', Colors.red);
      }
    } catch (e) {
      print(e);
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<WalletBloc, WalletState>(
      listener: (context, state) {
        if (state is WalletError) {
          _showSnackBar(state.message, Colors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            toolbarHeight: size.height / 12,
            foregroundColor: Colors.blue.shade300,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.person),
                      onPressed: () {},
                    ),
                  ],
                ),
              ],
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(
              color: Colors.blue.shade300,
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final rotationY = _animation.value * math.pi;
                          final isBack = _animation.value >= 0.5;

                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(rotationY),
                            alignment: Alignment.center,
                            child: isBack
                                ? _buildWalletBack(context, state)
                                : _buildWalletFront(context, state),
                          );
                        },
                      ),
                      Positioned.fill(
                        child: GestureDetector(
                          onTap: _flipCard,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 3,
                    children: [
                      _buildDashboardItem(
                        context,
                        icon: Icons.account_balance_wallet,
                        title: 'My Account',
                        onTap: () {},
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.send,
                        title: 'Send Money',
                        onTap: () {},
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.add,
                        title: 'Add Money',
                        onTap: () {},
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.receipt,
                        title: 'Pay Bills',
                        onTap: () {},
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.history,
                        title: 'Transaction History',
                        onTap: () {
                          GoRouter.of(context)
                              .pushNamed(AppRouteConst.transactionListRoute);
                        },
                      ),
                      _buildDashboardItem(
                        context,
                        icon: Icons.more_horiz,
                        title: 'More',
                        onTap: _showServiceListBottomSheet,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWalletFront(BuildContext context, WalletState state) {
    final size = MediaQuery.of(context).size;
    if (state is WalletLoaded) {
      return Container(
        width: size.width,
        height: size.height / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Balance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              state.balance,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              state.cardNum,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
          ],
        ),
      );
    } else if (state is WalletLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(child: Text('Tap to view Wallet details.'));
    }
  }

  Widget _buildWalletBack(BuildContext context, WalletState state) {
    final size = MediaQuery.of(context).size;
    if (state is WalletLoaded) {
      return Container(
        width: size.width,
        height: size.height / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.blue.shade300, Colors.blue.shade800],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Card ID',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            SizedBox(height: 10),
            Text(
              state.cardId,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    } else if (state is WalletLoading) {
      return Center(child: CircularProgressIndicator());
    } else {
      return Center(child: Text('Tap to view Card details.'));
    }
  }

  Widget _buildDashboardItem(BuildContext context,
      {required IconData icon,
      required String title,
      required Function onTap}) {
    return GestureDetector(
      onTap: () => onTap(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: Colors.blue.shade800),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
