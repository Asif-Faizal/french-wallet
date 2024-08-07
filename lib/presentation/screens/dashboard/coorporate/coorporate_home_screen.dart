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

class CoorporateHomeScreen extends StatefulWidget {
  const CoorporateHomeScreen({super.key});

  @override
  State<CoorporateHomeScreen> createState() => _CoorporateHomeScreenState();
}

class _CoorporateHomeScreenState extends State<CoorporateHomeScreen>
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

  void _showManageChildCardOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.library_books),
                title: Text('View Child Users'),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.viewChildCardRoute);
                },
              ),
              ListTile(
                leading: Icon(Icons.add_card_outlined),
                title: Text('Add Child User'),
                onTap: () {
                  Navigator.pop(context);
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.createChildUserRoute);
                },
              ),
              ListTile(
                leading: Icon(Icons.transfer_within_a_station),
                title: Text('Transfer from Child'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.transfer_within_a_station),
                title: Text('Transfer to Child'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Block or Unblock Users'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
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
                          icon: Icons.manage_accounts,
                          title: 'Manage\nChild Users',
                          onTap: () {
                            _showManageChildCardOptions();
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

// class CoorporateHomeScreen extends StatefulWidget {
//   const CoorporateHomeScreen({super.key});

//   @override
//   State<CoorporateHomeScreen> createState() => _CoorporateHomeScreenState();
// }

// class _CoorporateHomeScreenState extends State<CoorporateHomeScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//   bool _isFront = true;
//   String _selectedItems = '';

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );

//     _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
//       ..addListener(() {
//         setState(() {});
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   void _flipCard() {
//     if (_controller.status != AnimationStatus.forward) {
//       if (_isFront) {
//         _controller.forward();
//       } else {
//         _controller.reverse();
//       }
//       _isFront = !_isFront;
//     }
//   }

//   Future<void> _savePreferences() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('selected_value', _selectedItems);
//   }

//   void _onListItemSelected(String item) {
//     setState(() {
//       _selectedItems = item;
//       _savePreferences();
//     });
//   }

//   void _showManageChildCardOptions() {
//     showModalBottomSheet(
//       context: context,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
//       ),
//       builder: (context) {
//         return Container(
//           padding: const EdgeInsets.all(20.0),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.credit_card),
//                 title: Text('View List of Cards'),
//                 onTap: () {
//                   Navigator.pop(context);
//                   GoRouter.of(context)
//                       .pushNamed(AppRouteConst.viewChildCardRoute);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.block),
//                 title: Text('Block or Unblock'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.transfer_within_a_station),
//                 title: Text('Transfer from Child'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.transfer_within_a_station),
//                 title: Text('Transfer to Child'),
//                 onTap: () {
//                   Navigator.pop(context);
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final size = MediaQuery.of(context).size;
//     return Scaffold(
//       appBar: AppBar(
//         toolbarHeight: size.height / 12,
//         foregroundColor: Colors.blue.shade300,
//         actions: [
//           IconButton(
//               onPressed: () {},
//               icon: Icon(
//                 Icons.notifications,
//                 size: 30,
//               )),
//           SizedBox(
//             width: size.width / 40,
//           ),
//           IconButton(
//               onPressed: () {
//                 GoRouter.of(context)
//                     .pushNamed(AppRouteConst.transactionListRoute);
//               },
//               icon: Icon(
//                 Icons.message,
//                 size: 30,
//               )),
//           SizedBox(
//             width: size.width / 30,
//           )
//         ],
//       ),
//       drawer: Drawer(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: <Widget>[
//             SizedBox(
//               height: 40,
//             ),
//             ListTile(
//               leading: Icon(Icons.account_circle),
//               title: Text('Account Info'),
//               onTap: () {
//                 GoRouter.of(context).pushNamed(AppRouteConst.accountInfoRoute);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () {},
//             ),
//           ],
//         ),
//       ),
//       body: SingleChildScrollView(
//         physics: const BouncingScrollPhysics(),
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Transform(
//               transform: Matrix4.rotationY(_animation.value * math.pi),
//               alignment: Alignment.center,
//               child: _animation.value < 0.5
//                   ? _buildFront(size)
//                   : Transform(
//                       transform: Matrix4.rotationY(math.pi),
//                       alignment: Alignment.center,
//                       child: _buildBack(size),
//                     ),
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.end,
//               children: [
//                 TextButton(
//                   onPressed: _flipCard,
//                   child: Icon(Icons.rotate_90_degrees_ccw,
//                       color: Colors.blue.shade500),
//                 ),
//                 TextButton(
//                   onPressed: () {},
//                   child: Icon(Icons.visibility_off_outlined,
//                       color: Colors.blue.shade500),
//                 )
//               ],
//             ),
//             Divider(
//               color: Colors.blue.shade100,
//               thickness: 1,
//             ),
//             SizedBox(
//               height: size.height / 7,
//               width: size.height,
//               child: Center(
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   children: [
//                     buildListItem(
//                       'Send\nMoney',
//                       Card(
//                         color: Colors.blue.shade300,
//                         child: Padding(
//                           padding: const EdgeInsets.all(5),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.upload,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               _onListItemSelected('Send');
//                               GoRouter.of(context)
//                                   .pushNamed(AppRouteConst.retailSendRoute);
//                             },
//                           ),
//                         ),
//                       ),
//                       size,
//                     ),
//                     buildListItem(
//                       'Receive\nMoney',
//                       Card(
//                         color: Colors.blue.shade300,
//                         child: Padding(
//                           padding: const EdgeInsets.all(5),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.money,
//                               color: Colors.white,
//                             ),
//                             onPressed: () {
//                               _onListItemSelected('Receive');
//                               GoRouter.of(context)
//                                   .pushNamed(AppRouteConst.retailReceiveRoute);
//                             },
//                           ),
//                         ),
//                       ),
//                       size,
//                     ),
//                     buildListItem(
//                       'Manage\nChild Card',
//                       Card(
//                         color: Colors.blue.shade300,
//                         child: Padding(
//                           padding: const EdgeInsets.all(5),
//                           child: IconButton(
//                             icon: Icon(
//                               Icons.credit_card,
//                               color: Colors.white,
//                             ),
//                             onPressed: _showManageChildCardOptions,
//                           ),
//                         ),
//                       ),
//                       size,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Divider(
//               color: Colors.blue.shade100,
//               thickness: 1,
//             ),
//             SizedBox(
//               height: size.height / 40,
//             ),
//             Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Padding(
//                 padding:
//                     const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
//                 child: Column(
//                   children: [
//                     CarouselSlider(
//                       items: [
//                         'https://as2.ftcdn.net/v2/jpg/02/69/77/25/1000_F_269772568_eqFTjMBNfzhrfsgpgnekZNkueP99OSOt.jpg',
//                         'https://c8.alamy.com/comp/RJXPNA/business-travel-special-offer-template-horizontal-banner-tourism-agency-seasonal-sale-poster-design-RJXPNA.jpg',
//                         'https://www.shutterstock.com/shutterstock/photos/793624765/display_1500/stock-vector-horizontal-sale-poster-end-of-season-special-offer-design-template-font-design-vector-793624765.jpg',
//                         'https://cdn.vectorstock.com/i/1000v/17/23/big-sale-design-special-offer-poster-template-vector-37351723.jpg',
//                       ]
//                           .map((item) => SizedBox(
//                               height: size.height / 8,
//                               width: double.infinity,
//                               child: ClipRRect(
//                                   borderRadius: BorderRadius.circular(5),
//                                   child:
//                                       Image.network(item, fit: BoxFit.cover))))
//                           .toList(),
//                       options: CarouselOptions(
//                         height: size.height / 8,
//                         autoPlay: true,
//                         enlargeCenterPage: true,
//                         viewportFraction: 1.0,
//                         aspectRatio: 2.0,
//                         onPageChanged: (index, reason) {},
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget buildListItem(String text, Widget icon, Size size) {
//     final theme = Theme.of(context);
//     return Container(
//       width: size.width / 5,
//       margin: EdgeInsets.symmetric(horizontal: size.width / 60),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           icon,
//           SizedBox(
//             height: size.height / 70,
//           ),
//           Text(
//             text,
//             style: theme.textTheme.bodySmall,
//             textAlign: TextAlign.center,
//           )
//         ],
//       ),
//     );
//   }

//   Widget _buildFront(Size size) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(10),
//         child: Stack(
//           children: [
//             SizedBox(
//               height: size.height / 4.2,
//               width: double.infinity,
//               child: Image.network(
//                 'https://cdn.prod.website-files.com/5a9ee6416e90d20001b20038/64cfd57c347c14534e2dc618_%20-%201.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             SizedBox(
//               height: size.height / 4.2,
//               width: double.infinity,
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
//                 child: Container(
//                   height: size.height / 4,
//                   width: double.infinity,
//                   color: Colors.black.withOpacity(0.3),
//                   padding:
//                       const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('VISA',
//                               style: TextStyle(
//                                   fontSize: size.height / 25,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white)),
//                           Icon(
//                             Icons.wallet,
//                             size: size.height / 15,
//                             color: Colors.white,
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         width: size.width / 2,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.start,
//                           children: [
//                             Text('Balance:',
//                                 style: TextStyle(
//                                     fontSize: size.height / 40,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white)),
//                             SizedBox(
//                               width: size.width / 40,
//                             ),
//                             Text('**********',
//                                 style: TextStyle(
//                                     fontSize: size.height / 40,
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white)),
//                           ],
//                         ),
//                       ),
//                       Spacer(),
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text('1234 **** **** 1234',
//                               style: TextStyle(
//                                   fontSize: size.height / 40,
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white)),
//                           Column(
//                             children: [
//                               Text('Valid Thru',
//                                   style: TextStyle(
//                                       fontSize: size.height / 60,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white)),
//                               Text('09/30',
//                                   style: TextStyle(
//                                       fontSize: size.height / 50,
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.white)),
//                             ],
//                           )
//                         ],
//                       ),
//                       SizedBox(
//                         height: size.height / 60,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildBack(Size size) {
//     return Card(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(5),
//         child: Stack(
//           children: [
//             SizedBox(
//               height: size.height / 4.2,
//               width: double.infinity,
//               child: Image.network(
//                 'https://cdn.prod.website-files.com/5a9ee6416e90d20001b20038/64cfd57c347c14534e2dc618_%20-%201.png',
//                 fit: BoxFit.cover,
//               ),
//             ),
//             Column(
//               children: [
//                 SizedBox(
//                   height: size.height / 6,
//                   width: double.infinity,
//                   child: BackdropFilter(
//                     filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
//                     child: Container(
//                       height: size.height / 4.2,
//                       width: double.infinity,
//                       color: Colors.black.withOpacity(0.3),
//                       padding: const EdgeInsets.symmetric(
//                           vertical: 5, horizontal: 25),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         children: [
//                           SizedBox(
//                             height: size.height / 60,
//                           ),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Container(
//                                 height: size.height / 25,
//                                 width: size.width / 1.6,
//                                 color: Colors.grey.shade300,
//                                 margin: const EdgeInsets.symmetric(vertical: 7),
//                               ),
//                               Container(
//                                 height: size.height / 25,
//                                 width: size.width / 10,
//                                 color: Colors.white,
//                                 child: Row(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   mainAxisAlignment: MainAxisAlignment.start,
//                                   children: [
//                                     Text('***',
//                                         style: TextStyle(
//                                             fontStyle: FontStyle.italic)),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                               'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
//                               style:
//                                   TextStyle(fontSize: 11, color: Colors.white)),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                   height: size.height / 20,
//                   color: Colors.black,
//                 )
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
