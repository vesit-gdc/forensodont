import 'package:flutter/material.dart';
import 'package:forensodont/pages/credentials/login.dart';
import 'package:forensodont/pages/credentials/register.dart';
import 'package:google_fonts/google_fonts.dart';
import '../custom/thisButton.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  static final id = 'landing';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: AssetImage(
                    'assets/landing_bg.jpg',
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: MediaQuery.of(context).size.height*0.7,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/colleges_logo.png'),
                  Text(
                    'Forensodont',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 46.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Center(
                      child: Text(
                        'An Initiative under GDC & VESIT Collaboration',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  CustomButton(text: 'I have an Account', onPressed: () {
                    Navigator.pushNamed(context, LoginPage.id);
                  }),
                  CustomButton(text: 'Create a New Account', onPressed: () {
                    Navigator.pushNamed(context, RegisterPage.id);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
