import 'package:courall/pages/CourseDetailPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String description;
  final String tentang;
  final String category;
  final String region;
  final String imagePath;
  final double rating;

  const LessonCard({
    super.key,
    required this.title,
    required this.description,
    required this.tentang,
    required this.category,
    required this.region,
    required this.imagePath,
    required this.rating,
  });

  String _getYoutubeUrlForCourse(String title) {
    switch (title) {
      case 'Tari Berjenjang':
        return 'https://www.youtube.com/watch?v=7na4JY2IRP4';
      case 'Belajar Trigonometri with Kak Anwar':
        return 'https://www.youtube.com/watch?v=PUB0TaZ7bhA';
      case 'Intro to Coding with Pak Amir':
        return 'https://www.youtube.com/watch?v=rfscVS0vtbw';
      case 'Belajar Bahasa Abui with Ama Berto':
        return 'https://www.youtube.com/watch?v=IikynxoLpxA';
      case 'Masak Kapurung Khas Luwu':
        return 'https://www.youtube.com/watch?v=6F_ex2ybVQE';
      default:
        return 'https://www.youtube.com/watch?v=dQw4w9WgXcQ'; // fallback
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 360;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 330, maxHeight: 390),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFBE9E7), Color(0xFFFFF3E0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                imagePath,
                height: isSmallScreen ? 90 : 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: isSmallScreen ? 90 : 110,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 90),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: isSmallScreen ? 13 : 14.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11.5 : 12.5,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: $category\nRegion: $region',
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 11 : 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 3),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.poppins(
                              fontSize: isSmallScreen ? 11 : 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange[300],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseDetailPage(
                                title: title,
                                description: tentang,
                                youtubeUrl: _getYoutubeUrlForCourse(title),
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Learn',
                          style: GoogleFonts.poppins(
                            fontSize: isSmallScreen ? 11 : 12.5,
                            color: Colors.brown[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
