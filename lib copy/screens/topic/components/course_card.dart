import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    this.color = const Color(0xFF7553F6),
    this.imageUrl,
    required this.questionText,
    required this.options,
    required this.onOptionSelected,
  }) : super(key: key);

  final Color color;
  final String? imageUrl;
  final String questionText;
  final List<Map<String, dynamic>> options;
  final Function(int) onOptionSelected;

  @override
  Widget build(BuildContext context) {
    // Get screen size
    Size screenSize = MediaQuery.of(context).size;

    return Container(
      height: screenSize.height,
      width: screenSize.width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.all(Radius.circular(0)),
      ),
      child: Column(
        children: [
          // Topic Image (if imageUrl is not null and not empty)
          if (imageUrl != null && imageUrl!.isNotEmpty)
            Expanded(
              flex: 4,
              child: Image.network(
                imageUrl!,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          // Question Text
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              questionText,
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[300], // Softer white color
                fontFamily: 'Quicksand', // Fun and easy-to-read font
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Reduced Spacer to decrease gap
          SizedBox(height: 10), // Decreased gap
          // Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Wrap(
              spacing: 20,
              runSpacing: 10,
              children: List.generate(
                options.length,
                (index) => SizedBox(
                  width: (screenSize.width / 2) - 30,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // Background color
                      foregroundColor: Colors.black, // Text color
                      textStyle: TextStyle(
                        fontFamily: 'Quicksand',
                      ),
                    ),
                    onPressed: () => onOptionSelected(index),
                    child: Text(options[index]['text']),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
