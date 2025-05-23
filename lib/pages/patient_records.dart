import 'package:google_fonts/google_fonts.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../custom/column_selection.dart';

class Records extends StatefulWidget {
  const Records({super.key});
  static const id = 'records';

  @override
  RecordsState createState() => RecordsState();
}

class RecordsState extends State<Records> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Map<String, TextEditingController> _searchControllers = {};
  bool _filtersExpanded = false;
  List<QueryDocumentSnapshot> filteredDocs = [];

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 4.0,
            child: Center(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageThumbnail(String? imageUrl) {
    if (imageUrl == null || imageUrl == 'None') {
      return const Text('None');
    }
    return GestureDetector(
      onTap: () => _showImageDialog(imageUrl),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Image.network(
          imageUrl,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
        ),
      ),
    );
  }

  // Add to your state class
  List<String> selectedColumns = [];
  bool maxColumnsReached = false;
  static const int maxColumnsLimit = 6;

// Modified PDF generation function
  Future<void> generatePDF() async {
    if (filteredDocs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to export')),
      );
      return;
    }

    // Show column selection dialog
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => ColumnSelectionDialog(
        availableColumns: fieldSections,
        fieldMap: fieldMap,
        initiallySelected: selectedColumns,
        maxColumnsLimit: maxColumnsLimit,
      ),
    );

    if (result == null) return;

    setState(() {
      selectedColumns = List<String>.from(result['selectedColumns']);
      maxColumnsReached = result['maxReached'] as bool;
    });

    if (selectedColumns.isEmpty) return;

    final pdf = pw.Document();

    // Create data for all selected columns
    final data = filteredDocs.map((doc) {
      return selectedColumns.map((field) => doc[field]?.toString() ?? '-').toList();
    }).toList();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape, // Use landscape for more horizontal space
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.SizedBox(height: 20),

              // Main table
              pw.Table.fromTextArray(
                headers: selectedColumns.map((field) => fieldMap[field] ?? field).toList(),
                data: data,
                border: pw.TableBorder.all(color: PdfColors.grey300),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1976D2),
                ),
                cellAlignment: pw.Alignment.centerLeft,
                cellStyle: const pw.TextStyle(fontSize: 9), // Smaller font to fit more
                columnWidths: {
                  for (var i = 0; i < selectedColumns.length; i++)
                    i: const pw.FlexColumnWidth(1.8) // Adjusted width
                },
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  List<String> selectedFields = [];
  Map<String, String> fieldMap = {
    'aadhar': 'Aadhar Number',
    'abfraction': 'Abfraction',
    'abrasion': 'Abrasion',
    'address': 'Address',
    'amalgam': 'Amalgam',
    'anyother': 'Any Other',
    'attrition': 'Attrition',
    'bw': 'Bitewing',
    'cbct': 'CBCT',
    'complaint': 'Complaint',
    'compo': 'Composite',
    'contact': 'Contact',
    'crown': 'Crown',
    'ct': 'CT',
    'date': 'Date',
    'decay': 'Decay',
    'di': 'Dental Implant',
    'diag': 'Diagnosis',
    'dob': 'Date of Birth',
    'erosion': 'Erosion',
    'g': 'Gingiva',
    'gender': 'Gender',
    'gold': 'Gold',
    'iopa': 'IOPA',
    'j': 'Jaws',
    'lc': 'Lateral Cephalogram',
    'lip': 'Lip & Palates',
    'lprint': 'Lip Print',
    'mal': 'Tooth Malposition',
    'missing': 'Missing Teeth',
    'mixed': 'Mixed Dentition',
    'mm': 'Maxilla & Mandible',
    'mri': 'MRI',
    'name': 'Patient Name',
    'number': 'Tooth Number',
    'om': 'Oral Mucosa',
    'opg': 'OPG',
    'other': 'Other',
    'pala': 'Palatoscopy',
    'pc': 'Partial/Complete Prosthesis',
    'perm': 'Permanent Dentition',
    'photo': 'Photo',
    'prim': 'Primary Dentition',
    'rct': 'Root Canal Treatment',
    'reg': 'Registration Number',
    'rf': 'Removable/Fixed Prosthesis',
    'sc': 'Study Cast',
    'shape': 'Tooth Shape',
    'size': 'Tooth Size',
    'structure': 'Tooth Structure',
    't': 'Tongue',
    'tprint': 'Tongue Print',
    'usg': 'Ultrasound (USG)'
  };

  List<String> columnOrder = [
    'date', 'name', 'dob', 'gender', 'reg', 'address', 'aadhar', 'contact', 'complaint',
    'prim', 'mixed', 'perm', 'decay', 'amalgam', 'compo', 'gold', 'rct', 'missing',
    'attrition', 'abrasion', 'erosion', 'abfraction', 'size', 'shape', 'number',
    'structure', 'mal', 'lip', 'om', 'g', 'j', 't', 'crown', 'di', 'rf', 'pc', 'mm',
    'anyother', 'iopa', 'opg', 'bw', 'lc', 'cbct', 'ct', 'mri', 'usg', 'other', 'sc',
    'pala', 'lprint', 'tprint', 'diag'
  ];

  final Map<String, List<String>> fieldSections = {
    'General': ['date', 'reg'],
    'Personal Details': ['name', 'dob', 'gender','address','aadhar','contact','complaint'],
    'Dentition': ['prim', 'mixed', 'perm'],
    'Dental Charting': ['decay', 'amalgam', 'compo','gold','rct','missing'],
    'Regressive Changes': ['attrition', 'abrasion', 'erosion','abfraction'],
    'Pathologies': ['size', 'shape', 'number','structure','mal','lip','om','g','j','t'],
    'Previous Treatments': ['anyother', 'crown', 'di','rf','pc','mm'],
    // Add more sections as needed
  };

  @override
  void dispose() {
    _searchControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.brown.shade100,
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: generatePDF,
        child: const Icon(Icons.picture_as_pdf, color: Colors.white,),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            const SizedBox(height: 7),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0)),
                elevation: 4,
                child: ExpansionTile(
                  initiallyExpanded: false,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0)),
                  title: const Text(
                    'Search Filters',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  trailing: Icon(_filtersExpanded
                      ? Icons.expand_less
                      : Icons.expand_more),
                  onExpansionChanged: (expanded) {
                    setState(() => _filtersExpanded = expanded);
                  },
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: fieldSections.entries.map((section) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8, top: 16),
                                child: Text(
                                  section.key, // Section title
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Colors.purple.shade800,
                                  ),
                                ),
                              ),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 8.0,
                                children: section.value.map((field) {
                                  if (!fieldMap.containsKey(field)) return const SizedBox();
                                  return ChoiceChip(
                                    label: Text(fieldMap[field]!),
                                    selected: selectedFields.contains(field),
                                    selectedColor: Colors.purple.shade100,
                                    labelStyle: GoogleFonts.poppins(
                                      color: selectedFields.contains(field)
                                          ? Colors.purple.shade800
                                          : Colors.black87,
                                    ),
                                    onSelected: (selected) {
                                      setState(() {
                                        if (selected) {
                                          selectedFields.add(field);
                                          _searchControllers[field] = TextEditingController();
                                        } else {
                                          selectedFields.remove(field);
                                          _searchControllers.remove(field);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    ...selectedFields.map((field) => Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 16.0),
                      child: TextField(
                        controller: _searchControllers[field],
                        decoration: InputDecoration(
                          labelText: 'Enter ${fieldMap[field]}',
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(8.0)),
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    )),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Search applied!'),
                                  duration: Duration(seconds: 2)),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('Search',
                              style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          onPressed: () {
                            setState(() {
                              selectedFields.clear();
                              _searchControllers.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Filters cleared!'),
                                  duration: Duration(seconds: 2)),
                            );
                          },
                          child: const Text('Clear',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('patients').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData ||
                      snapshot.data!.docs.isEmpty) {
                    return const Center(
                        child: Text('No patient data found.'));
                  }

                  filteredDocs = snapshot.data!.docs.where((doc) {
                    if (selectedFields.isEmpty) return true;
                    return selectedFields.every((field) {
                      String searchValue = _searchControllers[field]
                          ?.text
                          .trim()
                          .toLowerCase() ??
                          '';
                      return searchValue.isEmpty ||
                          (doc[field]
                              ?.toString()
                              .toLowerCase()
                              .contains(searchValue) ??
                              false);
                    });
                  }).toList();

                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.0)),
                    elevation: 4,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: DataTable(
                        columnSpacing: 16,
                        headingRowColor:
                        MaterialStateColor.resolveWith((states) =>
                        Colors.blue.shade800),
                        dataRowColor: MaterialStateColor.resolveWith(
                                (states) => Colors.white.withOpacity(0.9)),
                        dividerThickness: 0, // Remove borders between rows
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16.0),
                          // Remove table borders
                        ),
                        columns: columnOrder
                            .map((field) => DataColumn(
                            label: Text(
                              fieldMap[field] ?? '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Colors.white),
                            )))
                            .toList(),
                        rows: filteredDocs.map((doc) {
                          return DataRow(
                            color: MaterialStateProperty.resolveWith<
                                Color?>((states) => states.contains(
                                MaterialState.selected)
                                ? Colors.purple.shade100
                                : null),
                            cells: columnOrder.map((field) {
                              if ([
                                'opg',
                                'bw',
                                'lc',
                                'cbct',
                                'ct',
                                'mri',
                                'usg',
                                'anyother',
                                'sc',
                                'pala',
                                'lprint',
                                'tprint'
                              ].contains(field)) {
                                return DataCell(_buildImageThumbnail(
                                    doc[field]?.toString()));
                              }
                              return DataCell(Text(
                                  doc[field]?.toString() ?? '-',
                                  style: const TextStyle(fontSize: 14)));
                            }).toList(),
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}