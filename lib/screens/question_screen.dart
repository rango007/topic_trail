import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'summary_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String topicId;
  final String topicName; // Added to receive the topic name

  QuestionScreen({required this.topicId, required this.topicName});

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  String? currentQuestionId;
  Map<String, dynamic>? currentQuestionData;
  List<String> userResponses = [];

  @override
  void initState() {
    super.initState();
    _loadInitialQuestion();
  }

  Future<void> _loadInitialQuestion() async {
    DocumentSnapshot topicSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(widget.topicId)
        .collection('questions')
        .limit(1)
        .get()
        .then((querySnapshot) => querySnapshot.docs.first);

    setState(() {
      currentQuestionId = topicSnapshot.id;
      currentQuestionData = topicSnapshot.data() as Map<String, dynamic>;
    });
  }

  Future<void> _loadQuestion(String questionId) async {
    DocumentSnapshot questionSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(widget.topicId)
        .collection('questions')
        .doc(questionId)
        .get();

    setState(() {
      currentQuestionId = questionSnapshot.id;
      currentQuestionData = questionSnapshot.data() as Map<String, dynamic>;
    });
  }

  String? getResizedImageUrl(String? imageUrl) {
    if (imageUrl == null) return null;

    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;
    final fileName = pathSegments.last;
    final extensionIndex = fileName.lastIndexOf('.');
    String resizedFileName;
    if (extensionIndex != -1) {
      resizedFileName = fileName.substring(0, extensionIndex) + '_200x200' + fileName.substring(extensionIndex);
    } else {
      resizedFileName = fileName + '_200x200';
    }
    return uri.replace(pathSegments: [...pathSegments.sublist(0, pathSegments.length - 1), resizedFileName]).toString();
  }

  void _onOptionSelected(int index) {
    setState(() {
      userResponses.add(currentQuestionData!['options'][index]['text']); // Access 'text' field of the option
      String? nextQuestionId = currentQuestionData!['options'][index]['nextQuestionId']; // Access 'nextQuestionId' field of the option
      if (nextQuestionId == null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SummaryScreen(userResponses: userResponses),
          ),
        );
      } else {
        _loadQuestion(nextQuestionId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (currentQuestionData == null) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    String? resizedImageUrl = getResizedImageUrl(currentQuestionData!['imageUrl']);
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName)), // Display the topic name in the app bar
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (resizedImageUrl != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Image.network(
                  resizedImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            Text(
              currentQuestionData!['text'],
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 16), // Added spacing between question text and options
            ...List.generate(
              currentQuestionData!['options'].length,
              (index) => ElevatedButton(
                onPressed: () => _onOptionSelected(index),
                child: Text(currentQuestionData!['options'][index]['text']), // Display the 'text' of the option
              ),
            ),
          ],
        ),
      ),
    );
  }
}
