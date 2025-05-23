import 'package:flutter/material.dart';
import 'package:forensodont/custom/constants.dart';
import 'package:forensodont/custom/navbar.dart';
import 'package:forensodont/pages/dental_examination.dart';
import 'package:forensodont/pages/patient_records.dart';
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

  Future<void> _launchForm() async {
    final Uri url = Uri.parse('https://docs.google.com/forms/d/e/1FAIpQLSdTmcnt4Q8VOlgkB8wZ8zHH5AZfDs9Ug2SySry04jCXC2LSmQ/viewform?usp=header');
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
                        onTap: () => Navigator.pushNamed(context, DentalExamination.id),
                      ),
                      HomeCard(
                        icon: Icons.folder_shared,
                        label: 'Patient\nRecords',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => _launchSheet(),
                      ),
                      HomeCard(
                        icon: Icons.upload_file_rounded,
                        label: 'Extract\nRecords',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, Records.id),
                      ),
                      HomeCard(
                        icon: Icons.person_search_rounded,
                        label: 'Forensic\nMatching',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => Navigator.pushNamed(context, 'add'),
                      ),
                      HomeCard(
                        icon: Icons.feedback,
                        label: 'Feedback',
                        color: cardColor,
                        iconColor: iconColor,
                        onTap: () => _launchForm(),
                      ),
                      HomeCard(
                        icon: Icons.assessment,
                        label: 'Postmortem',
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