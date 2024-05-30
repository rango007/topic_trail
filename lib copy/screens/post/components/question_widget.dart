import 'package:flutter/material.dart';

class QuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final Function(String, String) onEditQuestion;
  final Function(String, int, String, String?) onEditOption;
  final Function(String, String, String?) onAddOption;
  final Function(String) onPickImage;
  final List<Map<String, dynamic>> questions;
  final bool isUploadingImage;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.onEditQuestion,
    required this.onEditOption,
    required this.onAddOption,
    required this.onPickImage,
    required this.questions,
    required this.isUploadingImage,
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
            Stack(
              children: [
                ElevatedButton(
                  onPressed: () => onPickImage(question['id']),
                  child:
                      Text('Pick Image', style: TextStyle(color: Colors.black)),
                ),
                if (isUploadingImage)
                  Positioned.fill(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
            if (question['imageUrl'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Image.network(
                  question['imageUrl'],
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
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
                    onChanged: (newOption) => onEditOption(
                        question['id'],
                        index,
                        newOption,
                        question['options'][index]['nextQuestionId']),
                    controller: TextEditingController(
                        text: question['options'][index]['text']),
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
                      onEditOption(question['id'], index,
                          question['options'][index]['text'], value);
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
                                decoration:
                                    InputDecoration(labelText: 'Option Text'),
                                onChanged: (value) => newOption = value,
                              ),
                              SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                decoration: InputDecoration(
                                    labelText: 'Link to Question'),
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
                                onAddOption(question['id'], newOption,
                                    selectedQuestionId);
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
              child: Text('Add Option', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}
