import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CVDetailPage extends StatelessWidget {
  final Map<String, dynamic> cv;
  const CVDetailPage({Key? key, required this.cv}) : super(key: key);

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
    );
  }

  Widget _buildDetailCard(BuildContext context) {
    // Split the CV entries into two lists
    final entries = cv.entries.toList();
    final halfLength = (entries.length / 2).ceil();
    final firstColumnEntries = entries.sublist(0, halfLength);
    final secondColumnEntries = entries.sublist(halfLength);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: firstColumnEntries.map((entry) {
                  if (entry.key == "id") return const SizedBox(); // Skip ID field
                  return _buildDetailRow(context, entry.key, entry.value);
                }).toList(),
              ),
            ),
            const SizedBox(width: 16), // Spacing between columns
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: secondColumnEntries.map((entry) {
                  if (entry.key == "id") return const SizedBox(); // Skip ID field
                  return _buildDetailRow(context, entry.key, entry.value);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, dynamic value) {
    // Helper function to build clickable text or a copyable phone number
    Widget buildValueText(BuildContext context, String text) {
      // Regular expressions for email, URL, and phone number.
      final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      final urlRegex = RegExp(r'^(http|https):\/\/');
      // A simple phone number regex (this might need adjustments depending on the formats you expect)
      final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]+$');

      TextStyle linkStyle = const TextStyle(
        fontSize: 16,
        color: Colors.blue,
        decoration: TextDecoration.underline,
      );
      TextStyle normalStyle = const TextStyle(fontSize: 16);

      // Prepare a final URL string.
      String finalUrl = text;

      // If the text does not start with http/https but it starts with www. or contains known domains,
      // prepend https://
      if (!urlRegex.hasMatch(text) &&
          (text.startsWith("www.") ||
              text.contains("linkedin.com") ||
              text.contains("github.com"))) {
        finalUrl = "https://$text";
      }

      // If the text matches our phone number regex, display a copy button next to it.
      if (phoneRegex.hasMatch(text)) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text, style: normalStyle),
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: text));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Phone number copied to clipboard')),
                );
              },
            ),
          ],
        );
      }
      // If finalUrl now matches our URL regex, treat it as a clickable link.
      else if (urlRegex.hasMatch(finalUrl)) {
        return InkWell(
          onTap: () async {
            final uri = Uri.parse(finalUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            } else {
              // Optionally handle the error (e.g., show a snackbar)
              debugPrint('Could not launch $finalUrl');
            }
          },
          child: Text(text, style: linkStyle),
        );
      }
      // If it's an email address, open the email client.
      else if (emailRegex.hasMatch(text)) {
        return InkWell(
          onTap: () async {
            final emailUri = Uri(
              scheme: 'mailto',
              path: text,
            );
            if (await canLaunchUrl(emailUri)) {
              await launchUrl(emailUri);
            } else {
              // Optionally handle the error (e.g., show a snackbar)
              debugPrint('Could not launch email client for $text');
            }
          },
          child: Text(text, style: linkStyle),
        );
      }
      // Otherwise, return normal styled text.
      else {
        return Text(text, style: normalStyle);
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          if (value is List)
            ...value
                .map<Widget>((item) => buildValueText(context, item.toString()))
                .toList()
          else
            buildValueText(context, value.toString()),
        ],
      ),
    );
  }
}
