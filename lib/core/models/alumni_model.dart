// lib/core/models/alumni_model.dart

class AlumniModel {
  final String id;
  final String name;
  final String role;
  final String school;
  final String classInfo;
  final String? imageUrl;
  final String bio;
  final String career;
  final String vision;
  final bool isAvailableForMentorship;
  final String? email;
  final String? linkedin;
  final List<String> expertise;
  final int menteeCount;

  AlumniModel({
    required this.id,
    required this.name,
    required this.role,
    required this.school,
    required this.classInfo,
    this.imageUrl,
    required this.bio,
    required this.career,
    required this.vision,
    this.isAvailableForMentorship = true,
    this.email,
    this.linkedin,
    this.expertise = const [],
    this.menteeCount = 0,
  });

  // Getters for display
  String get displayName => name;
  String get displayRole => role;
  String get displaySchool => school;
  String get displayClass => classInfo;
  String get mentorshipStatus =>
      isAvailableForMentorship ? 'Available for mentorship' : 'Not available';
  String get menteeCountDisplay =>
      '$menteeCount mentee${menteeCount == 1 ? '' : 's'}';

  // Extract class year from classInfo (e.g., "Class of 2021" -> 2021)
  int? get classYear {
    final match = RegExp(r'(\d{4})').firstMatch(classInfo);
    if (match != null) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }

  // Years since graduation
  int? get yearsSinceGraduation {
    if (classYear != null) {
      return DateTime.now().year - classYear!;
    }
    return null;
  }

