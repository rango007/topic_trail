import 'package:flutter/material.dart';

class EditOptionWidget extends StatefulWidget {
  final Map<String, dynamic> option;
  final ValueChanged<Map<String, dynamic>> onOptionChanged;

  const EditOptionWidget({Key? key, required this.option, required this.onOptionChanged}) : super(key: key);

  @override
  _EditOptionWidgetState createState() => _EditOptionWidgetState();
}

class _EditOptionWidgetState extends State<EditOptionWidget> {
  late TextEditingController _textController;
  late TextEditingController _nextQuestionIdController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.option['text']);
    _nextQuestionIdController = TextEditingController(text: widget.option['nextQuestionId']);
  }

  void _updateOption() {
    widget.onOptionChanged({
      ...widget.option,
      'text': _textController.text,
      'nextQuestionId': _nextQuestionIdController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _textController,
          decoration: InputDecoration(labelText: 'Option Text'),
          onChanged: (value) => _updateOption(),
        ),
        TextFormField(
          controller: _nextQuestionIdController,
          decoration: InputDecoration(labelText: 'Next Question ID'),
          onChanged: (value) => _updateOption(),
        ),
        SizedBox(height: 10),
      ],
    );
  }
}
