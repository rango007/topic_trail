import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseCard extends StatelessWidget {
  const CourseCard({
    Key? key,
    required this.title,
    required this.imageUrl,
    this.color = const Color(0xFF7553F6),
    this.fullScreen = false,
  }) : super(key: key);

  final String title, imageUrl;
  final Color color;
  final bool fullScreen;

  @override
  Widget build(BuildContext context) {
    final double cardHeight = fullScreen ? MediaQuery.of(context).size.height : 280;
    final double twoThirdsCardHeight = cardHeight * (2 / 3);

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
            left: 16,
            right: 16,
            top: twoThirdsCardHeight,
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontFamily: 'Merriweather',
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
