import 'dart:convert';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forensodont/custom/thisButton.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis/drive/v3.dart' as drive;

import '../custom/checkbox.dart';
import '../custom/color_grid.dart';
import '../custom/dropdown.dart';
import '../custom/image_upload_button.dart';
import '../custom/mytextfield.dart';
import '../custom/text_label.dart';


class DentalExamination extends StatefulWidget {
  static const String id = 'dental';
  const DentalExamination({super.key});

  @override
  State<DentalExamination> createState() => _DentalExaminationState();
}

class _DentalExaminationState extends State<DentalExamination> {
  TextEditingController date = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController opg = TextEditingController();
  TextEditingController bitewing = TextEditingController();
  TextEditingController lateralceph = TextEditingController();
  TextEditingController cbct = TextEditingController();
  TextEditingController ct = TextEditingController();
  TextEditingController mri = TextEditingController();
  TextEditingController usg = TextEditingController();
  TextEditingController anyOther = TextEditingController();
  TextEditingController dob = TextEditingController();
  TextEditingController gender = TextEditingController();
  TextEditingController reg = TextEditingController();
  TextEditingController address = TextEditingController();
  TextEditingController aadhar = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController complaint = TextEditingController();
  TextEditingController dentPrimary = TextEditingController();
  TextEditingController dentMixed = TextEditingController();
  TextEditingController dentPerm = TextEditingController();
  TextEditingController decayed = TextEditingController();
  TextEditingController amalgam = TextEditingController();
  TextEditingController composite = TextEditingController();
  TextEditingController gold = TextEditingController();
  TextEditingController rct = TextEditingController();
  TextEditingController missing = TextEditingController();
  TextEditingController attrition = TextEditingController();
  TextEditingController abrasion = TextEditingController();
  TextEditingController erosion = TextEditingController();
  TextEditingController abfraction = TextEditingController();
  TextEditingController toothSize = TextEditingController();
  TextEditingController toothShape = TextEditingController();
  TextEditingController toothNumber = TextEditingController();
  TextEditingController toothStruc = TextEditingController();
  TextEditingController toothMal = TextEditingController();
  TextEditingController lipPalates = TextEditingController();
  TextEditingController oralMucosa = TextEditingController();
  TextEditingController gingiva = TextEditingController();
  TextEditingController jaws = TextEditingController();
  TextEditingController tongue = TextEditingController();
  TextEditingController crown = TextEditingController();
  TextEditingController implant = TextEditingController();
  TextEditingController removableFixed = TextEditingController();
  TextEditingController partialComplete = TextEditingController();
  TextEditingController maxillaMandible = TextEditingController();
  TextEditingController other = TextEditingController();
  TextEditingController iopa = TextEditingController();
  TextEditingController studyCast = TextEditingController();
  TextEditingController palatoscopy = TextEditingController();
  TextEditingController lipPrint = TextEditingController();
  TextEditingController tonguePrint = TextEditingController();
  TextEditingController diagnosis = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String thisDate = '';
  String thisDOB = '';

