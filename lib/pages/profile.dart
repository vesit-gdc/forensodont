import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:forensodont/custom/constants.dart';
import 'package:forensodont/custom/navbar.dart';
import 'package:forensodont/pages/landingpage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static final id = 'pro';

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? userData;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _loadLocalImage();
  }

  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('user_details').doc(user.email).get();
      if (doc.exists) {
        setState(() {
          userData = doc.data();
        });
      }
    }
  }

  Future<void> _loadLocalImage() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_image.jpg');
      final file = File(imagePath);

      if (await file.exists()) {
        setState(() {
          _profileImage = file;
        });
      }
    } catch (e) {
      debugPrint('Error loading local image: $e');
    }
  }

  Future<void> _saveImageLocally(File image) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_image.jpg');
      await image.copy(imagePath);
    } catch (e) {
      debugPrint('Error saving image locally: $e');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    showModalBottomSheet(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.gallery);
              if (picked != null) {
                final file = File(picked.path);
                await _saveImageLocally(file);
                setState(() => _profileImage = file);
              }
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () async {
              final picked = await picker.pickImage(source: ImageSource.camera);
              if (picked != null) {
                final file = File(picked.path);
                await _saveImageLocally(file);
                setState(() => _profileImage = file);
              }
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // Clear the locally stored image on logout
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = path.join(directory.path, 'profile_image.jpg');
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
      }

      await FirebaseAuth.instance.signOut();
      Navigator.pushNamed(context, LandingPage.id);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

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
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamed(context, 'land'),
        ),
      ),
      body: userData == null
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.7,
          child: IDCard(
            profileData: userData!,
            profileImage: _profileImage,
            onImageTap: _pickImage,
            onLogout: () => _logout(context),
          ),
        ),
      ),
      bottomNavigationBar: const Navbar(initialIndex: 2),
    );
  }
}

class IDCard extends StatelessWidget {
  final Map<String, dynamic> profileData;
  final File? profileImage;
  final VoidCallback onImageTap;
  final VoidCallback onLogout;

  const IDCard({
    required this.profileData,
    required this.onImageTap,
    required this.onLogout,
    this.profileImage,
    super.key,
  });

  Widget _buildProfileImage({bool fullSize = false}) {
    if (profileImage != null) {
      return ClipRRect(
        borderRadius: fullSize ? BorderRadius.circular(8) : BorderRadius.circular(30),
        child: Image.file(
          profileImage!,
          width: fullSize ? 120 : 50,
          height: fullSize ? 150 : 50,
          fit: BoxFit.cover,
        ),
      );
    } else if (profileData['photoUrl'] != null) {
      return ClipRRect(
        borderRadius: fullSize ? BorderRadius.circular(8) : BorderRadius.circular(30),
        child: Image.network(
          profileData['photoUrl'],
          width: fullSize ? 120 : 50,
          height: fullSize ? 150 : 50,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderIcon(fullSize),
        ),
      );
    } else {
      return _buildPlaceholderIcon(fullSize);
    }
  }

  Widget _buildPlaceholderIcon(bool fullSize) {
    return Icon(
      Icons.add_a_photo,
      size: fullSize ? 50 : 30,
      color: Colors.grey,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withAlpha(190),
              fontSize: 17,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue[800]!, Colors.blue[400]!],
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Header with logo and title
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        'INDIAN MEDICAL ASSOCIATION',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ID Card',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Profile picture and details
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile picture (clickable)
                    GestureDetector(
                      onTap: onImageTap,
                      child: Container(
                        width: 120,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: _buildProfileImage(fullSize: true),
                      ),
                    ),
                    const SizedBox(width: 20),

                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Name', profileData['full_name'] ?? 'Not provided'),
                          line(Colors.white),
                          profileGap,
                          _buildDetailRow('Email', profileData['email'] ?? 'Not provided'),
                          line(Colors.white),
                          profileGap,
                          _buildDetailRow('Gender', profileData['gender'] ?? 'Not provided'),
                          line(Colors.white),
                          profileGap,
                          _buildDetailRow('State', profileData['state_of_practice'] ?? 'Not provided'),
                          line(Colors.white),
                          profileGap,
                          _buildDetailRow('State Registration Number',
                              profileData['registration_number'] ?? 'Not provided'),
                          line(Colors.white),
                          profileGap,
                          _buildDetailRow('Address of Practice',
                              profileData['address'] ?? 'Not provided'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Footer with validity and logout button
              const SizedBox(height: 20),
              Divider(color: Colors.white.withAlpha(128)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 120,
                    height: 40,
                    color: Colors.white,
                    child: Center(
                      child: Text(
                        'Valid Till: ${profileData['validThru'] ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  // Logout button
                  GestureDetector(
                    onTap: onLogout,
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, size: 20, color: Colors.red),
                          SizedBox(width: 5),
                          Text(
                            'LOGOUT',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}