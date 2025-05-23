import 'package:flutter/material.dart';

class ColorfulGrid extends StatefulWidget {
  final TextEditingController amalgamController;
  final TextEditingController goldController;
  final TextEditingController rctController;
  final TextEditingController compositeController;
  final TextEditingController decayedController;
  final TextEditingController missingController;

  const ColorfulGrid({
    super.key,
    required this.amalgamController,
    required this.goldController,
    required this.rctController,
    required this.compositeController,
    required this.decayedController,
    required this.missingController,
  });

  @override
  ColorfulGridState createState() => ColorfulGridState();
}

class ColorfulGridState extends State<ColorfulGrid> {
  Color selectedColor = Colors.blue;
  late final Map<String, Color> colorMap;
  late final Map<String, TextEditingController> colorControllers;

  final List<List<String>> coordinates = [
    ["5-5", "5-4", "5-3", "5-2", "5-1", "space", "6-1", "6-2", "6-3", "6-4", "6-5"],
    ["1-8", "1-7", "1-6", "1-5", "1-4", "1-3", "1-2", "1-1", "space", "2-1", "2-2", "2-3", "2-4", "2-5", "2-6", "2-7", "2-8"],
    ["4-8", "4-7", "4-6", "4-5", "4-4", "4-3", "4-2", "4-1", "space", "3-1", "3-2", "3-3", "3-4", "3-5", "3-6", "3-7", "3-8"],
    ["8-5", "8-4", "8-3", "8-2", "8-1", "space", "7-1", "7-2", "7-3", "7-4", "7-5"],
  ];

  final Map<String, Color> boxColors = {};

  @override
  void initState() {
    super.initState();

    colorMap = {
      "Filled - Amalgam": Colors.green,
      "Filled - Gold": Colors.yellow.shade700,
      "Filled - RCT": Colors.blue,
      "Filled - Composite": Colors.purple,
      "Decayed": Colors.black,
      "Missing": Colors.red,
    };

    colorControllers = {
      "Filled - Amalgam": widget.amalgamController,
      "Filled - Gold": widget.goldController,
      "Filled - RCT": widget.rctController,
      "Filled - Composite": widget.compositeController,
      "Decayed": widget.decayedController,
      "Missing": widget.missingController,
    };

    // Initialize all boxes as grey
    for (var row in coordinates) {
      for (var coord in row) {
        if (coord != "space") {
          boxColors[coord] = Colors.grey;
        }
      }
    }

    // Set colors based on controller values
    for (var entry in colorControllers.entries) {
      String colorKey = entry.key;
      Color color = colorMap[colorKey]!;
      String coordsText = entry.value.text;
      if (coordsText.isNotEmpty) {
        List<String> coords = coordsText.split(", ");
        for (String coord in coords) {
          boxColors[coord] = color;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<Color>(
              value: selectedColor,
              items: colorMap.entries.map((entry) {
                return DropdownMenuItem<Color>(
                  value: entry.value,
                  child: Text(entry.key, style: TextStyle(color: entry.value)),
                );
              }).toList(),
              onChanged: (Color? newColor) {
                if (newColor != null) {
                  setState(() {
                    selectedColor = newColor;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: InteractiveViewer(
                constrained: false,
                child: Column(
                  children: coordinates.map((row) => buildRow(row)).toList(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...colorControllers.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: TextField(
                controller: entry.value,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: entry.key,
                  border: OutlineInputBorder(),
                ),
              ),
            )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRow(List<String> row) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: row.map((coord) {
          if (coord == "space") {
            return const SizedBox(width: 20);
          }
          return _buildBox(coord);
        }).toList(),
      ),
    );
  }

  Widget _buildBox(String coord) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (boxColors[coord] == selectedColor) {
            boxColors[coord] = Colors.grey;
          } else {
            boxColors[coord] = selectedColor;
          }

          for (var entry in colorControllers.entries) {
            String colorKey = entry.key;
            Color color = colorMap[colorKey]!;
            TextEditingController controller = entry.value;

            List<String> coords = [];
            boxColors.forEach((key, value) {
              if (value == color) {
                coords.add(key);
              }
            });

            controller.text = coords.join(", ");
          }
        });
      },
      child: Container(
        width: 50,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: boxColors[coord],
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}