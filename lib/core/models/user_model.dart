// lib/core/models/user_model.dart

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? imageUrl;
  final String role; // 'student', 'alumni', 'Staff','admin'
  final String? institution;
  final String? level; // 'Ordinary Level', 'Advanced Level'
  final String? classYear; // e.g., 'Class of 2023'
  final DateTime? joinedDate;
  final bool isVerified;
  final String? bio;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.imageUrl,
    this.role = 'student',
    this.institution,
    this.level,
    this.classYear,
    this.joinedDate,
    this.isVerified = false,
    this.bio,
  });

  // Getters for display
  String get displayName => name;
  String get displayRole => _formatRole(role);
  String get displayLevel => level ?? 'Not specified';
  bool get isStudent => role.toLowerCase() == 'student';
  bool get isAlumni => role.toLowerCase() == 'alumni';
  bool get isAdmin => role.toLowerCase() == 'admin';

  // Format role for display
  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'student':
        return 'Student';
      case 'alumni':
        return 'Alumni';
      case 'admin':
        return 'Administrator';
      default:
        return role;
    }
  }

  // Copy with method for updates
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    String? role,
    String? institution,
    String? level,
    String? classYear,
    DateTime? joinedDate,
    bool? isVerified,
    String? bio,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      imageUrl: imageUrl ?? this.imageUrl,
      role: role ?? this.role,
      institution: institution ?? this.institution,
      level: level ?? this.level,
      classYear: classYear ?? this.classYear,
      joinedDate: joinedDate ?? this.joinedDate,
      isVerified: isVerified ?? this.isVerified,
      bio: bio ?? this.bio,
    );
  }

  // Mock data factory
  factory UserModel.mock({
    String? id,
    String? name,
    String? email,
    String? role,
  }) {
    return UserModel(
      id: id ?? 'user_1',
      name: name ?? 'John Kamdem',
      email: email ?? 'john.kamdem@kcconnect.com',
      phone: '+237 123 456 789',
      imageUrl: 'assets/images/kc-connect_icon.png',
      role: role ?? 'student',
      institution: 'Knowledge College',
      level: 'Advanced Level',
      classYear: 'Class of 2024',
      joinedDate: DateTime(2024, 1, 15),
      isVerified: true,
      bio:
          'Passionate about technology and innovation. Future software engineer.',
    );
  }

  // Create list of mock users
  static List<UserModel> mockList() {
    return [
      UserModel.mock(
        id: 'user_1',
        name: 'John Kamdem',
        email: 'john@kcconnect.com',
        role: 'student',
      ),
      UserModel.mock(
        id: 'user_2',
        name: 'Marie Ngono',
        email: 'marie@kcconnect.com',
        role: 'student',
      ),
      UserModel.mock(
        id: 'user_3',
        name: 'Bradford Toh',
        email: 'bradford@kcconnect.com',
        role: 'alumni',
      ),
    ];
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'email': email,
  //     'phone': phone,
  //     'image_url': imageUrl,
  //     'role': role,
  //     'institution': institution,
  //     'level': level,
  //     'class_year': classYear,
  //     'joined_date': joinedDate?.toIso8601String(),
  //     'is_verified': isVerified,
  //     'bio': bio,
  //   };
  // }

  // factory UserModel.fromJson(Map<String, dynamic> json) {
  //   return UserModel(
  //     id: json['id'] as String,
  //     name: json['name'] as String,
  //     email: json['email'] as String,
  //     phone: json['phone'] as String?,
  //     imageUrl: json['image_url'] as String?,
  //     role: json['role'] as String? ?? 'student',
  //     institution: json['institution'] as String?,
  //     level: json['level'] as String?,
  //     classYear: json['class_year'] as String?,
  //     joinedDate: json['joined_date'] != null
  //         ? DateTime.parse(json['joined_date'] as String)
  //         : null,
  //     isVerified: json['is_verified'] as bool? ?? false,
  //     bio: json['bio'] as String?,
  //   );
  // }
}