  // Copy with method
  AlumniModel copyWith({
    String? id,
    String? name,
    String? role,
    String? school,
    String? classInfo,
    String? imageUrl,
    String? bio,
    String? career,
    String? vision,
    bool? isAvailableForMentorship,
    String? email,
    String? linkedin,
    List<String>? expertise,
    int? menteeCount,
  }) {
    return AlumniModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      school: school ?? this.school,
      classInfo: classInfo ?? this.classInfo,
      imageUrl: imageUrl ?? this.imageUrl,
      bio: bio ?? this.bio,
      career: career ?? this.career,
      vision: vision ?? this.vision,
      isAvailableForMentorship:
          isAvailableForMentorship ?? this.isAvailableForMentorship,
      email: email ?? this.email,
      linkedin: linkedin ?? this.linkedin,
      expertise: expertise ?? this.expertise,
      menteeCount: menteeCount ?? this.menteeCount,
    );
  }

  // Convert to map for backward compatibility with existing code
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'name': name,
      'role': role,
      'school': school,
      'classInfo': classInfo,
      'bio': bio,
      'career': career,
      'vision': vision,
    };
  }

  // Mock data factory
  factory AlumniModel.mock({
    String? id,
    String? name,
    String? role,
    String? classYear,
  }) {
    return AlumniModel(
      id: id ?? 'alumni_1',
      name: name ?? 'Eng NYAKE TUDORA',
      role: role ?? 'Mechanical Engineering grad',
      school: 'U.B(C.O.T), CMR',
      classInfo: classYear ?? 'Class of 2021',
      imageUrl: 'assets/images/kc-connect_icon.png',
      bio:
          'Passionate mechanical engineer with expertise in automotive systems and renewable energy solutions. Former head of the KC Engineering Club.',
      career:
          'Currently working at Toyota Cameroon as Senior Mechanical Engineer, specializing in vehicle design and testing. Previously interned at Total Energies.',
      vision:
          'To revolutionize the automotive industry in Africa through sustainable engineering practices and mentoring the next generation of African engineers.',
      isAvailableForMentorship: true,
      email: 'nyake.tudora@example.com',
      linkedin: 'linkedin.com/in/nyaketudora',
      expertise: [
        'Mechanical Engineering',
        'Automotive Design',
        'CAD',
        'Project Management',
      ],
      menteeCount: 5,
    );
  }

  // Create list of mock alumni
  static List<AlumniModel> mockList() {
    return [
      AlumniModel.mock(
        id: 'alumni_1',
        name: 'Eng NYAKE TUDORA',
        role: 'Mechanical Engineering grad',
        classYear: 'Class of 2021',
      ),
      AlumniModel.mock(
        id: 'alumni_2',
        name: 'NKENGAFOUA CALEB',
        role: 'Computer Engineering Student',
        classYear: 'Class of 2023',
      ),
      AlumniModel.mock(
        id: 'alumni_3',
        name: 'AYUK SANDRINE',
        role: 'Mastercard Foundation Scholar',
        classYear: 'Class of 2023',
      ),
      AlumniModel.mock(
        id: 'alumni_4',
        name: 'BEZIA PRECIOUS',
        role: 'Full-Stack Developer',
        classYear: 'Class of 2023',
      ),
      AlumniModel(
        id: 'alumni_5',
        name: 'MBAH COLLINS',
        role: 'Data Scientist',
        school: 'Carnegie Mellon Africa',
        classInfo: 'Class of 2020',
        imageUrl: 'assets/images/kc-connect_icon.png',
        bio:
            'Data scientist passionate about using machine learning to solve African problems. Former KC Math Olympiad champion.',
        career:
            'Machine Learning Engineer at Jumia, working on recommendation systems and fraud detection. PhD candidate at CMU Africa.',
        vision:
            'To build AI solutions that improve lives across Africa, starting with agriculture and healthcare.',
        isAvailableForMentorship: true,
        email: 'mbah.collins@example.com',
        linkedin: 'linkedin.com/in/mbahcollins',
        expertise: ['Machine Learning', 'Python', 'Data Science', 'AI'],
        menteeCount: 8,
      ),
      AlumniModel(
        id: 'alumni_6',
        name: 'TABI GRACE',
        role: 'Medical Doctor',
        school: 'University of Yaoundé I',
        classInfo: 'Class of 2019',
        imageUrl: 'assets/images/kc-connect_icon.png',
        bio:
            'Pediatrician dedicated to improving child healthcare in rural Cameroon. KC Science Club president.',
        career:
            'Pediatrician at Yaoundé Central Hospital, founder of Mobile Health Initiative reaching 50+ villages.',
        vision:
            'To ensure every child in Cameroon has access to quality healthcare, regardless of their location.',
        isAvailableForMentorship: true,
        expertise: [
          'Medicine',
          'Pediatrics',
          'Public Health',
          'Healthcare Management',
        ],
        menteeCount: 12,
      ),
      AlumniModel(
        id: 'alumni_7',
        name: 'FONGOH BRANDON',
        role: 'Civil Engineer',
        school: 'ENSP Yaoundé',
        classInfo: 'Class of 2020',
        imageUrl: 'assets/images/kc-connect_icon.png',
        bio:
            'Infrastructure engineer working on sustainable urban development projects across Central Africa.',
        career:
            'Project Manager at Chinese Roads and Bridge Corporation, overseeing major highway construction projects.',
        vision:
            'To transform African infrastructure through innovative and sustainable engineering solutions.',
        isAvailableForMentorship: false, // Not available
        expertise: [
          'Civil Engineering',
          'Project Management',
          'Urban Planning',
        ],
        menteeCount: 3,
      ),
    ];
  }

  // Filter by availability
  static List<AlumniModel> availableForMentorship() {
    return mockList()
        .where((alumni) => alumni.isAvailableForMentorship)
        .toList();
  }

  // Filter by class year
  static List<AlumniModel> byClassYear(String year) {
    return mockList()
        .where((alumni) => alumni.classInfo.contains(year))
        .toList();
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'name': name,
  //     'role': role,
  //     'school': school,
  //     'class_info': classInfo,
  //     'image_url': imageUrl,
  //     'bio': bio,
  //     'career': career,
  //     'vision': vision,
  //     'is_available_for_mentorship': isAvailableForMentorship,
  //     'email': email,
  //     'linkedin': linkedin,
  //     'expertise': expertise,
  //     'mentee_count': menteeCount,
  //   };
  // }

  // factory AlumniModel.fromJson(Map<String, dynamic> json) {
  //   return AlumniModel(
  //     id: json['id'] as String,
  //     name: json['name'] as String,
  //     role: json['role'] as String,
  //     school: json['school'] as String,
  //     classInfo: json['class_info'] as String,
  //     imageUrl: json['image_url'] as String?,
  //     bio: json['bio'] as String,
  //     career: json['career'] as String,
  //     vision: json['vision'] as String,
  //     isAvailableForMentorship: json['is_available_for_mentorship'] as bool? ?? true,
  //     email: json['email'] as String?,
  //     linkedin: json['linkedin'] as String?,
  //     expertise: (json['expertise'] as List<dynamic>?)?.cast<String>() ?? [],
  //     menteeCount: json['mentee_count'] as int? ?? 0,
  //   );
  // }
}
