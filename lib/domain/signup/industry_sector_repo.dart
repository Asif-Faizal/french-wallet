import 'industry_type_entity.dart';

abstract class IndustrySectorRepository {
  Future<List<IndustrySector>> getIndustrySectors();
}
