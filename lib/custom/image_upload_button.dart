import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class UploadButtonWidget extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const UploadButtonWidget({
    super.key,
    required this.label,
    required this.controller,
  });

  @override
  State<UploadButtonWidget> createState() => _UploadButtonWidgetState();
}

class _UploadButtonWidgetState extends State<UploadButtonWidget> {
  bool isUploading = false;

  Future<void> uploadImageToDrive() async {
    setState(() => isUploading = true);

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        File imageFile = File(result.files.single.path!);

        final serviceAccountJson = await rootBundle.loadString('assets/user.json');
        final credentials =
        ServiceAccountCredentials.fromJson(jsonDecode(serviceAccountJson));

        final client = await clientViaServiceAccount(
          credentials,
          [drive.DriveApi.driveFileScope],
        );

        var driveApi = drive.DriveApi(client);
        var file = drive.File();
        file.name = result.files.single.name;

        String folderId = '11yLDXAN-rGt30xOaMeLuVm7N5LAU1i9y';
        file.parents = [folderId];

        var response = await driveApi.files.create(
          file,
          uploadMedia: drive.Media(imageFile.openRead(), imageFile.lengthSync()),
        );

        String fileLink = 'https://drive.google.com/uc?export=view&id=${response.id}';
        widget.controller.text = fileLink;
        print(fileLink);
      }
    } catch (e) {
      widget.controller.text = 'Error: $e';
    } finally {
      setState(() => isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                labelText: widget.label,
                labelStyle: const TextStyle(fontSize: 16, color: Colors.blueGrey),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
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
              readOnly: true,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: isUploading ? null : uploadImageToDrive,
            icon: isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Icon(Icons.upload_file, color: Colors.white),
            label: Text(
              isUploading ? 'Uploading...' : 'Upload',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ],
      ),
    );
  }
}
