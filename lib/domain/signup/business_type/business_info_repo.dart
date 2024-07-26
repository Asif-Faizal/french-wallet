import 'business_type_entity.dart';

abstract class BusinessInfoRepository {
  Future<List<BusinessType>> getBusinessTypes();
}
