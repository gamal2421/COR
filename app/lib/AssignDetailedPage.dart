import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignDetailedPage extends StatelessWidget {
  final Map<String, dynamic> cv;

  const AssignDetailedPage({super.key, required this.cv});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red[800],
        title: const Text('Assigned CV Details',
            style: TextStyle(color: Colors.white)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _returnCVtocollictionCVS(context),
          backgroundColor: Colors.red[800],
        child: Icon(Icons.assignment_return,color: Colors.white,),
      ),
    );
  }

  Future<void> _returnCVtocollictionCVS(BuildContext context) async {
    try {
      final documentId = cv['id'];

      // Fetch the current CV data from the 'Assign' collection.
      final cvData = await Firestore.instance
          .collection('Assign')
          .document(documentId)
          .get();

      // Create a new map with updated isAssigned field.
      final updatedData = Map<String, dynamic>.from(cvData.map);
      updatedData['isAssigned'] = 'No';

      // Save the updated data to the CV collection.
      await Firestore.instance
          .collection('CV')
          .document(documentId)
          .set(updatedData);

      // Remove the document from the 'Assign' collection.
      await Firestore.instance
          .collection('Assign')
          .document(documentId)
          .delete();

      // Update the local state so the UI reflects the change.
      // Since this is a StatelessWidget, you cannot use setState.
      // You can use a callback or other state management solution to update the UI.

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('CV returned successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error return CV: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  Widget _buildDetailCard(BuildContext context) {
    final sortedEntries = cv.entries.toList()
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
            if (cv['isAssigned'] == "Yes")
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Assigned',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 8),
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
