import '../../data/wallet/wallet_repo.dart';
import 'wallet_entity.dart';

class GetWalletDetails {
  final WalletRepository repository;

  GetWalletDetails(this.repository);

  Future<Wallet> call() async {
    final walletDetails = await repository.getWalletDetails();
    return Wallet(
      balance: walletDetails['balance'],
      cardNum: walletDetails['card_num'],
      cardId: walletDetails['card_udid'],
    );
  }
}
