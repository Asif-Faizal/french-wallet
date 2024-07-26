import '../../../domain/signup/business_type/business_info_repo.dart';
import '../../../domain/signup/business_type/business_type_entity.dart';
import 'business_info_datasource.dart';

class BusinessInfoRepositoryImpl implements BusinessInfoRepository {
  final BusinessInfoDataSource dataSource;

  BusinessInfoRepositoryImpl({required this.dataSource});

  @override
  Future<List<BusinessType>> getBusinessTypes() async {
    final businessTypes = await dataSource.fetchBusinessTypes();
    return businessTypes
        .map((model) => BusinessType(businessType: model.businessType))
        .toList();
  }
}
