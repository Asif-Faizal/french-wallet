import '../../../domain/signup/industry_sector/industry_sector_repo.dart';
import '../../../domain/signup/industry_sector/industry_type_entity.dart';
import 'industry_sector_datasource.dart';

class IndustrySectorRepositoryImpl implements IndustrySectorRepository {
  final IndustrySectorDataSource dataSource;

  IndustrySectorRepositoryImpl({required this.dataSource});

  @override
  Future<List<IndustrySector>> getIndustrySectors() async {
    final industrySectors = await dataSource.fetchIndustrySectors();
    return industrySectors
        .map((model) => IndustrySector(industrySector: model.industrySector))
        .toList();
  }
}
