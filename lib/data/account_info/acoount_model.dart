// account_model.dart
class UserProfileResponse {
  final String status;
  final UserProfile data;

  UserProfileResponse({required this.status, required this.data});

  factory UserProfileResponse.fromJson(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'],
      data: UserProfile.fromJson(json['data']),
    );
  }
}

class UserProfile {
  final String fullName;
  final String mobileNo;
  final String customerId;
  final String approved;
  final String nationality;

  UserProfile({
    required this.fullName,
    required this.mobileNo,
    required this.customerId,
    required this.approved,
    required this.nationality,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      fullName: json['full_name'],
      mobileNo: json['mobile_no'],
      customerId: json['customer_id'],
      approved: json['approved'],
      nationality: json['nationality'],
    );
  }
}
