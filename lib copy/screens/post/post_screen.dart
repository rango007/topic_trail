import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';

import 'components/question_widget.dart';
import 'components/add_question_button.dart';
import 'components/question_dialog.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _topicDetailController = TextEditingController();
  final TextEditingController _otherCategoryController = TextEditingController();
  final List<Map<String, dynamic>> _questions = [];

  String? _postType;
  String? _category;
  String? _topicImageUrl;
  bool _isUploadingTopicImage = false;
  Map<String, bool> _isUploadingQuestionImage = {};

  @override
  void initState() {
    super.initState();
    _loadDraft();
  }

  void _addQuestion(String questionText, List<String> options) {
    String questionId = DateTime.now().millisecondsSinceEpoch.toString();
    setState(() {
      _questions.add({
        'id': questionId,
        'text': questionText,
        'options': [],
        'imageUrl': null,
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
      _questions.firstWhere(
          (question) => question['id'] == questionId)['text'] = newText;
    });
  }

  void _editOption(String questionId, int optionIndex, String newOption,
      String? nextQuestionId) {
    setState(() {
      _questions
              .firstWhere((question) => question['id'] == questionId)['options']
          [optionIndex] = {
        'text': newOption,
        'nextQuestionId': nextQuestionId,
      };
    });
  }

  Future<void> _pickImage(String questionId) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _isUploadingQuestionImage[questionId] = true;
      });
      String imageUrl = await _uploadImage(imageFile, 'question_images');
      setState(() {
        _questions.firstWhere(
            (question) => question['id'] == questionId)['imageUrl'] = imageUrl;
        _isUploadingQuestionImage[questionId] = false;
      });
    }
  }

  Future<void> _pickTopicImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      setState(() {
        _isUploadingTopicImage = true;
      });
      String imageUrl = await _uploadImage(imageFile, 'topic_images');
      setState(() {
        _topicImageUrl = imageUrl;
        _isUploadingTopicImage = false;
      });
    }
  }

  Future<String> _uploadImage(File imageFile, String folder) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageRef =
        FirebaseStorage.instance.ref().child(folder).child(fileName);
    UploadTask uploadTask = storageRef.putFile(imageFile);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  Future<void> _submitTopic() async {
    if (_topicController.text.isEmpty ||
        _questions.isEmpty ||
        _postType == null ||
        _category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill all the fields.'),
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
        'detail': _topicDetailController.text,
        'creatorId': FirebaseAuth.instance.currentUser!.uid,
        'timestamp': now,
        'imageUrl': _topicImageUrl,
        'postType': _postType,
        'category':
            _category == 'Others' ? _otherCategoryController.text : _category,
      });

      for (var question in _questions) {
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(topicId)
            .collection('questions')
            .doc(question['id'])
            .set({
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

      _clearDraft();
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

  void _showAddQuestionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return QuestionDialog(
          onAddQuestion: _addQuestion,
        );
      },
    );
  }

  Future<void> _saveDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> draftData = {
      'topic': _topicController.text,
      'detail': _topicDetailController.text,
      'postType': _postType,
      'category': _category,
      'otherCategory': _otherCategoryController.text,
      'topicImageUrl': _topicImageUrl,
      'questions': _questions,
    };
    await prefs.setString('draft', json.encode(draftData));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Draft saved successfully!'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _loadDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? draftString = prefs.getString('draft');
    if (draftString != null) {
      Map<String, dynamic> draftData = json.decode(draftString);
      setState(() {
        _topicController.text = draftData['topic'];
        _topicDetailController.text = draftData['detail'];
        _postType = draftData['postType'];
        _category = draftData['category'];
        _otherCategoryController.text = draftData['otherCategory'];
        _topicImageUrl = draftData['topicImageUrl'];
        _questions.clear();
        _questions.addAll(List<Map<String, dynamic>>.from(draftData['questions']));
      });
    }
  }

  Future<void> _clearDraft() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('draft');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                "Create Trails",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium!
                    .copyWith(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                value: _postType,
                decoration: InputDecoration(labelText: 'Post Type'),
                items: [
                  DropdownMenuItem(
                      value: 'Recent Events', child: Text('Recent Events')),
                  DropdownMenuItem(
                      value: 'General Topic', child: Text('General Topic')),
                ],
                onChanged: (value) {
                  setState(() {
                    _postType = value;
                  });
                },
              ),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: InputDecoration(labelText: 'Category'),
                items: [
                  DropdownMenuItem(value: 'Business', child: Text('Business')),
                  DropdownMenuItem(value: 'Technology', child: Text('Technology')),
                  DropdownMenuItem(value: 'Science', child: Text('Science')),
                  DropdownMenuItem(value: 'Others', child: Text('Others')),
                ],
                onChanged: (value) {
                  setState(() {
                    _category = value;
                  });
                },
              ),
              if (_category == 'Others')
                TextField(
                  controller: _otherCategoryController,
                  decoration: InputDecoration(labelText: 'Other Category'),
                ),
              TextField(
                controller: _topicController,
                decoration: InputDecoration(labelText: 'Topic'),
              ),
              TextField(
                controller: _topicDetailController,
                decoration: InputDecoration(labelText: 'Detail'),
              ),
              SizedBox(height: 16),
              Stack(
                children: [
                  ElevatedButton(
                    onPressed: _pickTopicImage,
                    child: Text('Pick Topic Image',
                        style: TextStyle(color: Colors.black)),
                  ),
                  if (_isUploadingTopicImage)
                    Positioned.fill(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                ],
              ),
              if (_topicImageUrl != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Image.network(
                    _topicImageUrl!,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
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
                      isUploadingImage:
                          _isUploadingQuestionImage[_questions[index]['id']] ??
                              false,
                    );
                  } else {
                    return AddQuestionButton(
                      onPressed: _showAddQuestionDialog,
                    );
                  }
                },
              ),
              ElevatedButton(
                onPressed: _submitTopic,
                child:
                    Text("Submit Topic", style: TextStyle(color: Colors.black)),
              ),
              ElevatedButton(
                onPressed: _saveDraft,
                child:
                    Text("Save Draft", style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
