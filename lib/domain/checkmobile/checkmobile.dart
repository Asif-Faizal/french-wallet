import 'package:ewallet2/domain/checkmobile/checkmobile_repo.dart';
import 'package:ewallet2/domain/checkmobile/checkmobile_entity.dart';

import '../../data/checkmobile/checkmobile_model.dart';

class CheckMobileUseCase {
  final CheckMobileRepository checkMobileRepository;

  CheckMobileUseCase({required this.checkMobileRepository});

  Future<CheckMobileResponseModel> call(String mobile) async {
    final CheckMobileResponseEntity entity =
        await checkMobileRepository.checkMobile(mobile);
    return CheckMobileResponseModel.fromEntity(entity);
  }
}
