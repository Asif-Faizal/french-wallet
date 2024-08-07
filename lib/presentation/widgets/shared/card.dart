import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_state.dart';

class WalletCard extends StatefulWidget {
  final bool isAuthenticated;
  final bool isBalanceVisible;
  final GlobalKey<FlipCardState> flipCardKey;

  const WalletCard({
    Key? key,
    required this.isAuthenticated,
    required this.isBalanceVisible,
    required this.flipCardKey,
  }) : super(key: key);

  @override
  State<WalletCard> createState() => _WalletCardState();
}

class _WalletCardState extends State<WalletCard> {
  @override
  Widget build(BuildContext context) {
    return FlipCard(
      key: widget.flipCardKey,
      direction: FlipDirection.HORIZONTAL,
      flipOnTouch: false,
      front: _buildWalletFront(context),
      back: _buildWalletBack(context),
    );
  }

  Widget _buildWalletFront(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final state = context.watch<WalletBloc>().state;

    if (widget.isAuthenticated) {
      if (state is WalletLoaded) {
        return Stack(
          children: [
            Card(
              shadowColor: Colors.blue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              elevation: 20,
              child: Container(
                  width: size.width,
                  height: size.height / 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Image.network(
                      'https://i.pinimg.com/736x/71/78/08/717808c6a6976c95e2f7b50dd6d485f3.jpg',
                      fit: BoxFit.cover,
                    ),
                  )),
            ),
            Container(
              width: size.width,
              height: size.height / 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 80,
                          child: Image.network(
                              'https://cdn.freebiesupply.com/logos/large/2x/visa-logo-black-and-white.png'),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: Icon(
                              Icons.sim_card_sharp,
                              color: Colors.amber,
                              size: 40,
                            ),
                          ),
                        )
                      ],
                    ),
                    Center(
                      child: Text(
                        widget.isBalanceVisible
                            ? '₹ ${state.balance}'
                            : '*****',
                        style: TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Card Number',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                widget.isBalanceVisible
                                    ? state.cardNum
                                    : '**** **** **** ****',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'Valid Thru',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white),
                              ),
                              Text(
                                '12/28',
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      } else if (state is WalletError) {
        return Center(
          child: Text(state.message),
        );
      } else {
        return Center(
          child: CircularProgressIndicator(),
        );
      }
    } else {
      return Stack(
        children: [
          Card(
            shadowColor: Colors.blue,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            elevation: 20,
            child: Container(
                width: size.width,
                height: size.height / 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Image.network(
                    'https://i.pinimg.com/736x/71/78/08/717808c6a6976c95e2f7b50dd6d485f3.jpg',
                    fit: BoxFit.cover,
                  ),
                )),
          ),
          Container(
            width: size.width,
            height: size.height / 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15, left: 15, right: 15),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: 80,
                        child: Image.network(
                            'https://cdn.freebiesupply.com/logos/large/2x/visa-logo-black-and-white.png'),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: RotatedBox(
                          quarterTurns: 1,
                          child: Icon(
                            Icons.sim_card_sharp,
                            color: Colors.amber,
                            size: 40,
                          ),
                        ),
                      )
                    ],
                  ),
                  Center(
                    child: Text(
                      '*****',
                      style: TextStyle(
                          fontSize: 40,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Card Number',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            Text(
                              '**** **** **** ****',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Valid Thru',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.white),
                            ),
                            Text(
                              '**/**',
                              style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }
  }

  Widget _buildWalletBack(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Card(
          shadowColor: Colors.blue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          elevation: 20,
          child: Container(
              width: size.width,
              height: size.height / 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Image.network(
                  'https://i.pinimg.com/736x/71/78/08/717808c6a6976c95e2f7b50dd6d485f3.jpg',
                  fit: BoxFit.cover,
                ),
              )),
        ),
        Container(
            width: size.width,
            height: size.height / 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        color: Colors.grey.shade400,
                        height: 40,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              height: 40,
                              width: 60,
                              color: Colors.grey.shade200,
                              child: Center(
                                  child: Text(
                                '123',
                                style: GoogleFonts.merienda(fontSize: 12),
                              )),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                        style: TextStyle(fontSize: 10),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Divider(
                    thickness: 40,
                  ),
                )
              ],
            )),
      ],
    );
  }
}
