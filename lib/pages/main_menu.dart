import 'dart:ui';
import 'package:courall/pages/lesson_card.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

// Replace with your actual YouTube Data API key
const String apiKey =
    ''; // GANTI DENGAN API KEY VALID ANDA

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<MainMenu> createState() => _MainMenuRevisedState();
}

Future<void> openCommunication(String type, String target) async {
  String url;
  switch (type) {
    case 'email':
      url = 'mailto:$target'
          '?subject=${Uri.encodeComponent("Bantuan Courall")}'
          '&body=${Uri.encodeComponent("Halo Courall,\nsaya butuh bantuan…")}';
      break;
    case 'whatsapp':
      final phone = target.replaceAll(RegExp(r'[^0-9]'), '');
      url =
          'https://wa.me/$phone?text=${Uri.encodeComponent("Halo Courall, saya butuh bantuan.")}';
      break;
    case 'line':
      final user = target.startsWith('@') ? target.substring(1) : target;
      url = 'https://line.me/R/ti/p/$user';
      break;
    default:
      return;
  }

  final uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
    return;
  }

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.inAppWebView);
    return;
  }

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
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: body,
            ),
          ),
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

class _MainMenuRevisedState extends State<MainMenu>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final cs.CarouselSliderController _carouselController =
      cs.CarouselSliderController();
  int _currentCarouselPage = 0;
  int _currentTabIndex = 0;
  String _searchQuery = '';
  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  static const Color primaryBrown = Color(0xFF8D6E63);
  static const Color secondaryBrown = Color(0xFF5D4037);
  static const Color accentBrown = Color(0xFFBCAAA4);
  static const Color backgroundNeutral = Color(0xFFF8F8F8);
  static const Color highlightOrange = Color(0xFFFFB74D);
  static const Color darkerhighlightOrange = Color.fromARGB(200, 255, 184, 77);

  static const Color textDarkBrown = Color(0xFF3E2723);
  static const Color textLight = Colors.white;
  static const Color textMedium = Color(0xFF757575);
  static const Color iconColorInactive = Color(0xFFAC8F84);
  static const Color successGreen = Color(0xFF66BB6A);
  static const Color errorRed = Color(0xFFE57373);

  final List<String> carouselImages = [
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189891/mahmur-marganti-8Bg8N8HtiWI-unsplash_hytoat.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189888/claudio-schwarz-fyeOxvYvIyY-unsplash_t3znsk.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189886/tra-nguyen-TVSRWmnW8Us-unsplash_jj5c8z.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189880/ainun-jamila-nwpGRTdDQRQ-unsplash_ms6wc2.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189887/polina-kuzovkova-yNPM6RN1RBw-unsplash_lgidwg.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189880/dhan-3ivwcy4mVmg-unsplash_nfq7mc.jpg',
    'https://res.cloudinary.com/dkpniycdb/image/upload/v1746189882/shaggy-sirep-m-hweLAVst0-unsplash_snchj4.jpg',
  ];

  final List<Map<String, String>> featuredLessons = [
    {
      'title': 'Tari Berjenjang',
      'description': 'Performed during Malay wedding ceremonies.',
      'tentang': '''
💃🏽 **Siapa yang menarikan?**  
Masyarakat Desa Mentuda, khususnya oleh kelompok-kelompok seni tradisional lokal.

🎶 **Apa itu?**  
Tari Berjenjang adalah tarian yang ditampilkan dalam upacara pernikahan tradisional Melayu. Tarian ini melambangkan keramahan, rasa hormat, dan hubungan antar keluarga. Para penari bergerak anggun dalam formasi "berjenjang", mengenakan busana tradisional yang penuh warna.

💔 **Mengapa kurang dikenal?**  
Tari ini hampir punah, hanya dikenal di kalangan kecil di Lingga. Generasi muda jarang mempelajarinya, dan di luar Kepulauan Riau, sangat sedikit orang yang tahu keberadaannya.

🌍 **Mengapa penting?**  
Tari ini melestarikan identitas budaya dan nilai-nilai keramahan masyarakat Melayu pesisir, sekaligus memperlihatkan kekayaan dan kehangatan tradisi Indonesia yang jarang tersorot oleh wisata arus utama.
''',
      'category': 'Tarian',
      'region': 'Mentuda Village - Riau Islands, Indonesia',
      'image': 'assets/tarian.jpg'
    },
    {
      'title': 'Belajar Trigonometri with Kak Anwar',
      'description': 'Pelajari trigonometri dengan mudah.',
      'tentang': ''' 📐 Belajar Trigonometri Dasar – bersama Kak Anwar dari Bone
👨🏽‍🏫 Siapa pengajarnya? Kak Anwar, guru honorer di sebuah sekolah desa kecil di Bone, Sulawesi Selatan, yang mengajar matematika dengan metode sederhana.

📚 Apa yang diajarkan? Kursus 5 menit yang menjelaskan konsep dasar trigonometri — mengenal sinus, cosinus, dan tangen melalui ilustrasi segitiga sederhana menggunakan alat seadanya seperti papan tulis kayu.

💔 Kenapa kurang dikenal? Di banyak daerah pedesaan, trigonometri terasa “menakutkan” karena minimnya alat bantu visual modern. Metode pengajaran kreatif seperti yang dilakukan Kak Anwar jarang terekspose.

🌍 Kenapa penting? Kursus ini membuktikan bahwa matematika bisa diajarkan dengan sederhana dan dekat dengan keseharian, memperluas akses pendidikan bermutu bagi siswa di daerah terpencil. ''',
      'category': 'Matematika',
      'region': 'Bone - Sulawesi Selatan, Indonesia',
      'image': 'assets/trigonometry.jpg'
    },
    {
      'title': 'Intro to Coding with Pak Amir',
      'description': 'Belajar dasar-dasar Pemrograman.',
      'tentang':
          ''' 🌐 Pengantar Koding bersama Pak Amir – Halmahera Utara, Indonesia
👨‍🏫 Siapa pengajarnya? Pak Amir, seorang programmer otodidak dari desa pesisir di Halmahera Utara yang belajar koding dari buku bekas dan modul offline.

💻 Apa itu? Sebuah pelajaran koding berdurasi 5 menit yang ramah untuk pemula, menggunakan ponsel dan bukan laptop — menunjukkan cara membuat aplikasi "Hello World" interaktif pertamamu dengan MIT App Inventor (alat koding visual berbasis drag-and-drop).

💔 Kenapa ini kurang dikenal: Pak Amir telah mengajarkan lebih dari 80 anak muda di desanya, banyak di antaranya belum pernah menyentuh komputer. Namun metodenya masih belum dikenal luas dan ia kekurangan sumber daya untuk memperluas jangkauan.

🌍 Kenapa ini penting: Pembelajar di mana pun (bahkan dengan internet terbatas) bisa terinspirasi oleh perjalanannya. Kursus ini membuktikan bahwa kamu tidak butuh peralatan canggih untuk mulai belajar koding — cukup rasa ingin tahu dan akses. Inisiatif ini membantu menjembatani kesenjangan pendidikan teknologi dari bawah ke atas. ''',
      'category': 'Programming',
      'region': 'North Halmahera, Indonesia',
      'image': 'assets/coding.jpeg'
    },
    {
      'title': 'Belajar Bahasa Abui with Ama Berto',
      'description':
          'Mengenal bahasa Abui, mulai dari salam, sapaan keluarga, hingga ekspresi sehari-hari.',
      'tentang':
          ''' 👴🏽 Siapa pengajarnya? Ama Berto, seorang tetua adat dan pendongeng tradisional dari Desa Takalelang, Pulau Alor, Nusa Tenggara Timur.

📚 Apa yang diajarkan? Pelajaran singkat 5 menit untuk mengenal bahasa Abui, mulai dari salam, sapaan keluarga, hingga ekspresi sehari-hari — disampaikan lewat gaya bercerita khas di dekat api unggun, dengan pelafalan asli.

💔 Kenapa kurang dikenal? Bahasa Abui hanya dituturkan oleh kurang dari 20.000 orang, dan tidak diajarkan di sekolah formal. Banyak generasi muda beralih ke Bahasa Indonesia, sehingga bahasa ini terancam punah.

🌍 Kenapa penting? Kursus ini membantu menghidupkan kembali pengetahuan leluhur, memperkuat kebanggaan budaya lokal di wilayah timur Indonesia, dan memberikan pengalaman belajar yang otentik langsung dari penutur aslinya.

''',
      'category': 'Bahasa',
      'region': 'Desa Takalelang - Nusa Tenggara Timur, Indonesia',
      'image': 'assets/abui.jpg'
    },
    {
      'title': 'Masak Kapurung Khas Luwu',
      'description': 'Sagu yang disiram kuah ikan dan sayuran.',
      'tentang':
          ''' 👩🏽‍🍳 Siapa pengajarnya? Ibu Sitti, ibu rumah tangga sekaligus juru masak komunitas dari Desa Malangke, Luwu, Sulawesi Selatan.

🧂 Apa yang diajarkan? Dalam waktu 5 menit, Ibu Sitti menunjukkan cara membuat Kapurung, makanan khas Luwu dari sagu yang disiram kuah ikan dan sayuran. Ia menggunakan alat dapur tradisional dan bahan lokal.

💔 Kenapa kurang dikenal? Kapurung jarang ditemukan di luar Sulawesi Selatan, dan dianggap “rumahan” meski kaya gizi serta budaya. Banyak orang muda bahkan tak tahu cara mengolah sagu secara benar.

🌍 Kenapa penting? Kursus ini memperkenalkan makanan berbasis sagu yang ramah lingkungan, menonjolkan kekayaan kuliner Indonesia Timur, dan memberi peluang ekonomi bagi ibu-ibu desa dengan keahlian masak tradisional. ''',
      'category': 'Memasak',
      'region': 'Luwu - Sulawesi Selatan, Indonesia',
      'image': 'assets/batik.png'
    },
  ];

  final List<String> searchRecommendations = [
    'Cara set up Flutter dan Firebase',
    'Gemini AI',
    'Fasilkom UI',
    'Membuat Batik',
    'Courall',
    'Fermat Little Theorem',
    'Multivariable Calculus',
    'Analisis Data dengan Python',
    'Machine Learning Dasar',
    'Konsep Pasar',
  ];

  final String batikPatternOverlay =
      'https://www.transparenttextures.com/patterns/batthern.png';
  final String batikHeaderBackground =
      'https://img.freepik.com/free-vector/modern-geometric-batik-pattern-background_110029-83.jpg?w=996';
  final String infoBackground =
      'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?ixlib=rb-4.0.3&auto=format&fit=crop&w=1170&q=80';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

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

  Widget _buildHomeTab() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 77.0,
          floating: true,
          pinned: true,
          snap: true,
          backgroundColor: secondaryBrown,
          elevation: 8.0,
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 9, right: 60),
            title: RichText(
              text: TextSpan(
                style: GoogleFonts.playfairDisplay(
                  textStyle: const TextStyle(
                    color: textLight,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    shadows: [
                      Shadow(
                          offset: Offset(0, 1),
                          blurRadius: 3,
                          color: Colors.black54)
                    ],
                  ),
                ),
                children: const [
                  TextSpan(text: 'Selamat Datang,\n'),
                  TextSpan(
                      text: 'Pembelajar Hebat!',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
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
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(batikHeaderBackground),
                      fit: BoxFit.cover,
                      opacity: 0.1,
                      colorFilter: ColorFilter.mode(
                          secondaryBrown.withOpacity(0.5), BlendMode.darken),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.0),
                        Colors.black.withOpacity(0.5)
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ],
            ),
            stretchModes: const [
              StretchMode.zoomBackground,
              StretchMode.fadeTitle
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  CircleAvatar(
                    backgroundColor: highlightOrange.withOpacity(0.95),
                    radius: 22,
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_outlined,
                          color: textDarkBrown, size: 24),
                      onPressed: () {},
                      tooltip: 'Notifikasi',
                    ),
                  ),
                  Positioned(
                    right: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: errorRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Center(
                        child: Text(
                          '3',
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
        SliverList(
          delegate: SliverChildListDelegate(
            [
              const SizedBox(height: 30),
              cs.CarouselSlider.builder(
                carouselController: _carouselController,
                options: cs.CarouselOptions(
                  height: 245,
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.88,
                  initialPage: 0,
                  enableInfiniteScroll: true,
                  reverse: false,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 5),
                  autoPlayAnimationDuration: const Duration(milliseconds: 1200),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  enlargeFactor: 0.25,
                  scrollDirection: Axis.horizontal,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentCarouselPage = index;
                    });
                  },
                ),
                itemCount: carouselImages.length,
                itemBuilder: (context, index, realIndex) {
                  final actualIndex = index % carouselImages.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    decoration: BoxDecoration(
                      color: accentBrown.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.18),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 7),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FadeInImage.assetNetwork(
                            placeholder: 'assets/images/placeholder.png',
                            image: carouselImages[actualIndex],
                            fit: BoxFit.cover,
                            imageErrorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: accentBrown.withOpacity(0.5),
                                child: const Center(
                                    child: Icon(Icons.broken_image_outlined,
                                        color: textMedium, size: 40)),
                              );
                            },
                          ),
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.2),
                                  Colors.black.withOpacity(0.85),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 20,
                            left: 20,
                            right: 20,
                            child: Text(
                              'Program Peduli #${actualIndex + 1}: Ayo peduli, salurkan donasi!',
                              style: GoogleFonts.poppins(
                                textStyle: const TextStyle(
                                  color: textLight,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 4,
                                        color: Colors.black87)
                                  ],
                                ),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
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
                        width: _currentCarouselPage == index ? 22 : 8,
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
              Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 7),
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
                            'Mendapatkan badge spesial khusus buat kamu! Sebagai bentuk mendukung kami untuk terus memberikan kursus-kursus berkualitas tinggi.',
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
                            onPressed: () {
                              CustomModal.show(
                                context: context,
                                title: 'Beli Hiasan Lokal dari Para Pengajar! ',
                                body: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('✨ Diskon 50% untuk semua hiasan ',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(height: 8),
                                    Text('Berlaku sampai 30 Mei 2025.'),
                                    SizedBox(height: 16),
                                    Text('✨ Gratis e-book Flutter',
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(height: 8),
                                    Text('Unduh setelah mendaftar.'),
                                  ],
                                ),
                              );
                            },
                            icon:
                                const Icon(Icons.star_border_rounded, size: 18),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
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
                        border: Border.all(
                            color: textLight.withOpacity(0.5), width: 2),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    return GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: featuredLessons.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio:
                            isMobile ? 0.63 : 0.70, // Lower ratio for mobile
                      ),
                      itemBuilder: (context, index) {
                        final lesson = featuredLessons[index];
                        return LessonCard(
                          title: lesson['title']!,
                          description: lesson['description']!,
                          tentang: lesson['tentang']!,
                          category: lesson['category']!,
                          region: lesson['region']!,
                          imagePath: lesson['image']!,
                          rating: 4.5,
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 35, 20, 20),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    image: const DecorationImage(
                      image: NetworkImage(
                          'https://img.freepik.com/free-photo/business-people-meeting_53876-88834.jpg'),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          child: Text(
                            'Courall : Kita untuk Semua',
                            style: GoogleFonts.playfairDisplay(
                              textStyle: const TextStyle(
                                color: textLight,
                                fontWeight: FontWeight.bold,
                                fontSize: 22,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                      offset: Offset(0, 1),
                                      blurRadius: 4,
                                      color: Colors.black87)
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.play_circle_outline,
                                  size: 20),
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
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 18, vertical: 11),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30)),
                                elevation: 5,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: textLight.withOpacity(0.2),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: textLight.withOpacity(0.4),
                                    width: 1),
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
              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }

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
        border: Border.all(color: accentBrown.withOpacity(0.3), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {},
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
        SliverAppBar(
          expandedHeight: 100.0,
          floating: true,
          pinned: false,
          snap: true,
          backgroundColor: primaryBrown,
          elevation: 4.0,
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: false,
            titlePadding:
                const EdgeInsets.only(left: 20, bottom: 32, right: 20),
            title: Text(
              'Temukan Kursus Impianmu !',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: textLight,
                fontSize: 19,
                shadows: [
                  Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black45)
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        primaryBrown.withOpacity(0.9),
                        secondaryBrown.withOpacity(1.0),
                      ],
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(batikPatternOverlay),
                      fit: BoxFit.cover,
                      opacity: 0.08,
                      colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.2), BlendMode.darken),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -30,
                  right: -20,
                  child: Icon(Icons.search_rounded,
                      size: 120, color: textLight.withOpacity(0.05)),
                ),
              ],
            ),
            stretchModes: const [StretchMode.zoomBackground],
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding:
                const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 5),
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
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (_isSearching)
                Center(child: CircularProgressIndicator(color: primaryBrown)),
              if (_searchResults.isNotEmpty)
                ..._searchResults
                    .map((video) => _buildVideoCard(video))
                    .toList(),
              if (_searchResults.isEmpty &&
                  !_isSearching &&
                  _searchQuery.isNotEmpty)
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
      ],
    );
  }

  Widget _buildVideoCard(dynamic video) {
    final videoId = video['id']['videoId'] ?? '';
    final thumbUrl = video['snippet']['thumbnails']['medium']['url'] ?? '';
    final title = video['snippet']['title'] ?? 'No Title';
    final author = video['snippet']['channelTitle'] ?? 'Unknown';

    if (videoId.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: () {
          print('Playing video ID: $videoId'); // Debug video ID
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar:
                    AppBar(title: Text(title), backgroundColor: secondaryBrown),
                body: YoutubePlayer(
                  controller: YoutubePlayerController(
                    initialVideoId: videoId,
                    flags: YoutubePlayerFlags(
                      autoPlay: true,
                      disableDragSeek: true,
                    ),
                  ),
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: highlightOrange,
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
                    title,
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
                        author,
                        style: GoogleFonts.poppins(
                            color: textMedium, fontSize: 12),
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
            Uri.parse(
                'https://www.googleapis.com/youtube/v3/search?part=snippet&q=$query&type=video&maxResults=20&key=$apiKey'),
          )
          .timeout(Duration(seconds: 10)); // Tambah timeout 10 detik

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> items = data['items'];
        print('API Response Items: ${json.encode(items)}'); // Debug response
        // Filter dihapus untuk menampilkan semua hasil
        setState(() {
          _searchResults = items; // Tampilkan semua hasil tanpa filter
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
          children: searchRecommendations
              .map((query) => ActionChip(
                    label: Text(query),
                    onPressed: () {
                      _searchController.text = query;
                      _performSearch(query);
                    },
                    backgroundColor: backgroundNeutral,
                    labelStyle: GoogleFonts.poppins(color: primaryBrown),
                  ))
              .toList(),
        ),
        SizedBox(height: 30),
      ],
    );
  }

  Widget _buildInfoTab() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(infoBackground),
          fit: BoxFit.cover,
          opacity: 0.05,
          colorFilter: ColorFilter.mode(
              backgroundNeutral.withOpacity(0.8), BlendMode.dstATop),
        ),
      ),
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            floating: false,
            backgroundColor: backgroundNeutral.withOpacity(0.8),
            elevation: 1.0,
            scrolledUnderElevation: 3.0,
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
              delegate: SliverChildListDelegate([
                Container(
                  margin: const EdgeInsets.only(bottom: 25),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                        color: accentBrown.withOpacity(0.4), width: 1),
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
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryBrown),
                            ),
                            TextSpan(
                              text:
                                  'adalah platform dari masyarakat kepada masyrakat yang mewujudkan impian belajar ini — menawarkan micro-lesson (pelajaran singkat) gratis dan sederhana yang diajarkan oleh ahli lokal dari seluruh dunia, langsung dari komunitas mereka ke komunitas Anda. Dan yang seru, Anda bisa berinteraksi dengan mereka!"',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Divider(color: accentBrown.withOpacity(0.5)),
                      const SizedBox(height: 20),
                      _buildInfoHighlight(
                        Icons.lightbulb_outline_rounded,
                        'Misi Kami',
                        'Menyediakan akses mudah ke pengetahuan dan keterampilan relevan untuk kesuksesan personal dan profesional, serta memberdayakan dan menguatkan komunitas lokal.',
                        primaryBrown,
                      ),
                      const SizedBox(height: 15),
                      _buildInfoHighlight(
                        Icons.favorite_border_rounded,
                        'Nilai Kami',
                        'Inovasi, Kualitas, Aksesibilitas, Komunitas.',
                        primaryBrown,
                      ),
                    ],
                  ),
                ),
                _buildSectionTitle(
                    'Fitur Unggulan', Icons.featured_play_list_outlined),
                const SizedBox(height: 15),
                _buildFeatureItem(
                  'Kurikulum Terstruktur',
                  'Materi pembelajaran dirancang secara sistematis.',
                  Icons.list_alt_rounded,
                  highlightOrange,
                ),
                _buildFeatureItem(
                  'Pembelajaran Gratis',
                  'Belajar kursus berkualitas tanpa khawatir dengan biaya.',
                  Icons.money,
                  darkerhighlightOrange,
                ),
                _buildFeatureItem(
                  'Kursus Lokal',
                  'Akses materi mulai dari sabang sampai merauke',
                  Icons.devices_rounded,
                  highlightOrange,
                ),
                _buildFeatureItem(
                  'Sertifikat Penyelesaian',
                  'Validasi pencapaian belajar Anda.',
                  Icons.workspace_premium_outlined,
                  darkerhighlightOrange,
                ),
                const SizedBox(height: 30),
                _buildSectionTitle(
                    'Pertanyaan Umum (FAQ)', Icons.help_outline_rounded),
                const SizedBox(height: 15),
                _buildFaqExpansionTile('Bagaimana cara memulai kursus?',
                    'Pilih kursus yang ingin Anda pelajari dan tekan tombol “Learn” untuk mulai belajar. Tidak perlu mendaftar, semua gratis!'),
                _buildFaqExpansionTile('Apakah saya mendapatkan sertifikat?',
                    'Kamu akan mendapatkan setifikat jika kamu menyelesaikan video course dan mencapai nilai minimal 55 dalam 1 course. Semangat belajar!'),
                _buildFaqExpansionTile('Bisakah saya mengunduh materi?',
                    'Ya anda dapat mengunduh materi'),
                _buildFaqExpansionTile('Mengapa Courall tidak perlu bayar?',
                    'Karena Courall dibuat sebagai platform pembelajaran berbasis komunitas dari masyarakat untuk masyarakat. Pemasukan yang dihasilkan dari donasi dan iklan akan dituju untuk para pengajar lokal dan biaya operasi platform. '),
                _buildFaqExpansionTile('Courall work in progress!',
                    'Courall adalah platform yang masih dalam tahap pengembangan. Kursus pembelajaran yang ditayangkan itu hanya sebagai landasan, kursus sebetulnya akan dibuat oleh orang-orang lokal asli!  Kami berkomitmen untuk terus meningkatkan pengalaman belajar Anda.'),
                const SizedBox(height: 30),
                _buildSectionTitle(
                    'Hubungi Kami', Icons.contact_support_outlined),
                const SizedBox(height: 15),
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
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildInfoHighlight(
      IconData icon, String title, String text, Color iconColor) {
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

  Widget _buildInfoCardBase(
      String title, String subtitle, IconData icon, Color themeColor,
      {VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
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
          onTap: onTap,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (onTap != null)
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: themeColor.withOpacity(0.7), size: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
      String title, String description, IconData icon, Color color) {
    return _buildInfoCardBase(title, description, icon, color);
  }

  Widget _buildContactCard(
      String title, String info, IconData icon, Color color) {
    VoidCallback? onTapAction;
    String type = '';
    if (icon == Icons.email_outlined)
      type = 'email';
    else if (icon == Icons.support_agent_rounded)
      type = 'whatsapp';
    else if (icon == Icons.language_outlined) type = 'line';

    if (type.isNotEmpty) {
      onTapAction = () => openCommunication(type, info).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Tidak dapat membuka link: $e',
                      style: GoogleFonts.poppins()),
                  backgroundColor: errorRed),
            );
          });
    }

    return _buildInfoCardBase(info, title, icon, color, onTap: onTapAction);
  }

  Widget _buildFaqExpansionTile(String question, String answer) {
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
              answer,
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          floating: false,
          backgroundColor: backgroundNeutral,
          elevation: 1.0,
          scrolledUnderElevation: 3.0,
          shadowColor: primaryBrown.withOpacity(0.3),
          centerTitle: false,
          title: Text(
            'Profil & Pengaturan',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: secondaryBrown,
              fontSize: 20,
            ),
          ),
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
            delegate: SliverChildListDelegate([
              _buildUserProfileHeader(),
              const SizedBox(height: 25),
              _buildSectionTitle(
                  'Pengaturan Akun', Icons.manage_accounts_outlined),
              const SizedBox(height: 15),
              _buildSettingsItem('Edit Profil', Icons.person_outline_rounded,
                  () {
                CustomModal.show(
                  context: context,
                  title: 'Profil',
                  body: Center(
                      child: Text('KERJAKAN EDWARD.',
                          style: GoogleFonts.poppins())),
                  maxHeightFactor: 0.2,
                );
              }),
              _buildSettingsItem(
                  'Kelola Notifikasi', Icons.notifications_none_rounded, () {
                CustomModal.show(
                  context: context,
                  title: 'Pengaturan Notifikasi',
                  body: Center(
                      child: Text('Fitur ini belum tersedia.',
                          style: GoogleFonts.poppins())),
                  maxHeightFactor: 0.2,
                );
              }),
              _buildSettingsItem(
                  'Riwayat Pembelajaran', Icons.history_edu_outlined, () {
                CustomModal.show(
                  context: context,
                  title: 'Riwayat',
                  body: Text(
                    'Riwayat anda tidak ada atau belum terdaftar pada database kami. ',
                  ),
                  maxHeightFactor: 0.2,
                );
              }),
              _buildSettingsItem(
                  'Sertifikat Saya', Icons.card_membership_outlined, () {
                CustomModal.show(
                  context: context,
                  title: 'Sertifikat Saya',
                  body: Text(
                    'Anda belum memenuhi syarat untuk klaim sertifikat apa pun. ',
                  ),
                  maxHeightFactor: 0.2,
                );
              }),
              const SizedBox(height: 30),
              _buildSectionTitle('Preferensi Aplikasi', Icons.tune_outlined),
              const SizedBox(height: 15),
              _buildSettingsItem('Tampilan & Tema', Icons.color_lens_outlined,
                  () {
                CustomModal.show(
                  context: context,
                  title: 'Tampilan & Tema',
                  body: Center(
                      child: Text('Akan Datang!',
                          style: GoogleFonts.poppins(fontSize: 16))),
                );
              }),
              _buildSettingsItem(
                  'Aksesibilitas', Icons.accessibility_new_rounded, () {
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
              _buildSectionTitle(
                  'Bantuan & Informasi', Icons.help_center_outlined),
              const SizedBox(height: 15),
              _buildSettingsItem('Pusat Bantuan (FAQ)', Icons.quiz_outlined,
                  () {
                _tabController.animateTo(2);
              }),
              _buildSettingsItem('Tentang Courall', Icons.info_outline_rounded,
                  () {
                CustomModal.show(
                  context: context,
                  title: 'Tentang Courall',
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Courall v0.1.0',
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text(
                          'Platform e-learning inovatif untuk semua kalangan.'),
                      SizedBox(height: 12),
                      Text('© 2025 Courall'),
                    ],
                  ),
                  maxHeightFactor: 0.28,
                );
              }),
              _buildSettingsItem('Kebijakan Privasi', Icons.shield_outlined,
                  () {
                CustomModal.show(
                  context: context,
                  title: 'Kebijakan Privasi',
                  body: Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 4),
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
              _buildLogoutButton(),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildUserProfileHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBrown.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(color: accentBrown.withOpacity(0.4), width: 1),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: accentBrown.withOpacity(0.5),
                backgroundImage:
                    const NetworkImage('https://picsum.photos/200'),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: successGreen,
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
                  'Edward Worang',
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
                  'edwardCSUI@gmail.com',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: textMedium,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: highlightOrange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                        color: highlightOrange.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    'Member Premium',
                    style: GoogleFonts.poppins(
                      color: highlightOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            color: primaryBrown,
            tooltip: 'Edit Profil',
            iconSize: 22,
          ),
        ],
      ),
    );
  }

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

  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: errorRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: errorRed.withOpacity(0.4), width: 1),
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
            showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  title: Text('Konfirmasi Keluar',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold, color: secondaryBrown)),
                  content: Text('Apakah Anda yakin ingin keluar dari akun?',
                      style: GoogleFonts.poppins(color: textMedium)),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Batal',
                          style: GoogleFonts.poppins(color: textMedium)),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Keluar',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold, color: errorRed)),
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        print('Logout action triggered');
                      },
                    ),
                  ],
                );
              },
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
                Icon(Icons.logout_rounded, color: errorRed, size: 22),
                const SizedBox(width: 12),
                Text(
                  'Keluar dari Akun',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: errorRed,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        border: Border.all(color: accentBrown.withOpacity(0.3), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
                child: _buildNavItemEnhanced(
                    Icons.home_filled, Icons.home_outlined, 'Beranda', 0)),
            Expanded(
                child: _buildNavItemEnhanced(
                    Icons.search_rounded, Icons.search_off_rounded, 'Cari', 1)),
            Expanded(
                child: _buildNavItemEnhanced(
                    Icons.info_rounded, Icons.info_outline_rounded, 'Info', 2)),
            Expanded(
                child: _buildNavItemEnhanced(Icons.person_outline_rounded,
                    Icons.person_outline, 'Profil', 3)),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItemEnhanced(
      IconData selectedIcon, IconData unselectedIcon, String label, int index) {
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
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
