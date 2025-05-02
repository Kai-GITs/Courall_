// ... existing imports
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  final String title;
  final String description;
  final String youtubeUrl;

  const CourseDetailPage({
    super.key,
    required this.title,
    required this.description,
    required this.youtubeUrl,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late YoutubePlayerController _youtubeController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final videoId = YoutubePlayer.convertUrlToId(widget.youtubeUrl) ?? '';
    _youtubeController = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getCourseSections(String title) {
    switch (title) {
      case 'Tari Berjenjang':
        return [
          {'title': 'Pengenalan Tari Berjenjang', 'duration': '10 Min'},
          {'title': 'Gerakan Dasar dan Makna', 'duration': '15 Min'},
          {'title': 'Kostum dan Musik Tradisional', 'duration': '8 Min'},
          {
            'title': 'Simbolisme dalam Upacara Pernikahan',
            'duration': '10 Min'
          },
        ];
      case 'Intro to Coding with Pak Amir':
        return [
          {'title': 'Apa itu MIT App Inventor?', 'duration': '5 Min'},
          {'title': 'Membuat Aplikasi Hello World', 'duration': '7 Min'},
          {'title': 'Simulasi & Uji Coba Aplikasi', 'duration': '10 Min'},
        ];
      default:
        return [
          {'title': 'Course Introduction', 'duration': '5 Min'},
          {'title': 'Main Content', 'duration': '10 Min'},
        ];
    }
  }

  String _getExtraDetails(String title) {
    switch (title) {
      case 'Tari Berjenjang':
        return '''
💃🏽 **Siapa yang menarikan?**
Masyarakat Desa Mentuda, khususnya kelompok adat setempat.

🎶 **Apa itu?**
Tari Berjenjang merupakan tari tradisional yang biasa ditampilkan saat upacara pernikahan Melayu. Menandakan penghormatan, sambutan, dan ikatan antara keluarga.

💔 **Mengapa ini hampir punah?**
Hanya dikenal oleh kalangan kecil di Lingga. Generasi muda jarang belajar, bahkan di luar Kepulauan Riau hampir tidak dikenal.

🌍 **Mengapa penting?**
Menjaga identitas budaya pesisir Melayu dan memperlihatkan kekayaan budaya Indonesia yang hangat dan bersahaja.
''';

      case 'Intro to Coding with Pak Amir':
        return '''
👨‍🏫 **Siapa pengajarnya?**
Pak Amir, programmer otodidak dari Halmahera Utara. Belajar melalui buku bekas dan modul offline.

💻 **Apa itu?**
Pelajaran 5 menit membangun aplikasi "Hello World" via MIT App Inventor — hanya dengan ponsel!

💔 **Mengapa ini diremehkan?**
Telah mengajar lebih dari 80 anak muda di desanya, namun metodenya belum dikenal luas.

🌍 **Mengapa penting?**
Membuktikan bahwa siapa pun bisa belajar coding tanpa laptop — cukup dengan rasa ingin tahu dan semangat belajar.
''';

      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBrown = const Color(0xFF8D6E63);
    final Color accentOrange = const Color(0xFFFFB74D);
    final courseSections = _getCourseSections(widget.title);
    final courseExtraInfo = _getExtraDetails(widget.title);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(widget.title,
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: primaryBrown,
            )),
        leading: const BackButton(color: Colors.brown),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Center(
              child: SizedBox(
                width: 720,
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: YoutubePlayer(
                      controller: _youtubeController,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.orange,
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(isExpanded: true),
                        const PlaybackSpeedButton(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryBrown,
              unselectedLabelColor: Colors.grey,
              indicatorColor: accentOrange,
              tabs: const [
                Tab(text: 'Course Content'),
                Tab(text: 'Discussion'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (var section in courseSections) ...[
                      Text(
                        section['title'],
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryBrown,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.timer, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(section['duration'],
                              style: GoogleFonts.poppins(
                                fontSize: 13,
                                color: Colors.grey[600],
                              )),
                          const Spacer(),
                          Icon(Icons.play_circle_outline,
                              size: 26, color: accentOrange),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Divider(height: 24, thickness: 1),
                    Text(
                      widget.description,
                      style: GoogleFonts.poppins(
                        fontSize: 14.5,
                        height: 1.6,
                        color: Colors.brown.shade800,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      courseExtraInfo,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.brown.shade700,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
                // Discussion tab
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _buildComment(
                      name: "Sarah W.",
                      text: "Kursus ini sangat bermanfaat!",
                      avatarUrl: 'https://picsum.photos/id/1005/200',
                      isAuthor: true,
                    ),
                    _buildComment(
                      name: "Poetri Lazuzardi",
                      text: "Terima kasih atas penjelasannya, sangat jelas.",
                      avatarUrl: 'https://picsum.photos/id/1011/200',
                      isAuthor: true,
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Add comment",
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        suffixIcon: const Icon(Icons.send, color: Colors.brown),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
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
    );
  }

  Widget _buildComment({
    required String name,
    required String text,
    required String avatarUrl,
    bool isAuthor = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(radius: 20, backgroundImage: NetworkImage(avatarUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Colors.blueAccent,
                        )),
                    const SizedBox(width: 6),
                    if (isAuthor)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF66BB6A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text("Author",
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w500)),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(text,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: Colors.black87,
                    )),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.thumb_up_alt_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text('1k',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey.shade600)),
                    const SizedBox(width: 16),
                    Text('Reply',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
