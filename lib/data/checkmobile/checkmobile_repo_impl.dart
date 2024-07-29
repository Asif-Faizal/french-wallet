import '../../domain/checkmobile/checkmobile_entity.dart';
import '../../domain/checkmobile/checkmobile_repo.dart';
import 'checkmobile_datasource.dart';

class CheckMobileRepositoryImpl implements CheckMobileRepository {
  final CheckMobileDataSource dataSource;

  CheckMobileRepositoryImpl({required this.dataSource});

  @override
  Future<CheckMobileResponseEntity> checkMobile(String mobile) async {
    final response = await dataSource.checkMobile(mobile);
    return CheckMobileResponseEntity(
      userLinkedDevices: response.userLinkedDevices,
      primaryDevice: response.primaryDevice,
      message: response.message,
    );
  }
}
