class CheckMobileResponseEntity {
  final int userLinkedDevices;
  final int primaryDevice;
  final String message;

  CheckMobileResponseEntity({
    required this.userLinkedDevices,
    required this.primaryDevice,
    required this.message,
  });
}
