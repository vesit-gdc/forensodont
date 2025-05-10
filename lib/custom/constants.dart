import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final cForensodont = GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold);

final cSubheading = TextStyle(
    color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 25);

final sheetLink =
    'https://docs.google.com/spreadsheets/d/1aC87BfHUvI3dUHcY9DJUcumyBl9HT0I4K5rO48HpAcA/edit?gid=2123889636#gid=2123889636';

line(Color color)
{
  return Container(
    width: 100,
    height: 1,
    decoration: BoxDecoration(
      border: Border.all(color: color)
    ),
  );
}

final profileGap = SizedBox(
  height: 10,
);