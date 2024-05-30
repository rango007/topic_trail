import 'package:flutter/material.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required this.title,
    required this.detail,
    required this.imageUrl,
    this.color = const Color(0xFF7553F6),
    this.fullScreen = false,
  }) : super(key: key);

  final String title, detail, imageUrl;
  final Color color;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double cardHeight = fullScreen ? screenHeight : 280;
    final double detailEndPosition = screenHeight * 0.15;

    return Container(
      height: cardHeight,
      width: fullScreen ? MediaQuery.of(context).size.width : 260,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(0)),
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(0)),
              color: Colors.black.withOpacity(0.5), // Semi-transparent overlay
            ),
          ),
          Positioned(
            bottom: detailEndPosition,
            left: 16.0,
            right: 16.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontFamily: 'Merriweather',
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 8), // Spacing between title and detail
                Text(
                  detail,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                      ),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
