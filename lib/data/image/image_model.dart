class ImageModel {
  final String imageId;
  final String message;
  final String status;
  final int statusCode;

  ImageModel({
    required this.imageId,
    required this.message,
    required this.status,
    required this.statusCode,
  });

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      imageId: json['image_id'],
      message: json['message'],
      status: json['status'],
      statusCode: json['status_code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'image_id': imageId,
      'message': message,
      'status': status,
      'status_code': statusCode,
    };
  }
}
