// lib/cv_detail_builders/build_value_text.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds a text widget for displaying values with support for links, emails, and phone numbers.
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
