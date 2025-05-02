import 'dart:ui';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs; // Import carousel_slider package
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuRevisedState();
}

// main_menu.dart — sekitar line 20

Future<void> openCommunication(String type, String target) async {
  String url;
  switch (type) {
    case 'email':
      url = 'mailto:$target'
          '?subject=${Uri.encodeComponent("Bantuan CourseApp")}'
          '&body=${Uri.encodeComponent("Halo CourseApp,\nsaya butuh bantuan…")}';
      break;
    case 'whatsapp':
      final phone = target.replaceAll(RegExp(r'[^0-9]'), '');
      url =
          'https://wa.me/$phone?text=${Uri.encodeComponent("Halo CourseApp, saya butuh bantuan.")}';
      break;
    case 'line':
      final user = target.startsWith('@') ? target.substring(1) : target;
      url = 'https://line.me/R/ti/p/$user';
      break;
    default:
      return;
  }

  final uri = Uri.parse(url);

  // Coba external intent dulu
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  // Fallback: In-App WebView (jika external intent gagal)
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.inAppWebView);
    return;
  }

  // Kalau masih gagal: beri feedback
  throw 'Tidak dapat membuka $url';
}

class CustomModal {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget body,
    double maxHeightFactor = 0.8,
  }) {
    return showGeneralDialog<T>(
      context: context,
      barrierLabel: 'Modal',
      barrierDismissible: true,
      barrierColor: Colors.black54,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Center(
          child: FractionallySizedBox(
            widthFactor: 0.9,
            heightFactor: maxHeightFactor,
            child: _ModalContent(title: title, body: body),
          ),
        ),
      ),
      transitionBuilder: (_, anim, __, child) {
        final curve = Curves.easeOutBack.transform(anim.value);
        return Transform.scale(
          scale: curve,
          child: Opacity(opacity: anim.value, child: child),
        );
      },
    );
  }
}

class _ModalContent extends StatelessWidget {
  final String title;
  final Widget body;
  const _ModalContent({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.hardEdge,
      color: Colors.white,
      elevation: 24,
      child: Column(
        children: [
          // HEADER
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFFB74D), Color(0xFF8D6E63)],
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(title,
                      style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // BODY
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: body,
            ),
          ),
          // FOOTER
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5D4037),
                  shape: StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: 14)),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Tutup',
                  style: GoogleFonts.poppins(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}


