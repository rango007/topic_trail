import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'summary_screen.dart';
import 'components/course_card.dart';

class TopicPage extends StatefulWidget {
  final String topicId;
  final String topicName;

  const TopicPage({Key? key, required this.topicId, required this.topicName}) : super(key: key);

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  String? currentQuestionId;
  Map<String, dynamic>? currentQuestionData;
  List<Map<String, String?>> userResponses = []; // Track user responses with more details

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
      currentQuestionData = topicSnapshot.data() as Map<String, dynamic>?;
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
      currentQuestionData = questionSnapshot.data() as Map<String, dynamic>?;
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
      resizedFileName = fileName.substring(0, extensionIndex) + '_400x400' + fileName.substring(extensionIndex);
    } else {
      resizedFileName = fileName + '_400x400';
    }
    return uri.replace(pathSegments: [...pathSegments.sublist(0, pathSegments.length - 1), resizedFileName]).toString();
  }

  void _onOptionSelected(int index) {
    setState(() {
      userResponses.add({
        'imageUrl': currentQuestionData!['imageUrl'],
        'questionText': currentQuestionData!['text'],
        'chosenOption': currentQuestionData!['options'][index]['text'],
      }); // Track the selected option and question details

      String? nextQuestionId = currentQuestionData!['options'][index]['nextQuestionId']; // Get the next question ID

      if (nextQuestionId == null) {
        // Navigate to SummaryScreen when no more questions
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => SummaryScreen(userResponses: userResponses),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.ease;
              final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              final offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: child,
              );
            },
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
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          widget.topicName,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Merriweather-Bold',
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: CourseCard(
          color: Colors.black, // Provide a black background
          imageUrl: resizedImageUrl,
          questionText: currentQuestionData!['text'],
          options: List<Map<String, dynamic>>.from(currentQuestionData!['options']),
          onOptionSelected: _onOptionSelected,
        ),
      ),
    );
  }
}
