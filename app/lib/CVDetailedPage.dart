import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CVDetailPage extends StatefulWidget {
  final Map<String, dynamic> cv;
  final bool isArchived;

  static const projectId = 'ocrcv-1e6fe';

  const CVDetailPage({super.key, required this.cv, this.isArchived = false});

  @override
  State<CVDetailPage> createState() => _CVDetailPageState();
}

class _CVDetailPageState extends State<CVDetailPage> {
  void main() async {
    Firestore.initialize(CVDetailPage.projectId);
  }

  late Map<String, dynamic> cv;

  @override
  void initState() {
    super.initState();
    cv = widget.cv;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('CV Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailCard(context),
          ],
        ),
      ),
      floatingActionButton: widget.isArchived
          ? FloatingActionButton(
              onPressed: _unarchiveCV,
              heroTag: "Unarchive",
              backgroundColor: Colors.red[800],
              child: const Icon(Icons.outbox_outlined, color: Colors.white),
            )
          : widget.cv['isAssigned'] == "Yes"
              ? null // Hide buttons when in Assign collection
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Assign/Unassign Button
                    FloatingActionButton(
                      heroTag: "AssignDeassign",
                      backgroundColor: Colors.red[800],
                      child: Icon(
                        widget.cv['isAssigned'] == "Yes"
                            ? Icons.assignment_return_sharp
                            : Icons.assignment_ind_sharp,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        bool confirm = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(
                                'Confirm ${widget.cv['isAssigned'] == "Yes" ? 'Unassign' : 'Assign'}'),
                            content: Text(
                                'Are you sure you want to ${widget.cv['isAssigned'] == "Yes" ? 'unassign' : 'assign'} this CV?'),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                child: Text('Confirm'),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Proceed with assigning/unassigning
                          try {
                            final documentId = widget.cv['id'];
                            final newStatus =
                                widget.cv['isAssigned'] == "Yes" ? "No" : "Yes";
                            if (newStatus == "Yes") {
                              // Move the CV to the Assign collection
                              final cvData = await Firestore.instance
                                  .collection(
                                      widget.isArchived ? 'Archive' : 'CV')
                                  .document(documentId)
                                  .get();
                              // Update the isAssigned field to "Yes"
                              cvData.map['isAssigned'] = "Yes";
                              await Firestore.instance
                                  .collection('Assign')
                                  .document(documentId)
                                  .set(cvData.map);
                              // Remove the CV from the original collection
                              await Firestore.instance
                                  .collection(
                                      widget.isArchived ? 'Archive' : 'CV')
                                  .document(documentId)
                                  .delete();
                            } else {
                              // Move the CV back to the original collection
                              final cvData = await Firestore.instance
                                  .collection('Assign')
                                  .document(documentId)
                                  .get();
                              // Update the isAssigned field to "No"
                              cvData.map['isAssigned'] = "No";
                              await Firestore.instance
                                  .collection(
                                      widget.isArchived ? 'Archive' : 'CV')
                                  .document(documentId)
                                  .set(cvData.map);
                              // Remove the CV from the Assign collection
                              await Firestore.instance
                                  .collection('Assign')
                                  .document(documentId)
                                  .delete();
                            }
                            setState(() {
                              widget.cv['isAssigned'] = newStatus;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'CV ${newStatus == "Yes" ? 'assigned' : 'unassigned'} successfully'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating CV: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(width: 10),
                    // Archive Button
                    FloatingActionButton(
                      heroTag: "Archive",
                      onPressed: _archiveCV,
                      backgroundColor: Colors.red[800],
                      child: const Icon(Icons.archive, color: Colors.white),
                    ),
                  ],
                ),
    );
  }

  // Function to archive a CV
 // Function to archive a CV
Future<void> _archiveCV() async {
  try {
    final documentId = widget.cv['id'];

    // Fetch the current CV data from the 'CV' collection.
    final cvData =
        await Firestore.instance.collection('CV').document(documentId).get();

    // Create a new map with updated isArchived field.
    final updatedData = Map<String, dynamic>.from(cvData.map);
    updatedData['isArchived'] = 'Yes';

    // Save the updated data to the Archive collection.
    await Firestore.instance
        .collection('Archive')
        .document(documentId)
        .set(updatedData); // Use updatedData here

    // Remove the document from the 'CV' collection.
    await Firestore.instance.collection('CV').document(documentId).delete();

    // Update the local state so the UI reflects the change.
    setState(() {
      widget.cv['isArchived'] = 'Yes';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV archived successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error archiving CV: $e'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

// Function to unarchive a CV
Future<void> _unarchiveCV() async {
  try {
    final documentId = widget.cv['id'];

    // Fetch the CV data from the Archive collection.
    final cvData = await Firestore.instance
        .collection('Archive')
        .document(documentId)
        .get();

    // Create a new map with updated isArchived field.
    final updatedData = Map<String, dynamic>.from(cvData.map);
    updatedData['isArchived'] = 'No';

    // Move the document to the 'CV' collection using the updated data.
    await Firestore.instance
        .collection('CV')
        .document(documentId)
        .set(updatedData);

    // Delete the document from the Archive collection.
    await Firestore.instance
        .collection('Archive')
        .document(documentId)
        .delete();

    // Update the local state so the UI reflects the change.
    setState(() {
      widget.cv['isArchived'] = 'No';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CV unarchived successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.of(context).pop();
  } catch (e) {
    debugPrint('Error unarchiving CV: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error unarchiving CV: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  Widget _buildDetailCard(BuildContext context) {
    final sortedEntries = widget.cv.entries.toList()
      ..sort((a, b) => a.key.toLowerCase().compareTo(b.key.toLowerCase()));

    final halfLength = (sortedEntries.length / 2).ceil();
    final firstColumnEntries = sortedEntries.sublist(0, halfLength);
    final secondColumnEntries = sortedEntries.sublist(halfLength);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.cv['isAssigned'] == "Yes")
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Assigned',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: firstColumnEntries.map((entry) {
                      if (entry.key == "id") return const SizedBox();
                      return _buildDetailRow(context, entry.key, entry.value);
                    }).toList(),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: secondColumnEntries.map((entry) {
                      if (entry.key == "id") return const SizedBox();
                      return _buildDetailRow(context, entry.key, entry.value);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, dynamic value) {
    if (value == null ||
        (value is String && value.contains("not provided")) ||
        (value is String && value.contains("dont have any Certifications"))) {
      return const SizedBox();
    }
    Widget buildMapWidget(BuildContext context, Map map) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: map.entries.map<Widget>((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("• ", style: TextStyle(fontSize: 16)),
                Flexible(
                  fit: FlexFit.loose,
                  child: Wrap(
                    children: [
                      Text(
                        '${entry.key}: ',
                        style: const TextStyle(
                            fontSize: 16,
                            color: Colors.red,
                            fontWeight: FontWeight.bold),
                        softWrap: true,
                      ),
                      Text(
                        '${entry.value}',
                        style: const TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      );
    }

    Widget buildValueText(BuildContext context, String text) {
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      final urlRegex = RegExp(r'^(http|https):\/\/');
      final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]+$');

      TextStyle linkStyle = const TextStyle(
        fontSize: 16,
        color: Colors.blue,
        decoration: TextDecoration.underline,
      );
      TextStyle normalStyle = const TextStyle(fontSize: 16);

      String finalUrl = text;
      if (!urlRegex.hasMatch(text) &&
          (text.startsWith("www.") ||
              text.contains("linkedin.com") ||
              text.contains("github.com"))) {
        finalUrl = "https://$text";
      }

      if (phoneRegex.hasMatch(text)) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: normalStyle, softWrap: true),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Phone number copied to clipboard')),
                );
              },
            ),
          ],
        );
      } else if (urlRegex.hasMatch(finalUrl)) {
        return InkWell(
          onTap: () async {
            final uri = Uri.parse(finalUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              debugPrint('Could not launch $finalUrl');
            }
          },
          child: Text(
            text,
            style: linkStyle,
            softWrap: true,
          ),
        );
      } else if (emailRegex.hasMatch(text)) {
        return InkWell(
          onTap: () async {
            final emailUri = Uri(
              scheme: 'mailto',
              path: text,
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              debugPrint('Could not launch email client for $text');
            }
          },
          child: Text(
            text,
            style: linkStyle,
            softWrap: true,
          ),
        );
      } else {
        return Text(
          text,
          style: normalStyle,
          softWrap: true,
        );
      }
    }

    Widget buildListItem(BuildContext context, dynamic item) {
      if (item is Map) {
        return Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: buildMapWidget(context, item),
        );
      } else {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("• ", style: TextStyle(fontSize: 16)),
            Expanded(child: buildValueText(context, item.toString())),
          ],
        );
      }
    }

    Widget buildLabel(String label) {
      TextStyle headerStyle = const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      );
      TextStyle subHeaderStyle = const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.grey,
      );
      TextStyle fieldLabelStyle = TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.red[800]!,
      );

      String lowerLabel = label.toLowerCase();
      if (lowerLabel.contains("header") && !lowerLabel.contains("sub")) {
        return Text(label, style: headerStyle);
      } else if (lowerLabel.contains("subheader") ||
          lowerLabel.contains("sub")) {
        return Text(label, style: subHeaderStyle);
      } else {
        return Text('$label:', style: fieldLabelStyle);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildLabel(label),
          const SizedBox(height: 4),
          if (value is List)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: value
                  .map<Widget>(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: buildListItem(context, item),
                    ),
                  )
                  .toList(),
            )
          else if (value is Map)
            buildMapWidget(context, value)
          else
            buildValueText(context, value.toString()),
        ],
      ),
    );
  }
}
