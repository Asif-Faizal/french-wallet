import 'package:equatable/equatable.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final String balance;
  final String cardNum;
  final String cardId;

  const WalletLoaded(
      {required this.balance, required this.cardNum, required this.cardId});

  @override
  List<Object> get props => [balance, cardNum, cardId];
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object> get props => [message];
}
