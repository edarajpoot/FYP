class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNo;
  final bool emergencyMode;
  final String password;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.emergencyMode,
     this.password = "", 
  });

  // Firebase ke document se UserModel banane ka method
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
      emergencyMode: map['emergencyMode'] ?? false,
      password: map['password'] ?? "",
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNo: json['phoneNo'] ?? '',
      emergencyMode: json['emergencyMode'] ?? false,
    );
  }

}

