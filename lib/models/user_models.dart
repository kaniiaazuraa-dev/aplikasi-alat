class UserModel {
  final String id;
  final String nama;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      nama: map['nama_lengkap'] ?? '-',
      email: map['email'] ?? '-',
      role: map['role'] ?? '-',
    );
  }
}
