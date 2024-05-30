import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

import 'components/animated_btn.dart';
import 'components/sign_in_dialog.dart';
import '../entryPoint/entry_point.dart';

class OnbodingScreen extends StatefulWidget {
  const OnbodingScreen({Key? key}) : super(key: key);

  @override
  State<OnbodingScreen> createState() => _OnbodingScreenState();
}

class _OnbodingScreenState extends State<OnbodingScreen> {
  late RiveAnimationController _btnAnimationController;

  bool isShowSignInDialog = false;

  @override
  void initState() {
    _btnAnimationController = OneShotAnimation(
      "active",
      autoplay: false,
    );
    super.initState();
  }

  void continueWithoutSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => EntryPoint(), // Navigate to your entry point
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onHorizontalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! < 0) {
            // User swiped from right to left
            continueWithoutSignIn();
          }
        },
        child: Stack(
          children: [
            Positioned(
              width: MediaQuery.of(context).size.width * 1.7,
              left: 100,
              bottom: 100,
              child: Image.asset(
                "assets/Backgrounds/Spline.png",
              ),
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: const SizedBox(),
              ),
            ),
            const RiveAnimation.asset(
              "assets/RiveAssets/shapes.riv",
            ),
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: const SizedBox(),
              ),
            ),
            AnimatedPositioned(
              top: isShowSignInDialog ? -50 : 0,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              duration: const Duration(milliseconds: 260),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),
                      SizedBox(
                        width: 260,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "News Stories & Hot Topics",
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.w700,
                                fontFamily: "Poppins",
                                height: 1.2,
                              ),
                            ),
                            SizedBox(height: 8), // Adjusted height here
                            Text(
                              "Be it what's happening in Israel-Gaza, Stock market or Bitcoin. Learn all in less than 5 minutes. Create your own customized trail for each story and share with your friends.",
                            ),
                            SizedBox(height: 2), // Space for arrow animation
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                height: 120,
                                width: 60,
                                child: Image.asset(
                                  "assets/Animations/swipe_arrows.gif",
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(flex: 1),
                      AnimatedBtn(
                        btnAnimationController: _btnAnimationController,
                        press: () {
                          _btnAnimationController.isActive = true;

                          Future.delayed(
                            const Duration(milliseconds: 800),
                            () {
                              setState(() {
                                isShowSignInDialog = true;
                              });
                              showCustomDialog(
                                context,
                                onValue: (_) {},
                              );
                            },
                          );
                        },
                      ),
                      InkWell(
                        onTap: continueWithoutSignIn,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            "Continue without Signing in",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
