import 'checkmobile_entity.dart';

abstract class LoginRepository {
  Future<CheckMobileResponseEntity> checkMobile(String mobile);
}
