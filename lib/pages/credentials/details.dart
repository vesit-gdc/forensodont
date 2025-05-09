import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../custom/constants.dart';
import '../../custom/mytextfield.dart';
import '../../custom/thisButton.dart';

class RegistrationDetailsPage extends StatefulWidget {
  const RegistrationDetailsPage({super.key});

  static final id = 'details';

  @override
  RegistrationDetailsPageState createState() => RegistrationDetailsPageState();
}

class RegistrationDetailsPageState extends State<RegistrationDetailsPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController registrationNumberController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String? selectedGender;
  String? selectedState;

  final List<String> genders = ["Male", "Female", "Other"];
  final List<String> indianStates = [
    "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat",
    "Haryana", "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
    "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab", "Rajasthan",
    "Sikkim", "Tamil Nadu", "Telangana", "Tripura", "Uttar Pradesh", "Uttarakhand", "West Bengal"
  ];

  Future<void> _submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No user logged in")),
      );
      return;
    }
    try {
      await FirebaseFirestore.instance.collection('user_details').doc(user.email).set({
        'full_name': fullNameController.text.trim(),
        'gender': selectedGender,
        'registration_number': registrationNumberController.text.trim(),
        'address': addressController.text.trim(),
        'state_of_practice': selectedState,
        'email': user.email,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Details submitted successfully!")),
      );
      Navigator.pushNamed(context, 'home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/l_and_r_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withAlpha(229),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: // inside your build method, replace the entire Column's children with:

                    [
                      Text('Forensodont', style: cForensodont),
                      Text('Registration Details', style: cSubheading),
                      const SizedBox(height: 20),

                      CustomTextField(
                        hintText: "Full Name",
                        controller: fullNameController,
                        prefixIcon: Icons.person,
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            ),
                          ),
                          hint: const Text("Select Gender"),
                          value: genders.contains(selectedGender) ? selectedGender : null,
                          items: genders.map((String gender) {
                            return DropdownMenuItem<String>(
                              value: gender,
                              child: Text(gender),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedGender = newValue;
                            });
                          },
                        ),
                      ),

                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              blurRadius: 6,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.red, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            ),
                          ),
                          hint: const Text("Select State of Practice"),
                          value: indianStates.contains(selectedState) ? selectedState : null,
                          items: indianStates.map((String state) {
                            return DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedState = newValue;
                            });
                          },
                        ),
                      ),

                      CustomTextField(
                        hintText: "Registration Number",
                        controller: registrationNumberController,
                        prefixIcon: Icons.badge,
                      ),

                      CustomTextField(
                        hintText: "Address of Practice",
                        controller: addressController,
                        prefixIcon: Icons.location_on,
                      ),

                      const SizedBox(height: 20),

                      CustomButton(
                          text: "Login", onPressed: _submitData),
                    ]
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