class _MainMenuRevisedState extends State<MainMenu> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final cs.CarouselSliderController _carouselController = cs.CarouselSliderController(); // Carousel controller
  int _currentCarouselPage = 0; // Track carousel page index
  int _currentTabIndex = 0;
  // Tambahkan variabel state
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Pilih instance yang valid dari daftar resmi
  final String _invidiousInstance = 'https://id.420129.xyz'; // Instance Jerman dengan CORS & API aktif

  // --- Batik-Inspired Color Palette (Refined) ---
  static const Color primaryBrown = Color(0xFF8D6E63); // Brown 400
  static const Color secondaryBrown = Color(0xFF5D4037); // Brown 700
  static const Color accentBrown = Color(0xFFBCAAA4); // Brown 200
  static const Color backgroundNeutral = Color(0xFFF8F8F8); // Slightly warmer Grey
  static const Color highlightOrange = Color(0xFFFFB74D); // Orange 300
  static const Color darkerhighlightOrange = Color.fromARGB(200, 255, 184, 77); // Orange 300

  static const Color textDarkBrown = Color(0xFF3E2723); // Brown 900
  static const Color textLight = Colors.white;
  static const Color textMedium = Color(0xFF757575); // Grey 600
  static const Color iconColorInactive = Color(0xFFAC8F84); // Lighter brown
  static const Color successGreen = Color(0xFF66BB6A); // Green 400 for success/validation
  static const Color errorRed = Color(0xFFE57373); // Red 300 for errors/logout

  // Carousel images (Expanded to 7 items)
  final List<String> carouselImages = [
    'https://images.unsplash.com/photo-1555066931-4365d14bab8c?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', // Programming
    'https://images.unsplash.com/photo-1522542550221-31fd19575a2d?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', // Design
    'https://images.unsplash.com/photo-1556761175-b413da4baf72?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1374&q=80', // Business
    'https://images.unsplash.com/photo-1491438590914-bc09fcaaf77a?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', // Marketing
    'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1064&q=80', // Photography
    'https://images.unsplash.com/photo-1534337840917-1b61585a68a6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80', // Self-Improvement
    'https://images.unsplash.com/photo-1605379399642-870262d3d051?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1206&q=80', // Data Science
  ];

  // Categories (Added one more)
  final List<Map<String, dynamic>> categories = [
    {'name': 'Pemrograman', 'icon': Icons.code_rounded},
    {'name': 'Membatik', 'icon': Icons.palette_outlined},
    {'name': 'Berdagang', 'icon': Icons.business_center_outlined},
    {'name': 'Pengembangan Diri', 'icon': Icons.self_improvement_outlined},
    {'name': 'Sains Data', 'icon': Icons.analytics_outlined}, // New category
    {'name': 'Segera Datang', 'icon': Icons.upcoming},
  ];

  // Search recommendations (Expanded)
  final List<String> searchRecommendations = [
    'Cara set up Flutter dan Firebase',
    'Gemini AI',
    'Fasilkom UI', // Updated year
    'Membuat Batik',
    'Courall', // More specific
    'Fermat Little Theorem', // More specific
    'Multivariable Calculus',
    'Analisis Data dengan Python', // More specific
    'Machine Learning Dasar',
    'Konsep Pasar',
  ];

  // --- Batik Pattern Assets (Refined) ---
  final String batikPatternOverlay = 'https://www.transparenttextures.com/patterns/batthern.png';
  final String batikHeaderBackground = 'https://img.freepik.com/free-vector/modern-geometric-batik-pattern-background_110029-83.jpg?w=996&t=st=1688887731~exp=1688888331~hmac=b5e7792c90b04a87d8110ebf668793d3f9b627a4971f241cc93f31937f066f8f'; // Alternative Batik Background
  final String infoBackground = 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1170&q=80'; // Background for Info Tab


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange); // Attach the specific listener
    // No need for PageController if using carousel_slider
    // _startAutoScroll is handled by carousel_slider options
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange); // Remove specific listener
    _tabController.dispose();
    // _pageController.dispose(); // Removed
    super.dispose();
  }

  // Tab change handler remains mostly the same
  void _handleTabChange() {
     if (_tabController.indexIsChanging) {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
     } else if (_currentTabIndex != _tabController.index) {
       setState(() {
        _currentTabIndex = _tabController.index;
       });
     }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundNeutral,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: IndexedStack(
           index: _currentTabIndex,
           children: [
              _buildHomeTab(),
              _buildSearchTab(),
              _buildInfoTab(),
              _buildSettingsTab(),
           ],
         ),
      ),
      bottomNavigationBar: _buildFloatingBottomNavigation(),
    );
  }

  // --- Tab Builders ---

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        // **Requirement 1: Redesigned Home Header**
        SliverAppBar(
          expandedHeight: 77.0, // Increased height for more design space
          floating: true, // Make it float for better access on scroll up
          pinned: true, // Keep it pinned at the top
          snap: true, // Snap effect when floating
          backgroundColor: secondaryBrown,
          elevation: 8.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 9, right: 60), // Adjusted padding
            title: RichText( // Use RichText for potential multi-line or styled text
               text: TextSpan(
                    style: GoogleFonts.playfairDisplay( // Elegant serif font
                       textStyle: const TextStyle(
                          color: textLight,
                          fontSize: 17, // Slightly smaller to fit potentially longer text
                          fontWeight: FontWeight.w700,
                          shadows: [ // Add subtle shadow for readability
                              Shadow(offset: Offset(0, 1), blurRadius: 3, color: Colors.black54),
                          ]
                       ),
                    ),
                  children: const [
                     TextSpan(text: 'Selamat Datang,\n'), // Line break
                     TextSpan(text: 'Pembelajar Hebat!', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), // Second line, bolder
                  ]
               ),
                overflow: TextOverflow.ellipsis, // Handle overflow
                maxLines: 2,
            ),
            background: Stack( // Use Stack for layering background elements
              fit: StackFit.expand,
              children: [
                // Base Gradient
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        primaryBrown.withOpacity(0.9),
                        secondaryBrown.withOpacity(1.0),
                      ],
                    ),
                  ),
                ),
                // Batik Pattern Overlay
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(batikHeaderBackground),
                      fit: BoxFit.cover,
                      opacity: 0.1, // Make pattern very subtle
                      colorFilter: ColorFilter.mode(
                          secondaryBrown.withOpacity(0.5), BlendMode.darken),
                    ),
                  ),
                ),
                // Bottom Shadow Gradient for Text Readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0), // Transparent top
                        Colors.black.withOpacity(0.5), // Darker bottom
                      ],
                      stops: const [0.4, 1.0], // Control gradient spread
                    ),
                  ),
                ),
              ],
            ),
            stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
          ),
          actions: [
             // Notification Bell with Badge (more complex)
             Padding(
                padding: const EdgeInsets.only(right: 15.0),
                child: Stack(
                   alignment: Alignment.topRight,
                   children: [
                     CircleAvatar(
                       backgroundColor: highlightOrange.withOpacity(0.95),
                       radius: 22, // Slightly larger
                       child: IconButton(
                         icon: const Icon(Icons.notifications_none_outlined, color: textDarkBrown, size: 24), // Use none_outlined
                         onPressed: () { /* Notification action */ },
                         tooltip: 'Notifikasi',
                       ),
                     ),
                      // Notification Badge (Example)
                     Positioned(
                       right: 4,
                       top: 4,
                       child: Container(
                         padding: const EdgeInsets.all(4),
                         decoration: BoxDecoration(
                           color: errorRed, // Use error color for emphasis
                           shape: BoxShape.circle,
                           border: Border.all(color: Colors.white, width: 1.5),
                         ),
                          constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                          child: Center(
                            child: Text(
                              '3', // Example notification count
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                       ),
                     ),
                   ],
                ),
              ),
          ],
        ),

        // SliverList for remaining content
        SliverList(
          delegate: SliverChildListDelegate(
            [
              // **Requirement 2: Carousel with 7 items and slightly larger**
              const SizedBox(height: 30), // More space before carousel
              cs.CarouselSlider.builder(
                 carouselController: _carouselController,
                 options: cs.CarouselOptions(
                   height: 245, // Slightly taller carousel
                   aspectRatio: 16/9, // Common aspect ratio
                   viewportFraction: 0.88, // Show more of adjacent items
                   initialPage: 0,
                   enableInfiniteScroll: true, // Loop the carousel
                   reverse: false,
                   autoPlay: true, // Enable auto play
                   autoPlayInterval: const Duration(seconds: 5), // Interval
                   autoPlayAnimationDuration: const Duration(milliseconds: 1200), // Slower animation
                   autoPlayCurve: Curves.fastOutSlowIn, // Standard curve
                   enlargeCenterPage: true, // Make center item larger
                   enlargeFactor: 0.25, // How much larger the center item is
                   scrollDirection: Axis.horizontal,
                   onPageChanged: (index, reason) {
                     setState(() {
                       _currentCarouselPage = index;
                     });
                   }
                 ),
                 itemCount: carouselImages.length, // Use the length of the updated list (7)
                 itemBuilder: (context, index, realIndex) {
                    final actualIndex = index % carouselImages.length;
                    // Using a more standard card approach for carousel items
                    return Container(
                         margin: const EdgeInsets.symmetric(horizontal: 5), // Small margin between items
                         decoration: BoxDecoration(
                           color: accentBrown.withOpacity(0.3),
                           borderRadius: BorderRadius.circular(24),
                           boxShadow: [
                             BoxShadow(
                               color: Colors.black.withOpacity(0.18), // Slightly darker shadow
                               blurRadius: 14,
                               spreadRadius: 1,
                               offset: const Offset(0, 7),
                             ),
                           ],
                         ),
                         child: ClipRRect( // Clip the image to rounded corners
                            borderRadius: BorderRadius.circular(24),
                            child: Stack( // Stack for image and gradient/text
                               fit: StackFit.expand,
                               children: [
                                 // Network Image with Loading Indicator
                                 FadeInImage.assetNetwork(
                                    placeholder: 'assets/images/placeholder.png', // Add a local placeholder image asset
                                    image: carouselImages[actualIndex],
                                    fit: BoxFit.cover,
                                     imageErrorBuilder: (context, error, stackTrace) {
                                         // Fallback widget if image fails to load
                                         return Container(
                                             color: accentBrown.withOpacity(0.5),
                                             child: const Center(child: Icon(Icons.broken_image_outlined, color: textMedium, size: 40)),
                                         );
                                     },
                                 ),
                                 // Gradient Overlay for text contrast
                                 Container(
                                   decoration: BoxDecoration(
                                     gradient: LinearGradient(
                                       begin: Alignment.topCenter,
                                       end: Alignment.bottomCenter,
                                       colors: [
                                         Colors.transparent,
                                         Colors.black.withOpacity(0.2),
                                         Colors.black.withOpacity(0.85), // Darker gradient
                                       ],
                                        stops: const [0.0, 0.45, 1.0], // Adjust stops
                                     ),
                                   ),
                                 ),
                                 // Text Content
                                 Positioned(
                                   bottom: 20,
                                   left: 20,
                                   right: 20, // Add right padding too
                                   child: Text(
                                     'Promo Spesial #${actualIndex + 1}: Tingkatkan Skill Anda!', // More engaging text
                                     style: GoogleFonts.poppins(
                                       textStyle: const TextStyle(
                                         color: textLight,
                                         fontSize: 18, // Slightly smaller font for potentially longer text
                                         fontWeight: FontWeight.w600,
                                         shadows: [
                                              Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
                                          ]
                                       ),
                                     ),
                                      maxLines: 2, // Allow two lines
                                      overflow: TextOverflow.ellipsis,
                                   ),
                                 ),
                               ],
                            ),
                         ),
                       );
                 },
              ),

              // Carousel Indicator (Dots) - Using carousel_slider's built-in indicator logic via state
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 25),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: carouselImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    return GestureDetector(
                      onTap: () => _carouselController.animateToPage(index),
                      child: AnimatedContainer(
                           duration: const Duration(milliseconds: 300),
                           curve: Curves.easeOut,
                           width: _currentCarouselPage == index ? 22 : 8, // Active indicator is wider
                           height: 8,
                           margin: const EdgeInsets.symmetric(horizontal: 4.0),
                           decoration: BoxDecoration(
                               borderRadius: BorderRadius.circular(4),
                               color: _currentCarouselPage == index
                                   ? secondaryBrown
                                   : accentBrown.withOpacity(0.7),
                           ),
                       ),
                    );
                  }).toList(),
                ),
              ),

              // Premium Banner (Remains largely the same, maybe slight style adjustments)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      highlightOrange.withOpacity(0.9),
                      primaryBrown.withOpacity(0.85),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBrown.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: secondaryBrown.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              'Courall Premium',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: textLight,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Upgrade ke Premium! Akses Tanpa Batas.',
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                color: textDarkBrown,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dapatkan kursus dengan harga termurah.',
                            style: GoogleFonts.poppins(
                              textStyle: TextStyle(
                                color: textDarkBrown.withOpacity(0.8),
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          ElevatedButton.icon(
                             onPressed: () { /* Action */
                             
                             CustomModal.show(
                                context: context,
                                title: 'Detail Promo Spesial',
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('✨ Diskon 50% untuk semua kursus',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    SizedBox(height: 8),
                                    Text('Berlaku sampai 30 Mei 2025.'),
                                    SizedBox(height: 16),
                                    Text('✨ Gratis e-book Flutter',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                    SizedBox(height: 8),
                                    Text('Unduh setelah mendaftar.'),
                                  ],
                                ),
                              );
                             
                             },
                             icon: const Icon(Icons.star_border_rounded, size: 18),
                             label: Text(
                               'Lihat Detail',
                               style: GoogleFonts.poppins(
                                 textStyle: const TextStyle(
                                   fontWeight: FontWeight.bold,
                                   fontSize: 13,
                                 ),
                               ),
                             ),
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: textLight,
                                  foregroundColor: secondaryBrown,
                                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 4,
                              ),
                           ),
                        ],
                      ),
                    ),
                     const SizedBox(width: 15),
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                         color: textLight.withOpacity(0.2),
                         shape: BoxShape.circle,
                         border: Border.all(color: textLight.withOpacity(0.5), width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.workspace_premium_outlined,
                          color: textLight,
                          size: 45,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Categories Section Title (Remains the same)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
                child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                   crossAxisAlignment: CrossAxisAlignment.center,
                   children: [
                      Text(
                        'Jelajahi Kategori',
                        style: GoogleFonts.poppins(
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: secondaryBrown,
                          ),
                        ),
                      ),
                     
                   ],
                ),
              ),

              // Categories Grid (Remains the same, using the existing enhanced card)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                  ),
                  itemCount: categories.length, // Use updated categories length
                  itemBuilder: (context, index) {
                    return _buildCategoryCard(categories[index]); // Use enhanced card builder
                  },
                ),
              ),

              // Featured Content Section (Remains the same)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                      image: NetworkImage('https://img.freepik.com/free-photo/business-people-meeting_53876-88834.jpg'),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 18,
                        spreadRadius: 3,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                           secondaryBrown.withOpacity(0.95),
                           primaryBrown.withOpacity(0.7),
                           Colors.transparent,
                        ],
                         stops: const [0.0, 0.6, 1.0],
                      ),
                    ),
                    padding: const EdgeInsets.all(25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: highlightOrange,
                            borderRadius: BorderRadius.circular(20),
                             boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                             ],
                          ),
                          child: Text(
                            'WAJIB DITONTON',
                            style: GoogleFonts.poppins(
                              textStyle: const TextStyle(
                                color: textDarkBrown,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            'Courall : Kita untuk Semua',
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                color: textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                height: 1.3,
                                shadows: [
                                    Shadow(offset: Offset(0, 1), blurRadius: 4, color: Colors.black87),
                                ]
                              ),
                            ),
                          ),
                        ),
                         const Spacer(),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_circle_outline, size: 20),
                              label: Text(
                                'Putar Video',
                                style: GoogleFonts.poppins(
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: textLight,
                                foregroundColor: secondaryBrown,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                elevation: 5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                               padding: const EdgeInsets.all(10),
                               decoration: BoxDecoration(
                                  color: textLight.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: textLight.withOpacity(0.4), width: 1)
                               ),
                               child: const Icon(
                                  Icons.bookmark_add_outlined,
                                  color: textLight,
                                  size: 20,
                               ),
                             ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Add extra space at the bottom for the floating nav bar
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

  // Enhanced Category Card (Remains the same)
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            textLight,
            backgroundNeutral.withOpacity(0.8),
          ],
          stops: const [0.0, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            spreadRadius: 0,
            offset: const Offset(0, 5),
          ),
        ],
         border: Border.all(color: accentBrown.withOpacity(0.3), width: 1.5)
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () { /* Category tap action */ },
            splashColor: primaryBrown.withOpacity(0.1),
            highlightColor: primaryBrown.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                           primaryBrown.withOpacity(0.1),
                           secondaryBrown.withOpacity(0.15),
                        ],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                          BoxShadow(
                            color: secondaryBrown.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: const Offset(2, 2),
                          ),
                      ],
                    ),
                    child: Icon(
                      category['icon'],
                      color: secondaryBrown,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    category['name'],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: textDarkBrown,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
        ),
      ),
    );
  }

  Widget _buildSearchTab() {
    return CustomScrollView(
       slivers: [
          // **Requirement 3: Redesigned Search Header**
          SliverAppBar(
              expandedHeight: 100.0, // Increased height for more design
              floating: true,
              pinned: false, // Keep title visible but not the whole bar
              snap: true,
              backgroundColor: primaryBrown,
              elevation: 4.0,
              // Ensure content scrolls behind AppBar when it collapses
              // surfaceTintColor: Colors.transparent, // Or match backgroundNeutral
              flexibleSpace: FlexibleSpaceBar(
                  centerTitle: false, // Align left when collapsed
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 32, right: 20),
                  title: Text(
                      'Temukan Kursus Impianmu !', // More engaging title
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, // Bolder
                          color: textLight,
                          fontSize: 19,
                          shadows: [ // Add shadow
                              Shadow(offset: Offset(0, 1), blurRadius: 2, color: Colors.black45),
                          ]
                      ),
                       maxLines: 1,
                       overflow: TextOverflow.ellipsis,
                  ),
                  background: Stack( // Stack for background layers
                     fit: StackFit.expand,
                     children: [
                       Container(
                           decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                      primaryBrown.withOpacity(0.9),
                                      secondaryBrown.withOpacity(1.0), // Darker bottom
                                  ],
                              ),
                           ),
                       ),
                        // Batik Pattern Overlay
                       Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(batikPatternOverlay),
                              fit: BoxFit.cover,
                              opacity: 0.08, // Subtle pattern
                              colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.2), BlendMode.darken)
                            ),
                          ),
                        ),
                        // Optional: Add a subtle shape or graphic element
                        Positioned(
                           bottom: -30,
                           right: -20,
                           child: Icon(Icons.search_rounded, size: 120, color: textLight.withOpacity(0.05)),
                        )
                     ],
                  ),
                   stretchModes: const [StretchMode.zoomBackground], // Only zoom background on overscroll
              ),
          ),

          // **Requirement 3: Fix Search Bar Overlap**
          SliverToBoxAdapter(
              // Adjust the offset less drastically, maybe use padding below AppBar instead
              // child: Transform.translate(
              //   offset: const Offset(0, -25), // Reduced negative offset
              child: Padding( // Add padding at the top instead of negative offset
                padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 5),
                child: Padding(
                  padding: const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 5),
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (value) => _performSearch(value),
                    decoration: InputDecoration(
                      hintText: 'Cari "tutorial flutter"...',
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () => _performSearch(_searchController.text),
                      ),
                    ),
                  ),
                ),
          
              ),
          ),

           // Main content area
            SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_isSearching)
                Center(child: CircularProgressIndicator(color: primaryBrown)),

              if (_searchResults.isNotEmpty)
                ..._searchResults.map((video) => _buildVideoCard(video)).toList(),

              if (_searchResults.isEmpty && !_isSearching && _searchQuery.isNotEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 50, color: textMedium),
                    SizedBox(height: 10),
                    Text('Tidak ditemukan hasil untuk "$_searchQuery"',
                        style: GoogleFonts.poppins(color: textMedium)),
                  ],
                ),
              ),

              if (_searchQuery.isEmpty && !_isSearching)
                _buildDefaultRecommendations(),
            ]),
          ),
        ),
       ]
    );
  }

    Widget _buildVideoCard(dynamic video) {
      final videoId = video['videoId'] ?? '';
      final thumbnails = video['videoThumbnails'] as List<dynamic>? ?? [];

      final thumbUrl = thumbnails.isNotEmpty 
      ? thumbnails.firstWhere(
          (thumb) => thumb['quality'] == 'medium',
          orElse: () => {'url': ''},
        )['url'] 
      : '';

      if (videoId.isEmpty) return SizedBox.shrink();

      return Card(
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: InkWell(
          onTap: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  appBar: AppBar(title: Text(video['title'] ?? 'Video'),
                  backgroundColor: secondaryBrown,),
                  body: YoutubePlayer(
                    controller: YoutubePlayerController(
                      initialVideoId: videoId,
                      flags: YoutubePlayerFlags(
                        autoPlay: true,
                        disableDragSeek: true,
                      ),
                    ),
                  ),
                ),
              ),
            );

          },
          child: Column(
            children: [
              CachedNetworkImage(
                imageUrl: thumbUrl,
                placeholder: (context, url) => Container(
                  height: 200,
                  color: accentBrown,
                  child: Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: Icon(Icons.error_outline, color: errorRed),
                ),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video['title'] ?? 'No Title',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: textDarkBrown,
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: textMedium),
                        SizedBox(width: 4),
                        Text(
                          video['author'] ?? 'Unknown',
                          style: GoogleFonts.poppins(color: textMedium, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, size: 16, color: textMedium),
                        SizedBox(width: 4),
                        Text(
                          _formatDuration(video['lengthSeconds']?.toString() ?? '0'),
                          style: GoogleFonts.poppins(color: textMedium, fontSize: 12),
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

String _formatDuration(String seconds) {
  final duration = Duration(seconds: int.parse(seconds));
  return "${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}";
}

    Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
      _searchQuery = query;
      _searchResults = [];
    });

    try {
      final response = await http
        .get(
        Uri.parse('$_invidiousInstance/api/v1/search?q=$query&type=video'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = json.decode(response.body);
        setState(() {
          _searchResults = results.where((v) => 
            v['title'].toString().toLowerCase().contains('tutorial') ||
            v['title'].toString().toLowerCase().contains('belajar')
          ).toList();
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
        throw 'Gagal memuat hasil (Status: ${response.statusCode})';
      }
    } catch (e) {
      setState(() => _isSearching = false);
      CustomModal.show(
        context: context,
        title: 'Error',
        body: Text('Gagal memuat hasil: ${e.toString()}'),
      );
    }
  }

  //  // Enhanced Search Recommendation Chip (Remains the same)
  // Widget _buildSearchRecommendationChip(String text) {
  //   return Material(
  //       color: Colors.transparent,
  //       child: InkWell(
  //           onTap: () { /* Search recommendation tap */},
  //           borderRadius: BorderRadius.circular(25),
  //           splashColor: primaryBrown.withOpacity(0.1),
  //           highlightColor: primaryBrown.withOpacity(0.05),
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
  //             decoration: BoxDecoration(
  //               color: Colors.white,
  //               borderRadius: BorderRadius.circular(25),
  //               border: Border.all(color: accentBrown.withOpacity(0.6), width: 1),
  //               boxShadow: [
  //                 BoxShadow(
  //                   color: Colors.black.withOpacity(0.04),
  //                   blurRadius: 8,
  //                   offset: const Offset(0, 2),
  //                 ),
  //               ],
  //             ),
  //             child: Text(
  //               text,
  //               style: GoogleFonts.poppins(
  //                 textStyle: TextStyle(
  //                   color: textDarkBrown.withOpacity(0.9),
  //                   fontSize: 13.5,
  //                   fontWeight: FontWeight.w500,
  //                 ),
  //               ),
  //             ),
  //           ),
  //       ),
  //   );
  // }


  Widget _buildDefaultRecommendations() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 20, bottom: 12),
        child: Text(
          'Rekomendasi Pencarian',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: secondaryBrown,
          ),
        ),
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: searchRecommendations.map((query) => ActionChip(
          label: Text(query),
          onPressed: () {
            _searchController.text = query;
            _performSearch(query);
          },
          backgroundColor: backgroundNeutral,
          labelStyle: GoogleFonts.poppins(color: primaryBrown),
        )).toList(),
      ),
    ],
  );
}

  Widget _buildInfoTab() {
    // **Requirement 4: Add Background Image**
    return Container( // Wrap with a Container for the background image
        decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(infoBackground), // Use the defined info background URL
                fit: BoxFit.cover,
                opacity: 0.05, // Make it very subtle
                colorFilter: ColorFilter.mode(backgroundNeutral.withOpacity(0.8), BlendMode.dstATop) // Blend with background
            ),
        ),
        child: CustomScrollView( // Keep CustomScrollView for scrolling content
           slivers: [
               SliverAppBar(
                   pinned: true,
                   floating: false,
                   backgroundColor: backgroundNeutral.withOpacity(0.8), // Slightly transparent to see background hint
                   elevation: 1.0, // Reduced elevation
                   scrolledUnderElevation: 3.0, // Elevation when scrolled under
                   shadowColor: primaryBrown.withOpacity(0.3),
                   centerTitle: false,
                   title: Text(
                      'Informasi Aplikasi',
                       style: GoogleFonts.poppins(
                           fontWeight: FontWeight.w600,
                           color: secondaryBrown,
                           fontSize: 20,
                       ),
                   ),
                   // Example of adding a subtle bottom border
                   bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(1.0),
                        child: Container(
                            color: accentBrown.withOpacity(0.3),
                            height: 1.0,
                        ),
                    ),
               ),

               SliverPadding(
                   padding: const EdgeInsets.all(20),
                   sliver: SliverList(
                      delegate: SliverChildListDelegate(
                          [
                              // About Us Section (Enhanced Card - remains mostly the same)
                               Container(
                                   margin: const EdgeInsets.only(bottom: 25),
                                   decoration: BoxDecoration(
                                       color: Colors.white.withOpacity(0.95), // Slightly transparent white
                                       borderRadius: BorderRadius.circular(20),
                                       boxShadow: [
                                          BoxShadow(
                                             color: Colors.black.withOpacity(0.08),
                                             blurRadius: 15,
                                             spreadRadius: 1,
                                             offset: const Offset(0,4)
                                          ),
                                       ],
                                        border: Border.all(color: accentBrown.withOpacity(0.4), width: 1),
                                   ),
                                   padding: const EdgeInsets.all(25),
                                   child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                          Text(
                                              'Tentang Courall',
                                              style: GoogleFonts.playfairDisplay(
                                                   fontSize: 22,
                                                   fontWeight: FontWeight.bold,
                                                   color: secondaryBrown,
                                              ),
                                          ),
                                          const SizedBox(height: 15),
                                          RichText(
                                              text: TextSpan(
                                                   style: GoogleFonts.poppins(
                                                      color: textDarkBrown.withOpacity(0.85),
                                                      fontSize: 15.5,
                                                      height: 1.7,
                                                   ),
                                                   children: const [
                                                      TextSpan(
                                                          text: 'Courall ',
                                                          style: TextStyle(fontWeight: FontWeight.bold, color: primaryBrown),
                                                      ),
                                                      TextSpan(
                                                          text: 'adalah platform e-learning inovatif yang didedikasikan untuk memberdayakan individu melalui pendidikan berkualitas yang mudah diakses. Kami percaya pada kekuatan pembelajaran seumur hidup untuk membuka potensi tak terbatas.',
                                                      ),
                                                   ],
                                               ),
                                          ),
                                           const SizedBox(height: 20),
                                           Divider(color: accentBrown.withOpacity(0.5)),
                                           const SizedBox(height: 20),
                                           // **Requirement 4: Check Logo Colors**
                                           // The colors primaryBrown and highlightOrange are distinct by design.
                                           // Assuming this distinction is intentional for visual hierarchy.
                                           _buildInfoHighlight(
                                              Icons.lightbulb_outline_rounded,
                                               'Misi Kami',
                                               'Menyediakan akses mudah ke pengetahuan dan keterampilan relevan untuk kesuksesan personal dan profesional, serta memberdayakan dan menguatkan komunitas lokal.',
                                                primaryBrown // Misi uses primary Brown
                                           ),
                                           const SizedBox(height: 15),
                                           _buildInfoHighlight(
                                               Icons.favorite_border_rounded, // Using favorite/heart for 'Nilai' (Values)
                                               'Nilai Kami',
                                               'Inovasi, Kualitas, Aksesibilitas, Komunitas.',
                                                primaryBrown // Nilai uses highlight Orange
                                           ),
                                       ],
                                   ),
                               ),

                              // Section Title: Fitur Aplikasi (Remains the same)
                              _buildSectionTitle('Fitur Unggulan', Icons.featured_play_list_outlined),
                              const SizedBox(height: 15),

                              // Feature Items (Remains the same)
                              _buildFeatureItem(
                                'Kurikulum Terstruktur',
                                'Materi pembelajaran dirancang secara sistematis.',
                                Icons.list_alt_rounded,
                                highlightOrange,
                              ),
                              _buildFeatureItem(
                                'Harga Terjangkau',
                                'Belajar kursus berkualitas tanpa khawatir dengan biaya.',
                                Icons.money,
                                darkerhighlightOrange,
                              ),
                              _buildFeatureItem(
                                'Pembelajaran Fleksibel',
                                'Akses materi kapan saja, di mana saja.', // Simplified text
                                Icons.devices_rounded, // Different icon
                                highlightOrange,
                              ),
                               _buildFeatureItem(
                                'Sertifikat Penyelesaian',
                                'Validasi pencapaian belajar Anda.',
                                Icons.workspace_premium_outlined,
                                 darkerhighlightOrange, // Consistent color for this type
                              ),


                              const SizedBox(height: 30),

                              // Section Title: FAQ (Remains the same)
                               _buildSectionTitle('Pertanyaan Umum (FAQ)', Icons.help_outline_rounded),
                               const SizedBox(height: 15),

                              // FAQ Items (Remains the same)
                              _buildFaqExpansionTile('Bagaimana cara memulai kursus?'),
                              _buildFaqExpansionTile('Apakah saya mendapatkan sertifikat?'),
                              _buildFaqExpansionTile('Bisakah saya mengunduh materi?'),
                              _buildFaqExpansionTile('Mengapa Courall sangat murah?'),

                              const SizedBox(height: 30),

                              // Section Title: Hubungi Kami (Remains the same)
                               _buildSectionTitle('Hubungi Kami', Icons.contact_support_outlined),
                               const SizedBox(height: 15),

                              // Contact Cards (Remains the same)
                              _buildContactCard(
                                'Email Dukungan',
                                'klfn45@gmail.com',
                                Icons.email_outlined,
                                 highlightOrange,
                              ),
                              _buildContactCard(
                                'WhatsApp Bantuan',
                                '+62 800 0000 0000',
                                Icons.support_agent_rounded,
                                 secondaryBrown,
                              ),
                              _buildContactCard(
                                'Line Support',
                                '@linekalfin',
                                Icons.language_outlined,
                                 secondaryBrown,
                              ),

                              // Bottom spacing
                              const SizedBox(height: 100),
                          ]
                      ),
                   ),
               ),
           ]
        ),
    );
  }

  // Helper for section titles (Remains the same)
   Widget _buildSectionTitle(String title, IconData icon) {
       return Row(
           children: [
               Icon(icon, color: secondaryBrown, size: 22),
               const SizedBox(width: 10),
               Text(
                  title,
                   style: GoogleFonts.poppins(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                       color: secondaryBrown,
                   ),
               ),
           ],
       );
   }


   // Helper for Info Highlights (Remains the same)
   Widget _buildInfoHighlight(IconData icon, String title, String text, Color iconColor) {
     return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textDarkBrown,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                   text,
                   style: GoogleFonts.poppins(
                      color: textDarkBrown.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                   ),
                ),
              ],
            ),
          ),
        ],
      );
   }


  // Enhanced Info Card Base (Remains the same)
   Widget _buildInfoCardBase(String title, String subtitle, IconData icon, Color themeColor) {
       return Container(
           margin: const EdgeInsets.only(bottom: 15),
           decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.95), // Match info card background
               borderRadius: BorderRadius.circular(15),
               boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                  ),
               ],
               border: Border.all(color: themeColor.withOpacity(0.3), width: 1),
           ),
           child: Material(
               color: Colors.transparent,
               child: InkWell(
                  borderRadius: BorderRadius.circular(15),
                  onTap: () { /* Card tap action */ },
                  splashColor: themeColor.withOpacity(0.1),
                  highlightColor: themeColor.withOpacity(0.05),
                  child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                          children: [
                              Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                         colors: [
                                            themeColor.withOpacity(0.1),
                                            themeColor.withOpacity(0.2),
                                         ],
                                         begin: Alignment.topLeft,
                                         end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                     icon,
                                     color: themeColor,
                                     size: 26,
                                  ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                          Text(
                                             title,
                                             style: GoogleFonts.poppins(
                                                 fontWeight: FontWeight.w600,
                                                 fontSize: 16,
                                                 color: textDarkBrown,
                                             ),
                                          ),
                                          if (subtitle.isNotEmpty) ...[
                                             const SizedBox(height: 5),
                                             Text(
                                                subtitle,
                                                style: GoogleFonts.poppins(
                                                    color: textMedium,
                                                    fontSize: 14,
                                                    height: 1.4,
                                                ),
                                             ),
                                          ]
                                      ],
                                  ),
                              ),
                             Icon(Icons.arrow_forward_ios_rounded, color: themeColor.withOpacity(0.7), size: 16),
                          ],
                      ),
                  ),
               ),
           ),
       );
   }

  // Specific builders using the base card (Remains the same)
   Widget _buildFeatureItem(String title, String description, IconData icon, Color color) {
       return _buildInfoCardBase(title, description, icon, color);
   }

   Widget _buildContactCard(String title, String info, IconData icon, Color color) {
  return InkWell(
    onTap: () => openCommunication(
    icon == Icons.email_outlined ? 'email'
      : icon == Icons.support_agent_rounded ? 'whatsapp'
      : 'line',
    info,
  ).catchError((e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.toString())),
    );
  }),
  child: _buildInfoCardBase(info, title, icon, color),
  );
}



  // Enhanced FAQ Item (Remains the same)
  // main_menu.dart — perbarui fungsi _buildFaqExpansionTile
