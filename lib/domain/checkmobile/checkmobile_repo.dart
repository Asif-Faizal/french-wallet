import 'checkmobile_entity.dart';

abstract class CheckMobileRepository {
  Future<CheckMobileResponseEntity> checkMobile(String mobile);
}
