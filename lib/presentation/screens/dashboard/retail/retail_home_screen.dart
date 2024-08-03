import 'dart:convert';
import 'dart:ui';
import 'dart:math' as math;

import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ewallet2/shared/router/router_const.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../shared/config/api_config.dart';

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
  String? balance;
  String? card_num;
  String? card_id;
  bool _isAuthenticated = false;
  bool _isLoading = true;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void initState() {
    super.initState();
    _fetchCardDetails();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    _fetchCardDetails();
  }

  Future<void> _fetchCardDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? jwtToken = prefs.getString('jwt_token');
    String? refreshToken = prefs.getString('refresh_token');

    if (jwtToken == null || refreshToken == null) {
      _showSnackBar('Session expired. Please log in again.', Colors.red);
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (JwtDecoder.isExpired(jwtToken)) {
      jwtToken = await _refreshToken(refreshToken);
      if (jwtToken == null) {
        _showSnackBar('Session expired. Please log in again.', Colors.red);
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    final url =
        Uri.parse("https://api-innovitegra.online/transfer/wallet/wallet_list");
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Deviceid': Config.deviceId,
        'Authorization': 'Bearer $jwtToken'
      },
    );
    print(response.body);
    setState(() {
      _isLoading = false;
    });
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final status = responseData["status"];
      final statusCode = responseData["code"];
      if (status == "success") {
        setState(() {
          balance = responseData["balance"];
          card_id = responseData["card_udid"];
          card_num = responseData["card_num"];
          print("$balance $card_id");
        });
      } else if (status == "Fail") {
        if (statusCode == 5) {
          _showSnackBar('Session TimedOut please Login again', Colors.red);
        }
      }
    } else {
      _showSnackBar('Failed to fetch transactions.', Colors.red);
    }
  }

  Future<String?> _refreshToken(String refreshToken) async {
    final url = Uri.parse(Config.refresh_token);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken'
      },
    );

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);
      final jwtToken = responseBody['jwt_token'];
      if (jwtToken != null) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('jwt_token', jwtToken);
        return jwtToken;
      }
    }
    return null;
  }

  void _showSnackBar(String message, Color backgroundColor) {
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

  void _auth() async {
    if (!_isAuthenticated) {
      try {
        final bool canAuth = await auth.canCheckBiometrics;
        print(canAuth);
        if (canAuth) {
          final bool didAuth = await auth.authenticate(
              localizedReason: 'Please Authenticate to show Card Details',
              options: AuthenticationOptions(biometricOnly: true));
          setState(() {
            _isAuthenticated = didAuth;
          });
        }
      } catch (e) {
        print(e);
        _showSnackBar(e.toString(), Colors.red);
      }
    } else {
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: size.height / 12,
          foregroundColor: Colors.blue.shade300,
          actions: [
            IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.notifications,
                  size: 30,
                )),
            SizedBox(
              width: size.width / 40,
            ),
            IconButton(
                onPressed: () {
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.transactionListRoute);
                },
                icon: Icon(
                  Icons.message,
                  size: 30,
                )),
            SizedBox(
              width: size.width / 30,
            )
          ],
        ),
        drawer: Drawer(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
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
                  Navigator.pop(context);
                  GoRouter.of(context)
                      .pushNamed(AppRouteConst.accountInfoRoute);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () async {
                  SharedPreferences preferences =
                      await SharedPreferences.getInstance();
                  await preferences.clear();
                },
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Transform(
                transform: Matrix4.rotationY(_animation.value * math.pi),
                alignment: Alignment.center,
                child: _animation.value < 0.5
                    ? _buildFront(size)
                    : Transform(
                        transform: Matrix4.rotationY(math.pi),
                        alignment: Alignment.center,
                        child: _buildBack(size),
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _flipCard,
                    child: Icon(Icons.rotate_90_degrees_ccw,
                        color: Colors.blue.shade500),
                  ),
                  TextButton(
                    onPressed: () {
                      _auth();
                    },
                    child: _isAuthenticated
                        ? Icon(Icons.visibility_off_outlined,
                            color: Colors.blue.shade500)
                        : Icon(Icons.visibility, color: Colors.blue.shade500),
                  )
                ],
              ),
              Divider(
                color: Colors.blue.shade100,
                thickness: 1,
              ),
              SizedBox(
                height: size.height / 7,
                width: size.height,
                child: Center(
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildListItem(
                        'Send',
                        Card(
                          color: Colors.blue.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: IconButton(
                              icon: Icon(Icons.send_outlined,
                                  color: Colors.white),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString('selected_value', 'Send');
                                GoRouter.of(context)
                                    .pushNamed(AppRouteConst.retailSendRoute);
                              },
                            ),
                          ),
                        ),
                        size,
                      ),
                      buildListItem(
                        'Receive',
                        Card(
                          color: Colors.blue.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: IconButton(
                              icon: Icon(Icons.download_outlined,
                                  color: Colors.white),
                              onPressed: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                await prefs.setString(
                                    'selected_value', 'Receive');
                                GoRouter.of(context).pushNamed(
                                    AppRouteConst.retailReceiveRoute);
                              },
                            ),
                          ),
                        ),
                        size,
                      ),
                      buildListItem(
                        'Top Up',
                        Card(
                          color: Colors.blue.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: IconButton(
                              icon: Icon(Icons.upload_file_outlined,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        size,
                      ),
                      buildListItem(
                        'Card',
                        Card(
                          color: Colors.blue.shade300,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: IconButton(
                              icon: Icon(Icons.payment_outlined,
                                  color: Colors.white),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        size,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 80,
              ),
              Divider(
                color: Colors.blue.shade100,
                thickness: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Service List',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade500)),
                  TextButton(
                    onPressed: _showServiceListBottomSheet,
                    child: Text('View all',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade500)),
                  ),
                ],
              ),
              SizedBox(
                height: size.height / 80,
              ),
              SizedBox(
                height: size.height / 8,
                child: Center(
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: [
                      buildServiceListItem(
                        'Mobile Recharge',
                        IconButton(
                          icon: Icon(
                            Icons.call,
                          ),
                          onPressed: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.mobileRechargeRoute);
                          },
                        ),
                        size,
                      ),
                      buildServiceListItem(
                        'Electricity Bill',
                        IconButton(
                          icon: Icon(
                            Icons.electric_bolt_rounded,
                          ),
                          onPressed: () {
                            GoRouter.of(context)
                                .pushNamed(AppRouteConst.electricityBillRoute);
                          },
                        ),
                        size,
                      ),
                      buildServiceListItem(
                        'X Box',
                        IconButton(
                          icon: Icon(
                            Icons.abc,
                          ),
                          onPressed: () {},
                        ),
                        size,
                      ),
                      buildServiceListItem(
                        'Alfa',
                        IconButton(
                          icon: Icon(
                            Icons.abc,
                          ),
                          onPressed: () {},
                        ),
                        size,
                      ),
                      buildServiceListItem(
                        'Pay',
                        IconButton(
                          icon: Icon(
                            Icons.abc,
                          ),
                          onPressed: () {},
                        ),
                        size,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: size.height / 40,
              ),
              Divider(
                color: Colors.blue.shade100,
                thickness: 1,
              ),
              SizedBox(
                height: size.height / 40,
              ),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  child: Column(
                    children: [
                      CarouselSlider(
                        items: [
                          'https://as2.ftcdn.net/v2/jpg/02/69/77/25/1000_F_269772568_eqFTjMBNfzhrfsgpgnekZNkueP99OSOt.jpg',
                          'https://c8.alamy.com/comp/RJXPNA/business-travel-special-offer-template-horizontal-banner-tourism-agency-seasonal-sale-poster-design-RJXPNA.jpg',
                          'https://www.shutterstock.com/shutterstock/photos/793624765/display_1500/stock-vector-horizontal-sale-poster-end-of-season-special-offer-design-template-font-design-vector-793624765.jpg',
                          'https://cdn.vectorstock.com/i/1000v/17/23/big-sale-design-special-offer-poster-template-vector-37351723.jpg',
                        ]
                            .map((item) => SizedBox(
                                height: size.height / 8,
                                width: double.infinity,
                                child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(item,
                                        fit: BoxFit.cover))))
                            .toList(),
                        options: CarouselOptions(
                          height: size.height / 8,
                          autoPlay: true,
                          enlargeCenterPage: true,
                          viewportFraction: 1.0,
                          aspectRatio: 2.0,
                          onPageChanged: (index, reason) {},
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: ElevatedButton(
            style: ElevatedButton.styleFrom(
                elevation: 20,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue.shade500),
            onPressed: () {
              GoRouter.of(context).pushNamed(AppRouteConst.qrCodeScanRoute);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 20,
              ),
              child: Icon(
                Icons.qr_code_2,
                size: 30,
              ),
            )));
  }

  Widget _buildFront(Size size) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: Image.network(
                'https://cdn.prod.website-files.com/5a9ee6416e90d20001b20038/64cfd57c347c14534e2dc618_%20-%201.png',
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                child: Container(
                  height: size.height / 4,
                  width: double.infinity,
                  color: Colors.black.withOpacity(0.3),
                  padding:
                      const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('VISA',
                              style: GoogleFonts.rowdies(
                                  color: Colors.white,
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold)),
                          Icon(
                            Icons.wallet,
                            size: size.height / 15,
                            color: Colors.white,
                          )
                        ],
                      ),
                      SizedBox(
                        width: size.width / 2,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('Balance:',
                                style: TextStyle(
                                    fontSize: size.height / 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            SizedBox(
                              width: size.width / 40,
                            ),
                            if (_isAuthenticated)
                              Text(balance ?? '',
                                  style: TextStyle(
                                      fontSize: size.height / 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            if (!_isAuthenticated)
                              Text('#######',
                                  style: TextStyle(
                                      fontSize: size.height / 40,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                          ],
                        ),
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_isAuthenticated)
                            Text(card_num!,
                                style: TextStyle(
                                    fontSize: size.height / 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          if (!_isAuthenticated)
                            Text('#### #### #### ####',
                                style: TextStyle(
                                    fontSize: size.height / 40,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                          Column(
                            children: [
                              Text('Valid Thru',
                                  style: TextStyle(
                                      fontSize: size.height / 60,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                              Text('09/30',
                                  style: TextStyle(
                                      fontSize: size.height / 50,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white)),
                            ],
                          )
                        ],
                      ),
                      SizedBox(
                        height: size.height / 60,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(Size size) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          children: [
            SizedBox(
              height: size.height / 4.2,
              width: double.infinity,
              child: Image.network(
                'https://cdn.prod.website-files.com/5a9ee6416e90d20001b20038/64cfd57c347c14534e2dc618_%20-%201.png',
                fit: BoxFit.cover,
              ),
            ),
            Column(
              children: [
                SizedBox(
                  height: size.height / 6,
                  width: double.infinity,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0.2, sigmaY: 0.2),
                    child: Container(
                      height: size.height / 4.2,
                      width: double.infinity,
                      color: Colors.black.withOpacity(0.3),
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 25),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: size.height / 60,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: size.height / 25,
                                width: size.width / 1.6,
                                color: Colors.grey.shade300,
                                margin: const EdgeInsets.symmetric(vertical: 7),
                              ),
                              Container(
                                height: size.height / 25,
                                width: size.width / 10,
                                color: Colors.white,
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('***',
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Text(
                              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                              style:
                                  TextStyle(fontSize: 11, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  height: size.height / 20,
                  color: Colors.black,
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildListItem(String text, Widget icon, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width / 5,
      margin: EdgeInsets.symmetric(horizontal: size.width / 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          SizedBox(
            height: size.height / 70,
          ),
          Text(text, style: theme.textTheme.bodyLarge)
        ],
      ),
    );
  }

  Widget buildServiceListItem(String text, Widget icon, Size size) {
    final theme = Theme.of(context);
    return Container(
      width: size.width / 4,
      child: Card(
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            Padding(
              padding: EdgeInsets.only(
                  left: size.width / 60,
                  right: size.width / 60,
                  bottom: size.height / 200),
              child: Text(
                text,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}