  Future<void> _selectDate(BuildContext context, TextEditingController controller, Function(String) updateState) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        String formattedDate = "${picked.day}/${picked.month}/${picked.year}";
        updateState(formattedDate);
        controller.text = formattedDate;
      });
    }
  }

  Future<void> copyImagesToDrive({
    required List<TextEditingController> imageUrlControllers,
    required TextEditingController nameController,
    required TextEditingController dateController,
  }) async {
    try {
      // Load service account credentials
      final serviceAccountJson = await rootBundle.loadString('assets/service-account.json');
      final credentials = ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

      // Authenticate with service account
      final client = await clientViaServiceAccount(
        credentials,
        [drive.DriveApi.driveFileScope],
      );

      final driveApi = drive.DriveApi(client);

      // Determine target folder ID and file name based on name field
      final hasName = nameController.text.trim().isNotEmpty;
      final targetFolderId = hasName
          ? '13b4h-LWGWRl4MIYHMbRBrpC89rW2wYa7' // Named folder
          : '1NoHSIaaBUuz5R9bv47haP4Ep9GTEz9JT'; // Default folder

      // Process each image URL
      for (final controller in imageUrlControllers) {
        final imageUrl = controller.text.trim();
        if (imageUrl.isEmpty) continue;

        try {
          // Download image
          final response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode != 200) {
            throw Exception('Failed to download image: $imageUrl');
          }

          // Create file name based on available fields
          String fileName;
          if (hasName) {
            final datePart = dateController.text.trim().isNotEmpty
                ? '_${dateController.text.trim()}' // Add date if available
                : '';
            fileName = '${nameController.text.trim()}$datePart.jpg';
          } else {
            fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
          }

          // Clean filename by removing invalid characters
          fileName = fileName.replaceAll(RegExp(r'[^\w-.]'), '_');

          final fileMetadata = drive.File()
            ..name = fileName
            ..parents = [targetFolderId];

          // Upload to Google Drive
          final media = drive.Media(
            http.ByteStream.fromBytes(response.bodyBytes),
            response.bodyBytes.length,
          );

          await driveApi.files.create(
            fileMetadata,
            uploadMedia: media,
          );
        } catch (e) {
          print('Error processing image $imageUrl: $e');
          // Continue with next image even if one fails
        }
      }
    } catch (e) {
      print('Google Drive upload failed: $e');
      rethrow;
    }
  }

  void clearFields() {
    date.clear();
    name.clear();
    opg.clear();
    bitewing.clear();
    lateralceph.clear();
    cbct.clear();
    ct.clear();
    mri.clear();
    usg.clear();
    anyOther.clear();
    dob.clear();
    gender.clear();
    reg.clear();
    address.clear();
    aadhar.clear();
    contact.clear();
    complaint.clear();
    dentPrimary.clear();
    dentMixed.clear();
    dentPerm.clear();
    decayed.clear();
    amalgam.clear();
    composite.clear();
    gold.clear();
    rct.clear();
    missing.clear();
    attrition.clear();
    abrasion.clear();
    erosion.clear();
    abfraction.clear();
    toothSize.clear();
    toothShape.clear();
    toothNumber.clear();
    toothStruc.clear();
    toothMal.clear();
    lipPalates.clear();
    oralMucosa.clear();
    gingiva.clear();
    jaws.clear();
    tongue.clear();
    crown.clear();
    implant.clear();
    removableFixed.clear();
    partialComplete.clear();
    maxillaMandible.clear();
    other.clear();
    iopa.clear();
    studyCast.clear();
    palatoscopy.clear();
    lipPrint.clear();
    tonguePrint.clear();
    diagnosis.clear();

    thisDate = '';
    thisDOB = '';
  }

  static const my = SizedBox(
    height: 10,
  );

  String jetFieldValue(TextEditingController controller) {
    return controller.text.isEmpty ? 'None' : controller.text;
  }

  Future<void> addDataToFirestore() async {
    try {
      await _firestore.collection('patients').add({
        'aadhar':jetFieldValue(aadhar),
        'abfraction':jetFieldValue(abfraction),
        'abrasion':jetFieldValue(abrasion),
        'address':jetFieldValue(address),
        'amalgam':jetFieldValue(amalgam),
        'anyother':jetFieldValue(anyOther),
        'attrition':jetFieldValue(attrition),
        'bw':jetFieldValue(bitewing),
        'cbct':jetFieldValue(cbct),
        'complaint':jetFieldValue(complaint),
        'compo':jetFieldValue(composite),
        'contact':jetFieldValue(contact),
        'crown':jetFieldValue(crown),
        'ct':jetFieldValue(ct),
        'date':jetFieldValue(date),
        'decay':jetFieldValue(decayed),
        'di':jetFieldValue(implant),
        'diag':jetFieldValue(diagnosis),
        'dob':jetFieldValue(dob),
        'erosion':jetFieldValue(erosion),
        'g':jetFieldValue(gingiva),
        'gender':jetFieldValue(gender),
        'gold':jetFieldValue(gold),
        'iopa':jetFieldValue(iopa),
        'j':jetFieldValue(jaws),
        'lc':jetFieldValue(lateralceph),
        'lip':jetFieldValue(lipPalates),
        'lprint':jetFieldValue(lipPrint),
        'mal':jetFieldValue(toothMal),
        'missing':jetFieldValue(missing),
        'mixed':jetFieldValue(dentMixed),
        'mm':jetFieldValue(maxillaMandible),
        'mri':jetFieldValue(mri),
        'name':jetFieldValue(name),
        'number':jetFieldValue(toothNumber),
        'om':jetFieldValue(oralMucosa),
        'opg':jetFieldValue(opg),
        'other':jetFieldValue(other),
        'pala':jetFieldValue(palatoscopy),
        'pc':jetFieldValue(partialComplete),
        'perm':jetFieldValue(dentPerm),
        'photo':'None',
        'prim':jetFieldValue(dentPrimary),
        'rct':jetFieldValue(rct),
        'reg':jetFieldValue(reg),
        'rf':jetFieldValue(removableFixed),
        'sc':jetFieldValue(studyCast),
        'shape':jetFieldValue(toothShape),
        'size':jetFieldValue(toothSize),
        'structure':jetFieldValue(toothStruc),
        't':jetFieldValue(tongue),
        'tprint':jetFieldValue(tonguePrint),
        'usg':jetFieldValue(usg)
      });
      print("Data added successfully");
    } catch (e) {
      print("Error adding data: $e");
    }
  }

  final heading = GoogleFonts.roboto(
      fontWeight: FontWeight.bold,
      color: Colors.black,
      fontSize: 18
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Image.asset(
                "assets/form_background.png",
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      height: 15,
                    ),
                    TextLabel(
                      text: 'General',
                    ),
                    my,
                    //general
                    GestureDetector(
                      onTap: () => _selectDate(context, date, (newDate) => thisDate = newDate),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          child: Text(
                            'Date$thisDate', // Reflects the selected date
                            style: TextStyle(color: Colors.black87, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    CustomTextField(hintText: 'Registration Number', controller: reg),
                    my,
                    //end
                    TextLabel(text: 'Personal Details'),
                    my,
                    //personal details
                    CustomTextField(hintText: 'Name', controller: name),
                    GestureDetector(
                      onTap: () => _selectDate(context, dob, (newDate) => thisDOB = newDate),
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          child: Text(
                            'Date of Birth$thisDOB', // Reflects the selected date
                            style: TextStyle(color: Colors.black87, fontSize: 16),
                          ),
                        ),
                      ),
                    ),
                    CustomDropdownField(
                      hintText: 'Gender',
                      controller: gender,
                      options: ['Male', 'Female', 'Other'],
                    ),

                    CustomTextField(hintText: 'Address', controller: address),
                    CustomTextField(hintText: 'Aadhar Number', controller: aadhar),
                    CustomTextField(hintText: 'Contact', controller: contact),
                    //end personal
                    CustomTextField(hintText: 'Complaint', controller: complaint),
                    my,
                    TextLabel(text: 'Dentition'),
                    my,
                    my,
                    ExpandableCheckbox(children: [
                      CustomTextField(hintText: 'Primary', controller: dentPrimary),
                      CustomTextField(hintText: 'Mixed', controller: dentMixed),
                      CustomTextField(hintText: 'Permanent', controller: dentPerm),
                    ]),
                    my,
                    my,
                    GestureDetector(
                      onTap: () {
                        showCustomDialog(context, amalgam, gold, rct, composite, decayed, missing);
                      },
                      child: Container(
                        height: 60,
                        width: 260,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                              'Add Dental Charting',
                              style: heading
                          ),
                        ),
                      ),
                    ),
                    my,
                    my,
                    TextLabel(text: 'Regressive Changes'),
                    my,
                    my,
                    ExpandableCheckbox(children: [
                      CustomTextField(hintText: 'Attrition', controller: attrition),
                      CustomTextField(hintText: 'Abrasion', controller: abrasion),
                      CustomTextField(hintText: 'Erosion', controller: erosion),
                      CustomTextField(hintText: 'Abfraction', controller: abfraction),
                    ]),
                    my,
                    my,
                    //end
                    //pathologies
                    //tooth
                    TextLabel(text: 'Pathologies'),
                    my,
                    my,
                    ExpandableCheckbox(children: [
                      CustomTextField(hintText: 'Lip Palates', controller: lipPalates),
                      CustomTextField(hintText: 'Oral Mucosa', controller: oralMucosa),
                      CustomTextField(hintText: 'Gingiva', controller: gingiva),
                      CustomTextField(hintText: 'Jaws', controller: jaws),
                      CustomTextField(hintText: 'Tongue', controller: tongue),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                  'Tooth',
                                  style: heading
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              CustomTextField(hintText: 'Tooth Size', controller: toothSize),
                              CustomTextField(hintText: 'Tooth Shape', controller: toothShape),
                              CustomTextField(hintText: 'Tooth No.', controller: toothNumber),
                              CustomTextField(hintText: 'Tooth Structure', controller: toothStruc),
                              CustomTextField(hintText: 'Tooth Mal-position', controller: toothMal),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    my,
                    my,
                    //end

                    //end tongue
                    //previous treatment
                    TextLabel(text: 'Previous Treatments'),
                    my,
                    my,
                    ExpandableCheckbox(children: [
                      CustomTextField(hintText: 'Other Details', controller: other),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.lightBlueAccent,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(25),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              Text(
                                  'Prothesis',
                                  style: heading
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              CustomTextField(hintText: 'Crown', controller: crown),
                              CustomTextField(hintText: 'Implant', controller: implant),
                              CustomTextField(hintText: 'Removable Fixed', controller: removableFixed),
                              CustomTextField(hintText: 'Partial Complete', controller: partialComplete),
                              CustomTextField(hintText: 'Maxilla Mandible', controller: maxillaMandible),
                            ],
                          ),
                        ),
                      ),
                    ]),
                    my,
                    my,
                    TextLabel(text: 'Photos'),
                    my,
                    my,
                    ExpandableCheckbox(children: [
                      UploadButtonWidget(label: 'IOPA', controller: iopa),
                      UploadButtonWidget(label: 'OPG', controller: opg),
                      UploadButtonWidget(label: 'BiteWing', controller: bitewing),
                      UploadButtonWidget(label: 'Lateralceph', controller: lateralceph),
                      UploadButtonWidget(label: 'CBCT', controller: cbct),
                      UploadButtonWidget(label: 'CT', controller: ct),
                      UploadButtonWidget(label: 'MRI', controller: mri),
                      UploadButtonWidget(label: 'USG', controller: usg),
                      UploadButtonWidget(label: 'Any other', controller: anyOther),
                      UploadButtonWidget(label: 'Study Cast', controller: studyCast),
                      UploadButtonWidget(label: 'Palatoscopy', controller: palatoscopy),
                      UploadButtonWidget(label: 'Lip Print', controller: lipPrint),
                      UploadButtonWidget(label: 'Tongue Print', controller: tonguePrint),
                    ]),
                    my,
                    CustomTextField(hintText: 'Diagnosis', controller: diagnosis),
                    my,
                    CustomButton(text: 'Submit', onPressed: () async {
                      await addDataToFirestore();
                      clearFields();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.blue,
                          content: Text('Submitted!',style: TextStyle(color: Colors.white),),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }),
                    SizedBox(
                      height: 40,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showCustomDialog(BuildContext context, TextEditingController amal, TextEditingController gold, TextEditingController rct,
    TextEditingController comp, TextEditingController decay, TextEditingController miss) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: ColorfulGrid(amalgamController: amal,goldController: gold, rctController: rct, compositeController: comp, decayedController: decay, missingController: miss,),
      );
    },
  );
}