Widget _buildFaqExpansionTile(String question) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.95),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: accentBrown.withOpacity(0.4), width: 1),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        CustomModal.show(
          context: context,
          title: question,
          body: Text(
            'Jawaban untuk pertanyaan ini akan ditampilkan di sini. '
            'Penjelasan bisa lebih dari satu baris dan akan menyesuaikan secara otomatis. '
            'Pastikan konten FAQ relevan dan membantu pengguna.',
            style: GoogleFonts.poppins(
              color: textDarkBrown.withOpacity(0.8),
              fontSize: 14.5,
              height: 1.6,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            Expanded(
              child: Text(
                question,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 15.5,
                  color: secondaryBrown,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: primaryBrown,
              size: 16,
            ),
          ],
        ),
      ),
    ),
  );
}



  Widget _buildSettingsTab() {
     // Using CustomScrollView for consistency
     return CustomScrollView(
         slivers: [
             SliverAppBar(
                 pinned: true,
                 floating: false,
                 backgroundColor: backgroundNeutral,
                 elevation: 1.0, // Consistent elevation with Info tab
                 scrolledUnderElevation: 3.0,
                 shadowColor: primaryBrown.withOpacity(0.3),
                 centerTitle: false,
                 title: Text(
                     'Profil & Pengaturan', // Changed title
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: secondaryBrown,
                          fontSize: 20,
                      ),
                 ),
                  bottom: PreferredSize( // Consistent bottom border
                        preferredSize: const Size.fromHeight(1.0),
                        child: Container(
                            color: accentBrown.withOpacity(0.3),
                            height: 1.0,
                        ),
                    ),
             ),

             SliverPadding(
                 padding: const EdgeInsets.all(20),
                 sliver: SliverList(
                     delegate: SliverChildListDelegate(
                         [
                              // --- User Profile Section ---
                             _buildUserProfileHeader(), // Extracted to a separate widget for complexity
                             const SizedBox(height: 25),

                             // --- Account Section ---
                             _buildSectionTitle('Pengaturan Akun', Icons.manage_accounts_outlined), // Changed Icon
                             const SizedBox(height: 15),
                             _buildSettingsItem('Edit Profil', Icons.person_outline_rounded, () {/* Navigate Edit Profile */
                             CustomModal.show(
                                context: context,
                                title: 'Profil',
                                body: Center(child: Text('KERJAKAN EDWARD.', style: GoogleFonts.poppins())),
                                maxHeightFactor: 0.2
                              );
                            }),
                             _buildSettingsItem('Kelola Notifikasi', Icons.notifications_none_rounded, () {
                              CustomModal.show(
                                context: context,
                                title: 'Pengaturan Notifikasi',
                                body: Center(child: Text('Fitur ini belum tersedia.', style: GoogleFonts.poppins())),
                                maxHeightFactor: 0.2
                              );
                            }),
                             // **Requirement 5: Replace Items**
                             // _buildSettingsItem('Privasi & Keamanan', Icons.lock_outline_rounded, () {/* Navigate Privacy */}), // REMOVED
                             // _buildSettingsItem('Preferensi Bahasa', Icons.translate_rounded, () {/* Navigate Language */}), // REMOVED
                             _buildSettingsItem('Riwayat Pembelajaran', Icons.history_edu_outlined, () {/* Navigate History */
                             CustomModal.show(
                                context: context,
                                title: 'Riwayat',
                                body: Text(
                                  'Riwayat anda tidak ada atau belum terdaftar pada database kami. ',
                                ),
                                maxHeightFactor: 0.2
                              );
                            }),
                             _buildSettingsItem('Sertifikat Saya', Icons.card_membership_outlined, () {
                              CustomModal.show(
                                context: context,
                                title: 'Sertifikat Saya',
                                body: Text(
                                  'Anda belum memenuhi syarat untuk klaim sertifikat apa pun. ',
                                ),
                                maxHeightFactor: 0.2
                              );
                            }),

                             const SizedBox(height: 30),

                             // --- App Settings Section ---
                             _buildSectionTitle('Preferensi Aplikasi', Icons.tune_outlined),
                             const SizedBox(height: 15),
                              // **Requirement 5: Replace Items**
                              // _buildSettingsToggleItem('Mode Gelap', Icons.brightness_4_outlined, true, (value) {/* Toggle Dark Mode */}), // REMOVED
                              // _buildSettingsItem('Penggunaan Data & Cache', Icons.storage_outlined, () {/* Navigate Storage */}), // REMOVED
                              _buildSettingsItem('Tampilan & Tema', Icons.color_lens_outlined, () {
                              CustomModal.show(
                                context: context,
                                title: 'Tampilan & Tema',
                                body: Center(child: Text('Akan Datang!', style: GoogleFonts.poppins(fontSize: 16))),
                              );
                            }),
                              _buildSettingsItem('Aksesibilitas', Icons.accessibility_new_rounded, () {
                                CustomModal.show(
                                  context: context,
                                  title: 'Aksesibilitas',
                                  body: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.text_fields),
                                        title: Text('Ukuran Teks Besar (Akan Datang)'),
                                      ),
                                      ListTile(
                                        leading: Icon(Icons.contrast),
                                        title: Text('Mode Kontras Tinggi (Akan Datang)'),
                                      ),
                                      SizedBox(height: 8),
                                      Text('\nPengaturan akan hadir pada update mendatang.'),
                                    ],
                                  ),
                                  maxHeightFactor: 0.4,
                                );
                              }),


                             const SizedBox(height: 30),

                             // --- Help & About Section (Remains the same) ---
                              _buildSectionTitle('Bantuan & Informasi', Icons.help_center_outlined),
                              const SizedBox(height: 15),
                              _buildSettingsItem('Pusat Bantuan (FAQ)', Icons.quiz_outlined, () {/* Navigate Help */  _tabController.animateTo(2);}),
                              _buildSettingsItem('Tentang Courall', Icons.info_outline_rounded, () {
                              CustomModal.show(
                                context: context,
                                title: 'Tentang Courall',
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Courall v0.1.0', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('Platform e-learning inovatif untuk semua kalangan.'),
                                    SizedBox(height: 12),
                                    Text('© 2025 Courall'),
                                  ],
                                ),
                                maxHeightFactor: 0.28,
                              );
                            }),
                              _buildSettingsItem('Kebijakan Privasi', Icons.shield_outlined, () {
                                CustomModal.show(
                                  context: context,
                                  title: 'Kebijakan Privasi',
                                  body: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12, right: 4), // kiri terasa
                                      child: Text(
                                        """1. Pengumpulan Informasi
Kami mengumpulkan data pribadi yang Anda berikan secara langsung ketika:

-Mendaftar akun

-Mengakses kursus

-Menghubungi layanan bantuan

Informasi yang kami kumpulkan dapat berupa nama, email, institusi, dan aktivitas penggunaan aplikasi.\n\n"""
                                        """2. Penggunaan Informasi
Data Anda digunakan untuk:

-Memberikan akses ke konten kursus

-Mengelola akun pengguna

-Meningkatkan layanan dan pengalaman pengguna

-Mengirim notifikasi penting dan informasi promosi\n\n"""
                                        """3. Penyimpanan dan Keamanan
Data Anda disimpan secara aman dan hanya diakses oleh pihak yang berwenang. Kami menggunakan enkripsi dan sistem keamanan standar industri untuk melindungi data Anda.\n\n"""
                                        """4. Berbagi Informasi
Kami tidak menjual atau menyewakan informasi pribadi Anda kepada pihak ketiga. Informasi hanya dibagikan jika:

-Diperlukan oleh hukum

-Dibutuhkan untuk melindungi hak dan keamanan pengguna atau Courall\n\n"""
                                        """5. Hak Pengguna
Anda memiliki hak untuk:

-Mengakses dan memperbarui data pribadi Anda

-Menghapus akun dan data yang tersimpan

-Menolak penggunaan data untuk kepentingan pemasaran\n\n"""
                                        """6. Perubahan Kebijakan
Kami dapat memperbarui kebijakan ini dari waktu ke waktu. Perubahan signifikan akan diberitahukan melalui aplikasi atau email.""",
                                        style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                  maxHeightFactor: 0.9,
                                );
                              }),


                              const SizedBox(height: 35),

                              // --- Log out Button (Remains the same) ---
                              _buildLogoutButton(),


                             // Bottom spacing
                             const SizedBox(height: 100),
                         ]
                     ),
                 ),
             ),
         ]
     );
   }

  // NEW: User Profile Header Widget for Settings Tab
  Widget _buildUserProfileHeader() {
    return Container(
       padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
       decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: primaryBrown.withOpacity(0.1), // Soft shadow
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: Border.all(color: accentBrown.withOpacity(0.4), width: 1),
       ),
       child: Row(
          children: [
             // User Avatar with Online Indicator
             Stack(
                children: [
                   CircleAvatar(
                      radius: 35,
                      backgroundColor: accentBrown.withOpacity(0.5),
                      backgroundImage: const NetworkImage('https://picsum.photos/200'), // Placeholder avatar
                   ),
                    Positioned(
                       bottom: 2,
                       right: 2,
                       child: Container(
                         width: 12,
                         height: 12,
                         decoration: BoxDecoration(
                            color: successGreen, // Online status indicator
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                         ),
                       ),
                     ),
                ],
             ),
             const SizedBox(width: 20),
             Expanded(
                child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                      Text(
                         'Edward Horang', // Replace with actual user name
                         style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: textDarkBrown,
                         ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                         'chiggaCSUI@gmail.com', // Replace with actual user email
                         style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: textMedium,
                         ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                       // Example: Membership Status Tag
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                         decoration: BoxDecoration(
                           color: highlightOrange.withOpacity(0.15),
                           borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: highlightOrange.withOpacity(0.5), width: 1)
                         ),
                         child: Text(
                           'Member Premium', // Example Status
                           style: GoogleFonts.poppins(
                             color: highlightOrange, // Use palette color
                             fontWeight: FontWeight.w600,
                             fontSize: 11,
                           ),
                         ),
                       ),
                   ],
                ),
             ),
             const SizedBox(width: 10),
              // Edit Profile Button
             IconButton(
                onPressed: () { /* Navigate to Edit Profile */},
                icon: const Icon(Icons.edit_outlined),
                 color: primaryBrown,
                 tooltip: 'Edit Profil',
                 iconSize: 22,
             ),
          ],
       ),
    );
  }


  // Enhanced Settings Item (Remains the same)
   Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
     return Container(
       margin: const EdgeInsets.only(bottom: 12),
       decoration: BoxDecoration(
         color: Colors.white,
         borderRadius: BorderRadius.circular(15),
         boxShadow: [
           BoxShadow(
             color: Colors.black.withOpacity(0.04),
             blurRadius: 8,
             offset: const Offset(0, 2),
           ),
         ],
          border: Border.all(color: accentBrown.withOpacity(0.3), width: 1),
       ),
       child: Material(
         color: Colors.transparent,
         child: InkWell(
           onTap: onTap,
           borderRadius: BorderRadius.circular(15),
           splashColor: primaryBrown.withOpacity(0.1),
           highlightColor: primaryBrown.withOpacity(0.05),
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
             child: Row(
               children: [
                 Icon(
                   icon,
                   color: primaryBrown,
                   size: 24,
                 ),
                 const SizedBox(width: 18),
                 Expanded(
                   child: Text(
                     title,
                     style: GoogleFonts.poppins(
                       fontWeight: FontWeight.w500,
                       fontSize: 16,
                       color: textDarkBrown,
                     ),
                   ),
                 ),
                 Icon(
                   Icons.arrow_forward_ios_rounded,
                   color: accentBrown,
                   size: 16,
                 ),
               ],
             ),
           ),
         ),
       ),
     );
   }

   // Settings Item with a Toggle Switch (Remains the same, but not used currently)
  //  Widget _buildSettingsToggleItem(String title, IconData icon, bool value, ValueChanged<bool> onChanged) {
  //      return Container(
  //          margin: const EdgeInsets.only(bottom: 12),
  //          decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(15),
  //             boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2),),],
  //             border: Border.all(color: accentBrown.withOpacity(0.3), width: 1),
  //          ),
  //          child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
  //             child: Row(
  //                children: [
  //                    Icon(icon, color: primaryBrown, size: 24),
  //                    const SizedBox(width: 18),
  //                    Expanded(
  //                        child: Text(
  //                            title,
  //                            style: GoogleFonts.poppins( fontWeight: FontWeight.w500, fontSize: 16, color: textDarkBrown,),
  //                        ),
  //                    ),
  //                    Switch(
  //                        value: value,
  //                        onChanged: onChanged,
  //                        activeColor: secondaryBrown,
  //                        inactiveThumbColor: accentBrown,
  //                        activeTrackColor: primaryBrown.withOpacity(0.5),
  //                        // Add material 3 style
  //                        trackOutlineColor: WidgetStateProperty.resolveWith(
  //                          (final Set<WidgetState> states) {
  //                            if (states.contains(WidgetState.selected)) {
  //                              return null; // Use default outline color when selected
  //                            }
  //                            return accentBrown.withOpacity(0.5); // Outline color when inactive
  //                          },
  //                        ),
  //                    ),
  //                ],
  //             ),
  //          ),
  //      );
  //  }


   // Enhanced Logout Button (Using errorRed from palette)
   Widget _buildLogoutButton() {
       return Container(
           margin: const EdgeInsets.symmetric(vertical: 10),
           decoration: BoxDecoration(
               color: errorRed.withOpacity(0.08), // Use errorRed palette color
               borderRadius: BorderRadius.circular(15),
               border: Border.all(color: errorRed.withOpacity(0.4), width: 1), // Red border
               boxShadow: [
                  BoxShadow(
                      color: errorRed.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                  ),
               ],
           ),
           child: Material(
               color: Colors.transparent,
               child: InkWell(
                  onTap: () {
                       // Add confirmation dialog for logout for better UX
                      showDialog(
                          context: context,
                          builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  title: Text('Konfirmasi Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: secondaryBrown)),
                                  content: Text('Apakah Anda yakin ingin keluar dari akun?', style: GoogleFonts.poppins(color: textMedium)),
                                  actions: <Widget>[
                                      TextButton(
                                          child: Text('Batal', style: GoogleFonts.poppins(color: textMedium)),
                                          onPressed: () { Navigator.of(dialogContext).pop(); }, // Close the dialog
                                      ),
                                      TextButton(
                                          child: Text('Keluar', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: errorRed)),
                                          onPressed: () {
                                              Navigator.of(dialogContext).pop(); // Close the dialog
                                              // --- Perform Actual Logout Logic Here ---
                                              print('Logout action triggered');
                                              // Example: Navigator.pushReplacementNamed(context, '/login');
                                          },
                                      ),
                                  ],
                              );
                          }
                      );
                  },
                  borderRadius: BorderRadius.circular(15),
                  splashColor: errorRed.withOpacity(0.1),
                  highlightColor: errorRed.withOpacity(0.05),
                  child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                              Icon( Icons.logout_rounded, color: errorRed, size: 22,), // Use errorRed
                              const SizedBox(width: 12),
                              Text(
                                 'Keluar dari Akun',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: errorRed, // Use errorRed
                                  ),
                              ),
                          ],
                      ),
                  ),
               ),
           ),
       );
   }


  // --- Bottom Navigation Bar (Remains the same) ---

  Widget _buildFloatingBottomNavigation() {
      return Container(
         margin: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
         height: 75,
         decoration: BoxDecoration(
           color: Colors.white,
           borderRadius: BorderRadius.circular(40),
           boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.15),
               blurRadius: 20,
               spreadRadius: 2,
               offset: const Offset(0, 5),
             ),
           ],
            border: Border.all(color: accentBrown.withOpacity(0.3), width: 1)
         ),
         child: ClipRRect(
           borderRadius: BorderRadius.circular(40),
           child: Row(
             mainAxisAlignment: MainAxisAlignment.spaceAround,
             children: [
               Expanded(child: _buildNavItemEnhanced(Icons.home_filled, Icons.home_outlined, 'Beranda', 0)),
               Expanded(child: _buildNavItemEnhanced(Icons.search_rounded, Icons.search_off_rounded, 'Cari', 1)),
               Expanded(child: _buildNavItemEnhanced(Icons.info_rounded, Icons.info_outline_rounded, 'Info', 2)),
               Expanded(child: _buildNavItemEnhanced(Icons.person_outline_rounded, Icons.person_outline, 'Profil', 3)), // Changed Icon and Label back to Profil
             ],
           ),
         ),
      );
   }

  // Enhanced Bottom Navigation Item (Remains the same)
  Widget _buildNavItemEnhanced(IconData selectedIcon, IconData unselectedIcon, String label, int index) {
    final bool isSelected = _currentTabIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutQuart,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _tabController.animateTo(index);
          },
          borderRadius: BorderRadius.circular(30),
          splashColor: primaryBrown.withOpacity(0.1),
          highlightColor: primaryBrown.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                 duration: const Duration(milliseconds: 200),
                 transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                 child: Icon(
                    isSelected ? selectedIcon : unselectedIcon,
                    key: ValueKey<bool>(isSelected),
                    color: isSelected ? secondaryBrown : iconColorInactive,
                    size: isSelected ? 28 : 26,
                  ),
              ),
              const SizedBox(height: 4),
              AnimatedDefaultTextStyle(
                 duration: const Duration(milliseconds: 200),
                 style: GoogleFonts.poppins(
                      color: isSelected ? secondaryBrown : iconColorInactive,
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                 ),
                 child: Text(
                   label,
                   overflow: TextOverflow.clip,
                   maxLines: 1,
                 ),
              ),
               AnimatedContainer(
                   duration: const Duration(milliseconds: 300),
                   height: isSelected ? 3.0 : 0.0,
                   width: isSelected ? 20.0 : 0.0,
                   margin: const EdgeInsets.only(top: 3),
                   decoration: BoxDecoration(
                       color: isSelected ? highlightOrange : Colors.transparent,
                       borderRadius: BorderRadius.circular(2),
                   ),
               )
            ],
          ),
        ),
      ),
    );
  }

}



// --- Placeholder for Image Asset ---
// Anda perlu menambahkan gambar placeholder di direktori assets Anda
// dan mendeklarasikannya di pubspec.yaml.
// Contoh:
// assets/images/placeholder.png

// --- Catatan Tambahan ---
// 1. Pastikan package `google_fonts` dan `carousel_slider` ditambahkan di `pubspec.yaml`.
//    dependencies:
//      flutter:
//        sdk: flutter
//      google_fonts: ^latest_version
//      carousel_slider: ^latest_version
// 2. Ganti URL gambar placeholder dan background dengan URL gambar Anda yang sebenarnya jika memungkinkan.
// 3. Ganti placeholder teks (seperti 'Nama Pengguna', email, jawaban FAQ) dengan data dinamis dari aplikasi Anda.
// 4. Anda mungkin perlu membuat direktori `assets/images` dan menambahkan file `placeholder.png` (atau nama lain) ke dalamnya.