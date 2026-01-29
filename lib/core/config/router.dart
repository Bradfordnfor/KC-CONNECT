// lib/core/config/router.dart
import 'package:flutter/material.dart';
import 'package:kc_connect/features/home/presentation/screens/home_page.dart';
import 'package:kc_connect/features/chat/presentation/screens/learn_page.dart';
import 'package:kc_connect/features/resources/presentation/screens/resources_page.dart';
import 'package:kc_connect/features/events/presentation/screens/events_page.dart';
import 'package:kc_connect/features/profile/presentation/screens/profile_page.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_page.dart';
import 'package:kc_connect/features/notifications/presentation/screens/news_page.dart';

class AppRoutes {
  static const String home = '/';
  static const String chat = '/chat';
  static const String resources = '/resources';
  static const String events = '/events';
  static const String profile = '/profile';
  static const String alumni = '/alumni';
  static const String news = '/news';
  static const String store = '/store';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case chat:
        return MaterialPageRoute(builder: (_) => const LearnPage());
      case resources:
        return MaterialPageRoute(builder: (_) => const ResourcesPage());
      case events:
        return MaterialPageRoute(builder: (_) => const EventsPage());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfilePage());
      case alumni:
        return MaterialPageRoute(builder: (_) => const AlumniPage());
      case news:
        return MaterialPageRoute(builder: (_) => const NewsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
