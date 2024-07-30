import '../../domain/login/login_entity.dart';
import '../../data/login/login_repo.dart';

class LoginUseCase {
  final LoginRepository repository;

  LoginUseCase({required this.repository});

  Future<LoginEntity> execute(String mobile, String password) async {
    final response = await repository.login(mobile, password);
    return LoginEntity.fromResponse(response);
  }
}
