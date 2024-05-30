import 'package:flutter/material.dart';
import 'edit_option_widget.dart';

class EditQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final ValueChanged<Map<String, dynamic>> onQuestionChanged;

  const EditQuestionWidget({Key? key, required this.question, required this.onQuestionChanged}) : super(key: key);

  @override
  _EditQuestionWidgetState createState() => _EditQuestionWidgetState();
}

class _EditQuestionWidgetState extends State<EditQuestionWidget> {
  late TextEditingController _textController;
  late TextEditingController _imageUrlController;
  late List<Map<String, dynamic>> _options;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question['text']);
    _imageUrlController = TextEditingController(text: widget.question['imageUrl']);
    _options = List<Map<String, dynamic>>.from(widget.question['options'] ?? []);
  }

  void _onOptionChanged(Map<String, dynamic> updatedOption) {
    setState(() {
      _options[_options.indexWhere((o) => o['id'] == updatedOption['id'])] = updatedOption;
      _updateQuestion();
    });
  }

  void _updateQuestion() {
    widget.onQuestionChanged({
      ...widget.question,
      'text': _textController.text,
      'imageUrl': _imageUrlController.text,
      'options': _options,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _textController,
          decoration: InputDecoration(labelText: 'Question Text'),
          onChanged: (value) => _updateQuestion(),
        ),
        TextFormField(
          controller: _imageUrlController,
          decoration: InputDecoration(labelText: 'Question Image URL'),
          onChanged: (value) => _updateQuestion(),
        ),
        ..._options.map((option) => EditOptionWidget(
              option: option,
              onOptionChanged: _onOptionChanged,
            )),
        SizedBox(height: 10),
      ],
    );
  }
}
