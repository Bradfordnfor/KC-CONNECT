// lib/core/models/resource_model.dart

class ResourceModel {
  final String id;
  final String title;
  final String category; // 'Ordinary Level', 'Advanced Level', 'Other Books'
  final String? subject;
  final String description;
  final String? fileUrl;
  final String? imageUrl;
  final int pages;
  final String uploadedBy;
  final String uploaderName;
  final DateTime uploadedDate;
  final int downloads;
  final bool isFavorite;

  ResourceModel({
    required this.id,
    required this.title,
    required this.category,
    this.subject,
    required this.description,
    this.fileUrl,
    this.imageUrl,
    this.pages = 0,
    required this.uploadedBy,
    required this.uploaderName,
    required this.uploadedDate,
    this.downloads = 0,
    this.isFavorite = false,
  });

  // Getters for display
  String get displayPages => pages > 0 ? '$pages pages' : 'Unknown pages';
  String get displayCategory => category;
  String get displayUploadedBy => 'By $uploaderName';
  String get formattedDate => _formatDate(uploadedDate);
  String get subtitle => '$displayPages • $uploaderName';
  String get meta => 'Uploaded: $formattedDate';

  // Check category type
  bool get isOrdinaryLevel => category == 'Ordinary Level';
  bool get isAdvancedLevel => category == 'Advanced Level';
  bool get isOtherBook => category == 'Other Books';

  // Format date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // Copy with method
  ResourceModel copyWith({
    String? id,
    String? title,
    String? category,
    String? subject,
    String? description,
    String? fileUrl,
    String? imageUrl,
    int? pages,
    String? uploadedBy,
    String? uploaderName,
    DateTime? uploadedDate,
    int? downloads,
    bool? isFavorite,
  }) {
    return ResourceModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      pages: pages ?? this.pages,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      downloads: downloads ?? this.downloads,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  // Mock data factory
  factory ResourceModel.mock({
    String? id,
    String? title,
    String? category,
    String? subject,
  }) {
    final cat = category ?? 'Ordinary Level';
    final subj = subject ?? 'Mathematics';

    return ResourceModel(
      id: id ?? 'resource_1',
      title: title ?? '$cat - Past Paper',
      category: cat,
      subject: subj,
      description:
          'Comprehensive study material for $subj covering all topics.',
      fileUrl: 'https://example.com/resource.pdf',
      imageUrl: 'assets/images/kc-connect_icon.png',
      pages: 45,
      uploadedBy: 'user_admin',
      uploaderName: 'Sir Bradford',
      uploadedDate: DateTime.now().subtract(const Duration(days: 15)),
      downloads: 234,
      isFavorite: false,
    );
  }

  // Create list of mock resources
  static List<ResourceModel> mockList({String? category}) {
    final List<ResourceModel> allResources = [
      // Ordinary Level
      ResourceModel.mock(
        id: 'ol_1',
        title: 'Mathematics Past Paper 2023',
        category: 'Ordinary Level',
        subject: 'Mathematics',
      ),
      ResourceModel.mock(
        id: 'ol_2',
        title: 'Physics Study Guide',
        category: 'Ordinary Level',
        subject: 'Physics',
      ),
      ResourceModel.mock(
        id: 'ol_3',
        title: 'Chemistry Revision Notes',
        category: 'Ordinary Level',
        subject: 'Chemistry',
      ),
      ResourceModel.mock(
        id: 'ol_4',
        title: 'English Literature Guide',
        category: 'Ordinary Level',
        subject: 'English',
      ),

      // Advanced Level
      ResourceModel.mock(
        id: 'al_1',
        title: 'Further Mathematics Paper',
        category: 'Advanced Level',
        subject: 'Mathematics',
      ),
      ResourceModel.mock(
        id: 'al_2',
        title: 'Advanced Physics Concepts',
        category: 'Advanced Level',
        subject: 'Physics',
      ),
      ResourceModel.mock(
        id: 'al_3',
        title: 'Organic Chemistry Notes',
        category: 'Advanced Level',
        subject: 'Chemistry',
      ),
      ResourceModel.mock(
        id: 'al_4',
        title: 'Computer Science Algorithms',
        category: 'Advanced Level',
        subject: 'Computer Science',
      ),

      // Other Books
      ResourceModel.mock(
        id: 'other_1',
        title: 'Cognitive Control',
        category: 'Other Books',
        subject: 'Self Help',
      ),
      ResourceModel.mock(
        id: 'other_2',
        title: 'Leadership Principles',
        category: 'Other Books',
        subject: 'Personal Development',
      ),
      ResourceModel.mock(
        id: 'other_3',
        title: 'Time Management Mastery',
        category: 'Other Books',
        subject: 'Productivity',
      ),
    ];

    // Filter by category if provided
    if (category != null) {
      return allResources.where((r) => r.category == category).toList();
    }

    return allResources;
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'category': category,
  //     'subject': subject,
  //     'description': description,
  //     'file_url': fileUrl,
  //     'image_url': imageUrl,
  //     'pages': pages,
  //     'uploaded_by': uploadedBy,
  //     'uploader_name': uploaderName,
  //     'uploaded_date': uploadedDate.toIso8601String(),
  //     'downloads': downloads,
  //     'is_favorite': isFavorite,
  //   };
  // }

  // factory ResourceModel.fromJson(Map<String, dynamic> json) {
  //   return ResourceModel(
  //     id: json['id'] as String,
  //     title: json['title'] as String,
  //     category: json['category'] as String,
  //     subject: json['subject'] as String?,
  //     description: json['description'] as String,
  //     fileUrl: json['file_url'] as String?,
  //     imageUrl: json['image_url'] as String?,
  //     pages: json['pages'] as int? ?? 0,
  //     uploadedBy: json['uploaded_by'] as String,
  //     uploaderName: json['uploader_name'] as String,
  //     uploadedDate: DateTime.parse(json['uploaded_date'] as String),
  //     downloads: json['downloads'] as int? ?? 0,
  //     isFavorite: json['is_favorite'] as bool? ?? false,
  //   );
  // }
}
