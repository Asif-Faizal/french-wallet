import '../../data/wallet/wallet_datasource.dart';
import '../../data/wallet/wallet_repo.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletDataSource walletDataSource;

  WalletRepositoryImpl(this.walletDataSource);

  @override
  Future<Map<String, dynamic>> getWalletDetails() {
    return walletDataSource.fetchWalletDetails();
  }
}
