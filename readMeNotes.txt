import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class CreateTopicScreen extends StatefulWidget {
  @override
  _CreateTopicScreenState createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final TextEditingController _topicController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];
  final ImagePicker _picker = ImagePicker();

  void _addQuestion(String questionText, List<String> options, String imageUrl) {
    String questionId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _questions.add({
        'id': questionId,
        'text': questionText,
        'options': [], // Initialize empty options
        'imageUrl': imageUrl, // Add image URL field
      });
    });
  }

  void _addOption(String questionId, String option, String? nextQuestionId) {
    setState(() {
      _questions
          .firstWhere((question) => question['id'] == questionId)['options']
          .add({
        'text': option,
        'nextQuestionId': nextQuestionId,
      });
    });
  }

  void _editQuestion(String questionId, String newText) {
    setState(() {
      _questions
          .firstWhere((question) => question['id'] == questionId)['text'] = newText;
    });
  }

  void _editOption(String questionId, int optionIndex, String newOption, String? nextQuestionId) {
    setState(() {
      _questions
          .firstWhere((question) => question['id'] == questionId)['options'][optionIndex] = {
        'text': newOption,
        'nextQuestionId': nextQuestionId,
      };
    });
  }

  Future<void> _submitTopic() async {
    if (_topicController.text.isEmpty || _questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a topic name and at least one question.'),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      String topicId = FirebaseFirestore.instance.collection('topics').doc().id;
      Timestamp now = Timestamp.now();
      await FirebaseFirestore.instance.collection('topics').doc(topicId).set({
        'name': _topicController.text,
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': now,
      });

      for (var question in _questions) {
        await FirebaseFirestore.instance.collection('topics').doc(topicId).collection('questions').doc(question['id']).set({
          'text': question['text'],
          'options': question['options'],
          'imageUrl': question['imageUrl'],
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Topic submitted successfully!'),
          duration: Duration(seconds: 3),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit topic. Please try again later.'),
          duration: Duration(seconds: 3),
        ),
      );
      print('Error submitting topic: $e');
    }
  }

  Future<void> _pickImage(String questionId) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference = FirebaseStorage.instance.ref().child('questions/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _questions.firstWhere((question) => question['id'] == questionId)['imageUrl'] = downloadUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Topic")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _topicController,
              decoration: InputDecoration(labelText: 'Topic Name'),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _questions.length + 1,
                itemBuilder: (context, index) {
                  if (index < _questions.length) {
                    return QuestionWidget(
                      question: _questions[index],
                      onAddOption: _addOption,
                      onEditQuestion: _editQuestion,
                      onEditOption: _editOption,
                      onPickImage: _pickImage,
                      questions: _questions,
                    );
                  } else {
                    return AddQuestionButton(
                      onPressed: () {
                        _showAddQuestionDialog();
                      },
                    );
                  }
                },
              ),
            ),
            ElevatedButton(
              onPressed: _submitTopic,
              child: Text("Submit Topic"),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddQuestionDialog() {
    String questionText = '';
    List<String> options = [];
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Question'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(labelText: 'Question Text'),
                onChanged: (value) => questionText = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addQuestion(questionText, options, '');
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

class QuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function(String, String) onEditQuestion;
  final Function(String, int, String, String?) onEditOption;
  final Function(String, String, String?) onAddOption;
  final Function(String) onPickImage;
  final List<Map<String, dynamic>> questions;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.onEditQuestion,
    required this.onEditOption,
    required this.onAddOption,
    required this.onPickImage,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(labelText: 'Question Text'),
              onChanged: (newText) => onEditQuestion(question['id'], newText),
              controller: TextEditingController(text: question['text']),
            ),
            SizedBox(height: 8),
            question['imageUrl'] != ''
                ? Image.network(question['imageUrl'])
                : Container(),
            ElevatedButton(
              onPressed: () => onPickImage(question['id']),
              child: Text('Upload Image'),
            ),
            SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: question['options'].length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: TextField(
                    decoration: InputDecoration(labelText: 'Option Text'),
                    onChanged: (newOption) => onEditOption(question['id'], index, newOption, question['options'][index]['nextQuestionId']),
                    controller: TextEditingController(text: question['options'][index]['text']),
                  ),
                  subtitle: DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Link to Question'),
                    value: question['options'][index]['nextQuestionId'],
                    items: questions.map((question) {
                      return DropdownMenuItem<String>(
                        value: question['id'],
                        child: Text(question['text']),
                      );
                    }).toList(),
                    onChanged: (value) {
                      onEditOption(question['id'], index, question['options'][index]['text'], value);
                    },
                  ),
                );
              },
            ),
            SizedBox(height: 8),
            ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    String newOption = '';
                    String? selectedQuestionId;

                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text('Add Option'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                decoration: InputDecoration(labelText: 'Option Text'),
                                onChanged: (value) => newOption = value,
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(labelText: 'Link to Question'),
                                value: selectedQuestionId,
                                items: questions.map((question) {
                                  return DropdownMenuItem<String>(
                                    value: question['id'],
                                    child: Text(question['text']),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedQuestionId = value;
                                  });
                                },
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                onAddOption(question['id'], newOption, selectedQuestionId);
                              },
                              child: Text('Add'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
              child: Text('Add Option'),
            ),
          ],
        ),
      ),
    );
  }
}

class AddQuestionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddQuestionButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text("Add Question"),
    );
  }
}
