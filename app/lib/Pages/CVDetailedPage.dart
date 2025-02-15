// lib/CVDetailPage.dart
import 'package:corr/CVDetailBuilders/BuildDetailCard.dart';
import 'package:firedart/firestore/firestore.dart';
import 'package:flutter/material.dart';

import 'package:corr/pages/main.dart';

class CVDetailPage extends StatefulWidget {
  final Map<String, dynamic> cv;
  static const projectId = 'ocrcv-1e6fe';

  const CVDetailPage({super.key, required this.cv});

  @override
  State<CVDetailPage> createState() => _CVDetailPageState();
}

class _CVDetailPageState extends State<CVDetailPage> {
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
        title:
            const Text('CV Details', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildDetailCard(context, cv),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Assign button
          FloatingActionButton(
            heroTag: "Assign",
            backgroundColor: Colors.red[800],
            child:
                const Icon(Icons.assignment_ind_sharp, color: Colors.white),
            onPressed: () async {
              try {
                final documentId = widget.cv['id'];
                await Firestore.instance
                    .collection('CV')
                    .document(documentId)
                    .update({'isAssigned': 'Yes'});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Employee is Assigned successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  cv["isAssigned"] = "Yes";
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating CV: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
          // De-Assign button
          FloatingActionButton(
            heroTag: "DeAssign",
            backgroundColor: Colors.red[800],
            child:
                const Icon(Icons.assignment_return_sharp, color: Colors.white),
            onPressed: () async {
              try {
                final documentId = widget.cv['id'];
                await Firestore.instance
                    .collection('CV')
                    .document(documentId)
                    .update({'isAssigned': 'No'});

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Employee is De-Assigned successfully'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
                setState(() {
                  cv["isAssigned"] = "No";
                });
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error updating CV: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          const SizedBox(width: 10),
          // Delete button
          FloatingActionButton(
            heroTag: "Delete",
            backgroundColor: Colors.red[800],
            child: const Icon(Icons.delete, color: Colors.white),
            onPressed: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text(
                      'Delete CV',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text(
                      'Are you sure you want to delete this CV?',
                      style: TextStyle(fontSize: 16),
                    ),
                    actions: [
                      TextButton(
                        child: const Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      TextButton(
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ],
                  );
                },
              );

              if (confirmDelete == true) {
                try {
                  final documentId = widget.cv['id'];
                  await Firestore.instance
                      .collection('CV')
                      .document(documentId)
                      .delete();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "CV deleted successfully",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => const FireStoreHome()));
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error deleting CV')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
