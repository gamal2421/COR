// BuildCVGrid.dart
import 'package:corr/Builders/BuildCVCard.dart';
import 'package:corr/Else/Variables.dart';
import 'package:flutter/material.dart';

Widget buildCVGrid(BuildContext context,) {
  if (isLoading) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.red),
    );
  }
  if (displayedCVs.isEmpty) {
    return const Center(
      child: Text(
        'No data found',
        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: displayedCVs.length,
      itemBuilder: (context, index) {
        return buildCVCard(displayedCVs[index], context);
      },
    ),
  );
}

Widget buildCVGridd(BuildContext context,
List<Map<String, dynamic>> cvs, 
Function onTap) {
  if (isLoading) {
    return const Center(
      child: CircularProgressIndicator(color: Colors.red),
    );
  }
  if (displayedCVs.isEmpty) {
    return const Center(
      child: Text(
        'No data found',
        style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
      ),
    );
  }

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 1200 ? 4 : 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: displayedCVs.length,
      itemBuilder: (context, index) {
        return buildCVCard(displayedCVs[index], context);
      },
    ),
  );
}
