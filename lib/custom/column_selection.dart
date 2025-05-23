import 'package:flutter/material.dart';

class ColumnSelectionDialog extends StatefulWidget {
  final Map<String, List<String>> availableColumns;
  final Map<String, String> fieldMap;
  final List<String> initiallySelected;
  final int maxColumnsLimit;

  const ColumnSelectionDialog({
    required this.availableColumns,
    required this.fieldMap,
    required this.initiallySelected,
    required this.maxColumnsLimit,
    super.key,
  });

  @override
  State<ColumnSelectionDialog> createState() => _ColumnSelectionDialogState();
}

class _ColumnSelectionDialogState extends State<ColumnSelectionDialog> {
  late List<String> selectedColumns;
  bool maxReached = false;

  @override
  void initState() {
    super.initState();
    selectedColumns = List.from(widget.initiallySelected);
    maxReached = selectedColumns.length >= widget.maxColumnsLimit;
  }

  void _toggleColumn(String field, bool selected) {
    setState(() {
      if (selected) {
        if (selectedColumns.length < widget.maxColumnsLimit) {
          selectedColumns.add(field);
          maxReached = selectedColumns.length >= widget.maxColumnsLimit;
        }
      } else {
        selectedColumns.remove(field);
        maxReached = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Columns to Export'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Ensure left alignment
          children: [
            if (maxReached)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Maximum ${widget.maxColumnsLimit} columns selected',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Important for alignment
                  children: [
                    for (final section in widget.availableColumns.entries)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                section.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Wrap(
                              alignment: WrapAlignment.start, // Ensure left alignment
                              crossAxisAlignment: WrapCrossAlignment.start,
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final field in section.value)
                                  if (widget.fieldMap.containsKey(field))
                                    FilterChip(
                                      label: Text(widget.fieldMap[field]!),
                                      selected: selectedColumns.contains(field),
                                      onSelected: maxReached && !selectedColumns.contains(field)
                                          ? null
                                          : (selected) => _toggleColumn(field, selected),
                                      backgroundColor: selectedColumns.contains(field)
                                          ? Colors.blue.shade100
                                          : null,
                                      showCheckmark: false,
                                    ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: selectedColumns.isEmpty
              ? null
              : () => Navigator.pop(context, {
            'selectedColumns': selectedColumns,
            'maxReached': maxReached,
          }),
          child: const Text('Generate PDF'),
        ),
      ],
    );
  }
}