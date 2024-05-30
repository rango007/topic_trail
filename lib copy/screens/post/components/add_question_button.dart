import 'package:flutter/material.dart';

class AddQuestionButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddQuestionButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text("Add Question", style: TextStyle(color: Colors.black)),
    );
  }
}
