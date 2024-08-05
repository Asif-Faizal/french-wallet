import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/wallet/get_wallet_details.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final GetWalletDetails getWalletDetails;

  WalletBloc({required this.getWalletDetails}) : super(WalletInitial()) {
    on<FetchWalletDetails>((event, emit) async {
      emit(WalletLoading());
      try {
        final wallet = await getWalletDetails();
        emit(WalletLoaded(
          balance: wallet.balance,
          cardNum: wallet.cardNum,
          cardId: wallet.cardId,
        ));
      } catch (e) {
        emit(WalletError(message: e.toString()));
      }
    });
  }
}
