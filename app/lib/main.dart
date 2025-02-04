import 'dart:convert';
import 'dart:io';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:firedart/firedart.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:process_run/process_run.dart'; // Import process_run

const projectId = 'ocrcv-1e6fe';

void main() {
  Firestore.initialize(projectId); // Initialize Firestore
  runApp(const FireStoreApp());
}

class FireStoreApp extends StatelessWidget {
  const FireStoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const FluentApp(
      title: 'Cloud Firestore Windows',
      home: FireStoreHome(),
    );
  }
}

class FireStoreHome extends StatefulWidget {
  const FireStoreHome({super.key});

  @override
  _FireStoreHomeState createState() => _FireStoreHomeState();
}

class _FireStoreHomeState extends State<FireStoreHome> {
  CollectionReference cvCollection = Firestore.instance.collection('CV');
  List<File> selectedFiles = [];
  bool isUploading = false;

  /// 🔹 **File Picker**
  Future<void> pickFiles() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      showSnackbar(context, "⚠ Permission denied!", Colors.orange);
      return;
    }

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'txt'],
      allowMultiple: true,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFiles = result.files.map((file) => File(file.path!)).toList();
      });

      // Process each selected file
      for (var file in selectedFiles) {
        await runPythonScript(file.path);
      }
    }
  }

  /// 🔹 **Run Python Script**
  Future<void> runPythonScript(String filePath) async {
    setState(() => isUploading = true);

    try {
      // Check if Python is installed by running `python --version`
      const pythonPath = 'python'; // Or 'python3', based on your environment

      // Ensure the Python script and paths are correctly set.
      const scriptPath = 'assets/scripts/extract_text.py';  // Make sure the path is correct

      // Running the Python script using `process_run`
      final result = await run(
        pythonPath, // The Python executable
        [scriptPath, filePath], // Arguments to pass to the Python script
      );

      if (result.exitCode == 0) {
        // Parse the JSON output from the Python script
        final jsonData = jsonDecode(result.stdout.trim());

        // Upload the processed data to Firestore
        await uploadDataToFirestore(jsonData);
      } else {
        showSnackbar(context, "❌ Error running script: ${result.stderr}", Colors.red);
      }
    } catch (e) {
      showSnackbar(context, "❌ Error: $e", Colors.red);
    } finally {
      setState(() => isUploading = false);
    }
  }

  /// 🔹 **Upload Data to Firestore**
  Future<void> uploadDataToFirestore(Map<String, dynamic> data) async {
    try {
      // Use .add() to create a new document
      final document = await cvCollection.add(data);

      showSnackbar(context, "✅ Data uploaded to Firestore: ${document.id}", Colors.green);
    } catch (e) {
      showSnackbar(context, "❌ Error uploading data: $e", Colors.red);
    }
  }

  /// 🔹 **Show Feedback Messages**
  void showSnackbar(BuildContext context, String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => ContentDialog(
        title: const Text("Firestore Action"),
        content: Text(message),
        actions: [
          Button(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      content: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Button(
              onPressed: isUploading ? null : pickFiles,
              child: const Text("📂 Upload & Process Files"),
            ),
            const SizedBox(height: 20),
            if (isUploading) const ProgressRing(),
          ],
        ),
      ),
    );
  }
}