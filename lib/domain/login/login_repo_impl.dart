import '../../data/login/login_datasource.dart';
import '../../data/login/login_repo.dart';
import '../../data/login/login_model.dart';

class LoginRepositoryImpl implements LoginRepository {
  final LoginDataSource dataSource;

  LoginRepositoryImpl({required this.dataSource});

  @override
  Future<LoginResponse> login(String mobile, String password) async {
    return await dataSource.login(mobile, password);
  }
}
