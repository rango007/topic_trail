import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'components/summary_card.dart';

class SummaryScreen extends StatelessWidget {
  final List<Map<String, String?>> userResponses;

  SummaryScreen({required this.userResponses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Black background
      appBar: AppBar(
        backgroundColor: Colors.black, // Black app bar
        title: Text(
          "Summary",
          style: TextStyle(
            color: Colors.white, // White text
            fontWeight: FontWeight.bold, // Bold font weight
            fontFamily: 'Merriweather-Bold', // Merriweather-Bold font
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: userResponses.length,
          itemBuilder: (context, index) {
            final response = userResponses[index];
            return SummaryCard(
              imageUrl: response['imageUrl'],
              questionText: response['questionText']!,
              chosenOption: response['chosenOption']!,
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button
                foregroundColor: Colors.black, // Black text
                textStyle: TextStyle(
                  fontFamily: 'Quicksand', // Quicksand font
                ),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Start Over"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white, // White button
                foregroundColor: Colors.black, // Black text
                textStyle: TextStyle(
                  fontFamily: 'Quicksand', // Quicksand font
                ),
              ),
              onPressed: () {
                _shareSummary();
              },
              child: Text("Share"),
            ),
          ],
        ),
      ),
    );
  }

  void _shareSummary() {
    final String summary = userResponses.map((response) {
      return "${response['questionText']}\nChosen Option: ${response['chosenOption']}";
    }).join("\n\n");
    Share.share(summary, subject: 'Check out my learning journey!');
  }
}
