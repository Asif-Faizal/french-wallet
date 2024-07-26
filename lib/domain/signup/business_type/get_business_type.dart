import 'business_info_repo.dart';
import 'business_type_entity.dart';

class GetBusinessTypes {
  final BusinessInfoRepository repository;

  GetBusinessTypes({required this.repository});

  Future<List<BusinessType>> call() async {
    return await repository.getBusinessTypes();
  }
}
