import 'package:flutter/material.dart';

class QuestionDialog extends StatefulWidget {
  final Function(String, List<String>) onAddQuestion;

  const QuestionDialog({Key? key, required this.onAddQuestion}) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  String questionText = '';
  List<String> options = [];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Question'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Question Text'),
            onChanged: (value) => setState(() {
              questionText = value;
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            widget.onAddQuestion(questionText, options);
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}
