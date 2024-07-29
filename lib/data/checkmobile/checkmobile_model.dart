import '../../domain/checkmobile/checkmobile_entity.dart';

class CheckMobileResponseModel {
  final int userLinkedDevices;
  final int primaryDevice;
  final String message;

  CheckMobileResponseModel({
    required this.userLinkedDevices,
    required this.primaryDevice,
    required this.message,
  });
  factory CheckMobileResponseModel.fromJson(Map<String, dynamic> json) {
    return CheckMobileResponseModel(
      userLinkedDevices: json['user_linked_devices'],
      primaryDevice: json['primary_device'],
      message: json['message'],
    );
  }
  factory CheckMobileResponseModel.fromEntity(
      CheckMobileResponseEntity entity) {
    return CheckMobileResponseModel(
      userLinkedDevices: entity.userLinkedDevices,
      primaryDevice: entity.primaryDevice,
      message: entity.message,
    );
  }
}
