class IndustrySectorModel {
  final String industrySector;

  IndustrySectorModel({required this.industrySector});

  factory IndustrySectorModel.fromJson(Map<String, dynamic> json) {
    return IndustrySectorModel(
      industrySector: json['industry_type'],
    );
  }
}
