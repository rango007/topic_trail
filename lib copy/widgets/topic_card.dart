import 'package:flutter/material.dart';

class TopicCard extends StatelessWidget {
  final String topicName;
  final String? imageUrl;
  final VoidCallback onTap;

  const TopicCard({
    Key? key,
    required this.topicName,
    this.imageUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 1, // Square aspect ratio
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : Placeholder(), // Placeholder for missing images
                ),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              topicName,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
