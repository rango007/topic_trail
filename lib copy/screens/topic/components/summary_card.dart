import 'package:flutter/material.dart';

class SummaryCard extends StatelessWidget {
  final String? imageUrl;
  final String questionText;
  final String chosenOption;

  const SummaryCard({
    Key? key,
    required this.imageUrl,
    required this.questionText,
    required this.chosenOption,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Image.network(
              imageUrl!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              questionText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              "Chosen Option: $chosenOption",
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
