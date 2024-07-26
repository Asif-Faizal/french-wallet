class BusinessTypeModel {
  final String businessType;

  BusinessTypeModel({required this.businessType});

  factory BusinessTypeModel.fromJson(Map<String, dynamic> json) {
    return BusinessTypeModel(
      businessType: json['business_type'],
    );
  }
}
