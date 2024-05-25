import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SummaryScreen extends StatelessWidget {
  final List<String> userResponses;

  SummaryScreen({required this.userResponses});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Summary")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Your Learning Journey:", style: TextStyle(fontSize: 24)),
            ...userResponses.map((response) => Text(response)).toList(),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text("Start Over"),
            ),
            ElevatedButton(
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
    final String summary = userResponses.join("\n");
    Share.share(summary, subject: 'Check out my learning journey!');
  }
}
