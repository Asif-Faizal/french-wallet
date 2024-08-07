import 'package:carousel_slider/carousel_slider.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ewallet2/presentation/screens/dashboard/card_info_screen.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:local_auth/local_auth.dart';
import '../../../bloc/wallet/wallet_bloc.dart';
import '../../../bloc/wallet/wallet_event.dart';
import '../../../bloc/wallet/wallet_state.dart';
import '../../../widgets/shared/card.dart';
import '../../../widgets/shared/dashboard_item.dart';
import '../../../widgets/shared/service_list_bottom_sheet.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen>
    with SingleTickerProviderStateMixin {
  bool _isAuthenticated = false;
  bool _isBalanceVisible = false;
  final LocalAuthentication auth = LocalAuthentication();
  final GlobalKey<FlipCardState> _flipCardKey = GlobalKey<FlipCardState>();
  final List<String> carouselImages = [
    'https://as1.ftcdn.net/v2/jpg/02/42/76/76/1000_F_242767680_DmkpQt7tMDRbG0dOy5194CAkXQNvQ9lT.jpg',
    'https://as2.ftcdn.net/v2/jpg/01/24/30/89/1000_F_124308988_7Ps8fE68TGdwYhDYGsgxwDo0CyFEYIHV.jpg',
  ];

  @override
  void initState() {
    super.initState();
    context.read<WalletBloc>().add(FetchWalletDetails());
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
          if (_isAuthenticated) {
            _isBalanceVisible = true;
          }
        });
      } else {
        _showSnackBar('Biometric authentication is not available', Colors.red);
      }
    } catch (e) {
      print(e);
      _showSnackBar(e.toString(), Colors.red);
    }
  }

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible;
      if (!_isBalanceVisible) {
        _isAuthenticated = false;
      }
    });
  }

  void _flipCard() {
    if (_flipCardKey.currentState != null) {
      _flipCardKey.currentState?.toggleCard();
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
          drawer: Drawer(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                ListTile(
                  leading: Icon(Icons.account_circle),
                  title: Text('Account Info'),
                  onTap: () {
                    GoRouter.of(context)
                        .pushNamed(AppRouteConst.accountInfoRoute);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  onTap: () {},
                ),
              ],
            ),
          ),
          appBar: AppBar(
            foregroundColor: Colors.blue.shade800,
            actions: [
              IconButton(
                  onPressed: () {
                    GoRouter.of(context)
                        .pushNamed(AppRouteConst.transactionListRoute);
                  },
                  icon: Icon(
                    Icons.note,
                    size: 35,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.notifications,
                    size: 35,
                  )),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CardInfoScreen()));
                    },
                    child: WalletCard(
                      isAuthenticated: _isAuthenticated,
                      isBalanceVisible: _isBalanceVisible,
                      flipCardKey: _flipCardKey,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                          color: Colors.blue.shade800,
                          onPressed: _flipCard,
                          icon: Icon(Icons.flip)),
                      IconButton(
                          color: Colors.blue.shade800,
                          onPressed: () {
                            if (_isBalanceVisible) {
                              _toggleBalanceVisibility();
                            } else {
                              _auth();
                            }
                          },
                          icon: Icon(
                            _isBalanceVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.blue.shade100,
                  ),
                  Container(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.send,
                          title: 'Send\nMoney',
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.retailSendRoute);
                          },
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.download,
                          title: 'Request\nMoney',
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.retailReceiveRoute);
                          },
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.store_mall_directory,
                          title: 'Manage\nStore',
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.merchantStoreRoute);
                          },
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.add,
                          title: 'TopUp\n ',
                          onTap: () {},
                        )),
                      ],
                    ),
                  ),
                  Divider(
                    thickness: 1,
                    color: Colors.blue.shade100,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Services',
                        style: TextStyle(
                            color: Colors.blue.shade800,
                            fontSize: 28,
                            fontWeight: FontWeight.bold),
                      ),
                      TextButton(
                          onPressed: () {
                            showModalBottomSheet(
                              isScrollControlled: true,
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(5)),
                              ),
                              builder: (context) {
                                return ServiceListBottomSheet();
                              },
                            );
                          },
                          child: Text(
                            'View all',
                            style: TextStyle(
                                fontSize: 14, color: Colors.blue.shade800),
                          ))
                    ],
                  ),
                  Container(
                    height: 120,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.phone_iphone_outlined,
                          title: 'Mobile\nRecharge',
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.mobileRechargeRoute);
                          },
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.electrical_services_outlined,
                          title: 'Electricity\nBill',
                          onTap: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.electricityBillRoute);
                          },
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.tv,
                          title: 'DTH\nRecharge',
                          onTap: () {},
                        )),
                        Expanded(
                            child: DashboardItem(
                          icon: Icons.water,
                          title: 'Water\nBill',
                          onTap: () {},
                        )),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
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
          floatingActionButton: ElevatedButton(
            onPressed: () {
              GoRouter.of(context).pushNamed(AppRouteConst.qrCodeScanRoute);
            },
            child: Icon(
              Icons.qr_code_2,
              size: 40,
            ),
            style: ElevatedButton.styleFrom(
              elevation: 20,
              shadowColor: Colors.blue.shade900,
              foregroundColor: Colors.white,
              backgroundColor: Colors.blue.shade800,
              shape: CircleBorder(),
              padding: EdgeInsets.all(15),
            ),
          ),
        );
      },
    );
  }
}
