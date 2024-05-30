import 'dart:math';

import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/history/history_screen.dart';
import '../../screens/notification/notification_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/post/post_screen.dart';
import '../onboding/onboding_screen.dart';
import '../../utils/rive_utils.dart';

import '../../models/menu.dart';
import 'components/btm_nav_item.dart';
import 'components/menu_btn.dart';
import 'components/post_btn.dart';
import 'components/side_bar.dart';

class EntryPoint extends StatefulWidget {
  const EntryPoint({super.key});

  @override
  State<EntryPoint> createState() => _EntryPointState();
}

class _EntryPointState extends State<EntryPoint> with SingleTickerProviderStateMixin {
  bool isSideBarOpen = false;

  Menu selectedBottonNav = bottomNavItems.first;
  Menu selectedSideMenu = sidebarMenus.first;

  late SMIBool isMenuOpenInput;

  late String userName = "Your Name";
  late String userBio = "Bio";
  bool isUserSignedIn = false;

  void updateSelectedBtmNav(Menu menu) {
    if (selectedBottonNav != menu) {
      setState(() {
        selectedBottonNav = menu;
      });
    }
  }

  late AnimationController _animationController;
  late Animation<double> scalAnimation;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addListener(() {
        setState(() {});
      });
    scalAnimation = Tween<double>(begin: 1, end: 0.8).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));
    animation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
        parent: _animationController, curve: Curves.fastOutSlowIn));

    _checkUserStatus();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSidebar() {
    isMenuOpenInput.value = !isMenuOpenInput.value;

    if (_animationController.value == 0) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }

    setState(() {
      isSideBarOpen = !isSideBarOpen;
    });
  }

  void _onPostBtnPressed() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _toggleSidebar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please sign in to create a post.'),
          duration: Duration(seconds: 3),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) => const PostPage(),
      );
    }
  }

  Future<void> _checkUserStatus() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        isUserSignedIn = true;
      });

      // Fetch user details from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userName = userDoc['name'] ?? "Your Name";
          userBio = userDoc['bio'] ?? "Bio";
        });
      }
    } else {
      setState(() {
        isUserSignedIn = false;
      });
    }
  }

  void _onSignOut() async {
    await FirebaseAuth.instance.signOut();
    setState(() {
      isUserSignedIn = false;
      userName = "Your Name";
      userBio = "Bio";
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnbodingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor2,
      body: Stack(
        children: [
          AnimatedPositioned(
            width: 288,
            height: MediaQuery.of(context).size.height,
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 0 : -288,
            top: 0,
            child: SideBar(
              userName: userName,
              userBio: userBio,
              isUserSignedIn: isUserSignedIn,
              onSignOut: _onSignOut,
            ),
          ),
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(
                  1 * animation.value - 30 * (animation.value) * pi / 180),
            child: Transform.translate(
              offset: Offset(animation.value * 265, 0),
              child: Transform.scale(
                scale: scalAnimation.value,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(24),
                  ),
                  child: _buildPage(),  // Update to dynamically build the page
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            curve: Curves.fastOutSlowIn,
            left: isSideBarOpen ? 220 : 0,
            top: 16,
            child: MenuBtn(
              press: _toggleSidebar,
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");

                artboard.addController(controller!);

                isMenuOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isMenuOpenInput.value = true;
              },
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: PostBtn(
              press: _onPostBtnPressed,
              riveOnInit: (artboard) {
                final controller = StateMachineController.fromArtboard(
                    artboard, "State Machine");

                artboard.addController(controller!);

                final isPostOpenInput =
                    controller.findInput<bool>("isOpen") as SMIBool;
                isPostOpenInput.value = true;
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Transform.translate(
        offset: Offset(0, 100 * animation.value),
        child: SafeArea(
          child: Container(
            padding:
                const EdgeInsets.only(left: 12, top: 12, right: 12, bottom: 12),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            decoration: BoxDecoration(
              color: backgroundColor2.withOpacity(0.8),
              borderRadius: const BorderRadius.all(Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor2.withOpacity(0.3),
                  offset: const Offset(0, 20),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ...List.generate(
                  bottomNavItems.length,
                  (index) {
                    Menu navBar = bottomNavItems[index];
                    return BtmNavItem(
                      navBar: navBar,
                      press: () {
                        RiveUtils.chnageSMIBoolState(navBar.rive.status!);
                        updateSelectedBtmNav(navBar);
                      },
                      riveOnInit: (artboard) {
                        navBar.rive.status = RiveUtils.getRiveInput(artboard,
                            stateMachineName: navBar.rive.stateMachineName);
                      },
                      selectedNav: selectedBottonNav,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to build the main content based on the selected bottom nav item
  Widget _buildPage() {
    switch (selectedBottonNav.id) {  // Use an identifier for the Menu items
      case 'home':
        return HomePage();
      case 'search':
        return SearchPage();
      case 'history':
        return HistoryPage();
      case 'notification':
        return NotificationPage();
      case 'profile':
        return ProfilePage();
      default:
        return HomePage();
    }
  }
}
