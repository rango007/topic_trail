import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'components/edit_question_widget.dart';

class EditTopicPage extends StatefulWidget {
  final String topicId;

  const EditTopicPage({Key? key, required this.topicId}) : super(key: key);

  @override
  _EditTopicPageState createState() => _EditTopicPageState();
}

class _EditTopicPageState extends State<EditTopicPage> {
  final _formKey = GlobalKey<FormState>();
  String? _name;
  String? _detail;
  String? _postType;
  String? _category;
  File? _imageFile;
  String? _imageUrl;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadTopicData();
  }

  Future<void> _loadTopicData() async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('topics').doc(widget.topicId).get();
    var topicData = doc.data() as Map<String, dynamic>;

    QuerySnapshot questionsSnapshot = await FirebaseFirestore.instance
        .collection('topics')
        .doc(widget.topicId)
        .collection('questions')
        .get();

    List<Map<String, dynamic>> questions = [];
    for (var questionDoc in questionsSnapshot.docs) {
      var questionData = questionDoc.data() as Map<String, dynamic>;
      questionData['id'] = questionDoc.id;
      questions.add(questionData);
    }

    setState(() {
      _name = topicData['name'];
      _detail = topicData['detail'];
      _postType = topicData['postType'];
      _category = topicData['category'];
      _imageUrl = topicData['imageUrl'];
      _questions = questions;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null) return;

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('topics/${widget.topicId}/${DateTime.now().millisecondsSinceEpoch}');
    UploadTask uploadTask = storageReference.putFile(_imageFile!);
    await uploadTask.whenComplete(() => null);

    String imageUrl = await storageReference.getDownloadURL();
    setState(() {
      _imageUrl = imageUrl;
    });
  }

  Future<void> _saveTopic() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      await _uploadImage();

      await FirebaseFirestore.instance.collection('topics').doc(widget.topicId).update({
        'name': _name,
        'detail': _detail,
        'postType': _postType,
        'category': _category,
        'imageUrl': _imageUrl,
      });

      for (var question in _questions) {
        String questionId = question['id'];
        await FirebaseFirestore.instance
            .collection('topics')
            .doc(widget.topicId)
            .collection('questions')
            .doc(questionId)
            .update({
          'text': question['text'],
          'imageUrl': question['imageUrl'],
        });

        for (var option in question['options']) {
          String optionId = option['id'];
          await FirebaseFirestore.instance
              .collection('topics')
              .doc(widget.topicId)
              .collection('questions')
              .doc(questionId)
              .collection('options')
              .doc(optionId)
              .update({
            'text': option['text'],
            'nextQuestionId': option['nextQuestionId'],
          });
        }
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Topic'),
      ),
      body: _name == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: _name,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) => _name = value,
                    ),
                    TextFormField(
                      initialValue: _detail,
                      decoration: InputDecoration(labelText: 'Detail'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a detail';
                        }
                        return null;
                      },
                      onSaved: (value) => _detail = value,
                    ),
                    TextFormField(
                      initialValue: _postType,
                      decoration: InputDecoration(labelText: 'Post Type'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a post type';
                        }
                        return null;
                      },
                      onSaved: (value) => _postType = value,
                    ),
                    TextFormField(
                      initialValue: _category,
                      decoration: InputDecoration(labelText: 'Category'),
                      validator: (value) {
                        if (value?.isEmpty ?? true) {
                          return 'Please enter a category';
                        }
                        return null;
                      },
                      onSaved: (value) => _category = value,
                    ),
                    SizedBox(height: 20),
                    _imageFile == null && _imageUrl == null
                        ? Text('No image selected.')
                        : _imageFile != null
                            ? Image.file(_imageFile!)
                            : Image.network(_imageUrl!),
                    ElevatedButton(
                      onPressed: _pickImage,
                      child: Text('Change Image'),
                    ),
                    SizedBox(height: 20),
                    ..._questions.map((question) => EditQuestionWidget(
                          question: question,
                          onQuestionChanged: (updatedQuestion) {
                            setState(() {
                              _questions[_questions.indexWhere((q) => q['id'] == updatedQuestion['id'])] = updatedQuestion;
                            });
                          },
                        )),
                    ElevatedButton(
                      onPressed: _saveTopic,
                      child: Text('Save'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
