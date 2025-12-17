import 'package:flutter/material.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/app_bar_widget.dart';
import 'package:kc_connect/core/widgets/bottom_nav_bar.dart';

class AlumniPage extends StatefulWidget {
  const AlumniPage({super.key});

  @override
  State<AlumniPage> createState() => _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(child: Text('Alumni Page', style: AppTextStyles.heading)),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
