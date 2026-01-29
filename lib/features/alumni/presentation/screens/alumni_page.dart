// lib/features/alumni/presentation/screens/alumni_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kc_connect/core/theme/app_colors.dart';
import 'package:kc_connect/core/theme/app_text_styles.dart';
import 'package:kc_connect/core/widgets/carousel_widget.dart';
import 'package:kc_connect/core/widgets/cards/alumni_card.dart';
import 'package:kc_connect/features/alumni/presentation/screens/alumni_details_page.dart';

class AlumniPage extends StatefulWidget {
  const AlumniPage({super.key});

  @override
  State<AlumniPage> createState() => _AlumniPageState();
}

class _AlumniPageState extends State<AlumniPage> {
  final TextEditingController _searchController = TextEditingController();

  // Mock data - replace with real data from Supabase later
  final List<Map<String, dynamic>> alumniList = [
    {
      'id': '1',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'name': 'Eng NYAKE TUDORA',
      'role': 'Mechanical Engineering grad',
      'school': 'U.B(C.O.T), CMR',
      'classInfo': 'Class of 2021',
      'bio':
          'Passionate mechanical engineer with expertise in automotive systems...',
      'career': 'Currently working at Toyota as Senior Engineer...',
      'vision': 'To revolutionize automotive industry in Africa...',
    },
    {
      'id': '2',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'name': 'NKENGAFOUA CALEB',
      'role': 'Computer Engineering Student',
      'school': 'Landmark, CMR',
      'classInfo': 'Class of 2023',
      'bio':
          'Software engineer passionate about building scalable applications...',
      'career': 'Full-Stack Developer at INOFIXZ...',
      'vision': 'To empower young Africans through technology...',
    },
    {
      'id': '3',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'name': 'AYUK SANDRINE',
      'role': 'Mastercard Foundation Student',
      'school': 'ALU, Rwanda',
      'classInfo': 'Class of 2023',
      'bio': 'Aspiring entrepreneur focused on fintech solutions...',
      'career': 'Product Manager at fintech startup...',
      'vision': 'To create inclusive financial solutions for Africa...',
    },
    {
      'id': '4',
      'imageUrl': 'assets/images/kc-connect_icon.png',
      'name': 'BEZIA PRECIOUS',
      'role': 'Computer Engineering Student',
      'school': 'U.B(F.E.T), CMR',
      'classInfo': 'Class of 2023',
      'bio':
          'I\'m a software engineer passionate about building scalable web applications that make learning and collaboration easier. During my time at KC, I was part of the ICT Club and helped launch the first digital noticeboard for the campus. I believe in continuous learning and sharing knowledge with the next generation of tech leaders.',
      'career':
          'Currently a Full-Stack Developer at INOFIXZ, where I lead a small team focused on building online learning platforms for African universities. My career journey began with freelance web projects before joining a startup that connected students to digital mentors.',
      'vision':
          'To empower 10,000 young Africans through technology-driven education and mentorship by 2030. I aim to create opportunities for students from underserved communities to explore software development, innovation, and entrepreneurship.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBannerCarousel(),
                    _buildListingsHeaderWithSearch(),
                    const SizedBox(height: 16),
                    _buildAlumniList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBannerCarousel() {
    return CarouselWidget(
      margin: EdgeInsets.all(16),
      height: 155,
      autoPlay: false,
      showIndicators: false,
      items: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.gradientColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Text(
                'FIND A MENTOR',
                style: AppTextStyles.subHeading.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Row(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildIconBadge(Icons.star, 1),
                      const SizedBox(height: 10),
                      _buildIconBadge(Icons.star, 2),
                    ],
                  ),
                  const SizedBox(width: 16),
                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Interact with other KCians around the globe',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 25),
                        Text(
                          'Get rewarded for global impact and consistency',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconBadge(IconData icon, int number) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(icon, color: AppColors.white, size: 18),
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                color: AppColors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingsHeaderWithSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Listings icon and text on the left
          const Icon(Icons.tune, color: AppColors.blue, size: 24),
          const SizedBox(width: 8),
          Text(
            'Listings',
            style: AppTextStyles.subHeading.copyWith(
              color: AppColors.blue,
              fontSize: 20,
            ),
          ),

          const SizedBox(width: 30),

          // Search bar on the right
          Expanded(
            child: Container(
              height: 35,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    // Filter alumni list
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: AppTextStyles.body.copyWith(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  isDense: true,
                ),
                style: AppTextStyles.body.copyWith(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlumniList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: alumniList.length,
      itemBuilder: (context, index) {
        final alumni = alumniList[index];
        return AlumniCard(
          imageUrl: alumni['imageUrl'],
          name: alumni['name'],
          role: alumni['role'],
          school: alumni['school'],
          classInfo: alumni['classInfo'],
          onTap: () {
            Get.to(
              () => AlumniDetailPage(alumniData: alumni),
              transition: Transition.rightToLeft,
            );
          },
        );
      },
    );
  }
}
