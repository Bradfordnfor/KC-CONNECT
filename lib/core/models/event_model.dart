// lib/core/models/event_model.dart

class EventModel {
  final String id;
  final String title;
  final String description;
  final String
  type; // 'Workshop', 'Seminar', 'Competition', 'Networking', 'Social'
  final DateTime date;
  final String time;
  final String? host;
  final String? location;
  final String? imageUrl;
  final int? capacity;
  final int registeredCount;
  final bool isRegistered;
  final bool isFeatured;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.date,
    required this.time,
    this.host,
    this.location,
    this.imageUrl,
    this.capacity,
    this.registeredCount = 0,
    this.isRegistered = false,
    this.isFeatured = false,
  });

  // Getters for display
  String get displayDate => _formatDate(date);
  String get displayTime => time;
  String get subtitle => '$displayDate - $time';
  String get meta => host != null ? 'Host: $host' : 'KC Connect';
  String get displayType => type;
  bool get isPast => date.isBefore(DateTime.now());
  bool get isToday => _isToday(date);
  bool get isFull => capacity != null && registeredCount >= capacity!;
  int get daysToGo => date.difference(DateTime.now()).inDays;
  String get spotsLeft => capacity != null
      ? '${capacity! - registeredCount} spots left'
      : 'Open registration';

  // Format date for display
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    final day = date.day;
    final month = months[date.month - 1];
    final suffix = _getDaySuffix(day);

    return '$month $day$suffix';
  }

  // Get day suffix (st, nd, rd, th)
  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  // Check if date is today
  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // Copy with method
  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    String? type,
    DateTime? date,
    String? time,
    String? host,
    String? location,
    String? imageUrl,
    int? capacity,
    int? registeredCount,
    bool? isRegistered,
    bool? isFeatured,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      date: date ?? this.date,
      time: time ?? this.time,
      host: host ?? this.host,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      capacity: capacity ?? this.capacity,
      registeredCount: registeredCount ?? this.registeredCount,
      isRegistered: isRegistered ?? this.isRegistered,
      isFeatured: isFeatured ?? this.isFeatured,
    );
  }

  // Mock data factory
  factory EventModel.mock({
    String? id,
    String? title,
    String? type,
    int? daysFromNow,
  }) {
    final eventDate = DateTime.now().add(Duration(days: daysFromNow ?? 30));

    return EventModel(
      id: id ?? 'event_1',
      title: title ?? 'Talk: Cognitive Control',
      description:
          'A deep dive into cognitive control mechanisms and their applications in daily life. Learn practical strategies to improve focus, decision-making, and mental clarity.',
      type: type ?? 'Workshop',
      date: eventDate,
      time: '2:00 PM',
      host: 'Sir Caleb',
      location: 'KC Main Hall',
      imageUrl: 'assets/images/kc-connect_icon.png',
      capacity: 100,
      registeredCount: 45,
      isRegistered: false,
      isFeatured: daysFromNow != null && daysFromNow <= 30,
    );
  }

  // Create list of mock events
  static List<EventModel> mockList() {
    return [
      EventModel.mock(
        id: 'event_1',
        title: 'NATIONAL STEM QUEST',
        type: 'Competition',
        daysFromNow: 29,
      ),
      EventModel.mock(
        id: 'event_2',
        title: 'Tech Innovation Summit',
        type: 'Seminar',
        daysFromNow: 45,
      ),
      EventModel.mock(
        id: 'event_3',
        title: 'Science Fair 2025',
        type: 'Competition',
        daysFromNow: 60,
      ),
      EventModel.mock(
        id: 'event_4',
        title: 'Talk: Cognitive Control',
        type: 'Workshop',
        daysFromNow: 15,
      ),
      EventModel.mock(
        id: 'event_5',
        title: 'Career Development Workshop',
        type: 'Workshop',
        daysFromNow: 22,
      ),
      EventModel.mock(
        id: 'event_6',
        title: 'Alumni Networking Night',
        type: 'Networking',
        daysFromNow: 35,
      ),
      EventModel.mock(
        id: 'event_7',
        title: 'End of Year Social',
        type: 'Social',
        daysFromNow: 90,
      ),
      // Past event
      EventModel.mock(
        id: 'event_8',
        title: 'Mathematics Olympiad',
        type: 'Competition',
        daysFromNow: -10,
      ),
    ];
  }

  // Get upcoming events only
  static List<EventModel> upcomingEvents() {
    return mockList().where((event) => !event.isPast).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get featured events
  static List<EventModel> featuredEvents() {
    return mockList()
        .where((event) => event.isFeatured && !event.isPast)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // For Supabase integration (future)
  // Map<String, dynamic> toJson() {
  //   return {
  //     'id': id,
  //     'title': title,
  //     'description': description,
  //     'type': type,
  //     'date': date.toIso8601String(),
  //     'time': time,
  //     'host': host,
  //     'location': location,
  //     'image_url': imageUrl,
  //     'capacity': capacity,
  //     'registered_count': registeredCount,
  //     'is_registered': isRegistered,
  //     'is_featured': isFeatured,
  //   };
  // }

  // factory EventModel.fromJson(Map<String, dynamic> json) {
  //   return EventModel(
  //     id: json['id'] as String,
  //     title: json['title'] as String,
  //     description: json['description'] as String,
  //     type: json['type'] as String,
  //     date: DateTime.parse(json['date'] as String),
  //     time: json['time'] as String,
  //     host: json['host'] as String?,
  //     location: json['location'] as String?,
  //     imageUrl: json['image_url'] as String?,
  //     capacity: json['capacity'] as int?,
  //     registeredCount: json['registered_count'] as int? ?? 0,
  //     isRegistered: json['is_registered'] as bool? ?? false,
  //     isFeatured: json['is_featured'] as bool? ?? false,
  //   );
  // }
}
