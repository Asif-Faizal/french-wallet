import 'package:ewallet2/domain/signup/industry_sector_repo.dart';

import 'industry_type_entity.dart';

class GetIndustrySectors {
  final IndustrySectorRepository repository;

  GetIndustrySectors({required this.repository});

  Future<List<IndustrySector>> call() async {
    return await repository.getIndustrySectors();
  }
}
