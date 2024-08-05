import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    final size = MediaQuery.of(context).size;
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
                'Wallet Balance',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              Text(
                widget.isBalanceVisible ? '₹ ${state.balance}' : '*****',
                style: TextStyle(fontSize: 40, color: Colors.white),
              ),
              SizedBox(height: 20),
              Text(
                'Card Number',
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              Text(
                widget.isBalanceVisible ? state.cardNum : '**** **** **** ****',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
            ],
          ),
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
      return Container(
        width: size.width,
        height: size.height / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            'Authenticate to view wallet details',
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
        ),
      );
    }
  }

  Widget _buildWalletBack(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: size.height / 4,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.grey.shade300,
      ),
      child: Center(
        child: Text(
          'Back Side - Wallet Details',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
