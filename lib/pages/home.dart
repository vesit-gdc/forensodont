import 'package:flutter/material.dart';
import 'package:forensodont/custom/constants.dart';
import 'package:forensodont/custom/navbar.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../custom/homecard.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static final id = 'home';

  Future<void> _launchSheet() async {
    final Uri url = Uri.parse(sheetLink);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Colors.white;
    final iconColor = Colors.indigo.shade700;

    return Scaffold(
        extendBody: true,
        appBar: AppBar(
          title: Text(
            'Forensodont',
            style: GoogleFonts.poppins(
              color: Colors.purple.shade900,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFF4F4F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushNamed(context, 'land'),
          ),
        ),
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/l_and_r_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                  child: GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    children: [
                      HomeCard(
                        icon: Icons.medical_services,
                        label: 'Dental\nExamination',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'data'),
                      ),
                      HomeCard(
                        icon: Icons.folder_shared,
                        label: 'Patient\nRecords',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => _launchSheet(),
                      ),
                      HomeCard(
                        icon: Icons.upload_file,
                        label: 'Extract\nRecords',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'rec'),
                      ),
                      HomeCard(
                        icon: Icons.search,
                        label: 'Forensic\nMatching',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'add'),
                      ),
                      HomeCard(
                        icon: Icons.feedback_outlined,
                        label: 'Feedback',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'sel'),
                      ),
                      HomeCard(
                        icon: Icons.history_edu,
                        label: 'Antemortem',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'grid'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: Navbar(initialIndex: 1,)
    );
  }
}