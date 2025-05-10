import 'package:flutter/material.dart';
import 'package:forensodont/custom/navbar.dart';
import 'package:google_fonts/google_fonts.dart';

class About extends StatelessWidget {
  const About({super.key});

  static final id = 'about';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
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
        elevation: 2,
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top + kToolbarHeight,
          bottom: 100,
          left: 30,
          right: 30,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/colleges_logo.png'),
            const SizedBox(height: 50),
            Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(190),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'About Forensodont',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'The Government Dental College and Hospital, Mumbai, a premier institution dedicated to advanced dental education and patient care, has collaborated with the innovative and esteemed Vivekanand Education Society\'s Institute of Technology to develop \'Forensodont\', a specialized app designed to assist doctors and forensic experts in identifying individuals through dental records.\n\n'
                          'It allows the user to upload post-mortem images, while doctors provide antemortem dental radiographs and other details. This app securely stores this data and utilizes deep learning to compare images, streamlining the identification process.',
                      textAlign: TextAlign.justify,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Additional visual element
                    Container(
                      height: 4,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.purple.shade900,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Navbar(initialIndex: 0),
    );
  }
}