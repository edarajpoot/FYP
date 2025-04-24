class UserModel {
  final String id;
  final String name;
  final String email;
  final String phoneNo;
  final bool emergencyMode;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNo,
    required this.emergencyMode,
  });

  // Firebase ke document se UserModel banane ka method
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phoneNo: map['phoneNo'] ?? '',
      emergencyMode: map['emergencyMode'] ?? false,
    );
  }

   // Method to create a copy of UserModel with updated fields
  UserModel copyWith({String? name, String? email, String? phoneNo, bool? emergencyMode}) {
    return UserModel(
      id: this.id,  // Keep id the same
      name: name ?? this.name,  // Use the new name if provided, else keep the old one
      email: email ?? this.email,
      phoneNo: phoneNo ?? this.phoneNo,
      emergencyMode: emergencyMode ?? this.emergencyMode,
    );
  }
}

