import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:example/controllers/layout_controller.dart';
import 'package:example/controllers/podcast_controller.dart';
import 'package:example/pages/account_page.dart';
import 'package:example/pages/audio_page.dart';
import 'package:example/pages/browse_page.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/utils/app_colors.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:example/widgets/mini_player_widget.dart';
import 'package:family_bottom_sheet/family_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MainLayout extends StatelessWidget {
  MainLayout({super.key});

  final LayoutController controller = Get.put(LayoutController());
  final PodcastController podcastController = Get.put(PodcastController());

  final List<Widget> _pages = const [
    HomePage(),
    AudioPage(),
    BrowsePage(),
    AccountPage(),
    // OpenContainerDemo(),
  ];

  @override
  Widget build(BuildContext context) {
    const List<double> darkMatrix = <double>[
      1.385, -0.56, -0.112, 0.0, 0.3, //
      -0.315, 1.14, -0.112, 0.0, 0.3, //
      -0.315, -0.56, 1.588, 0.0, 0.3, //
      0.0, 0.0, 0.0, 1.0, 0.0,
    ];
    return Scaffold(
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showGenerateSheet(context),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        return Stack(
          children: [
            // main pages with transition
            PageTransitionSwitcher(
              duration: const Duration(milliseconds: 400),
              reverse: controller.isReverse,
              transitionBuilder: (child, animation, secondaryAnimation) {
                return SharedAxisTransition(
                  animation: animation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  child: child,
                );
              },
              child: KeyedSubtree(
                key: ValueKey<int>(controller.currentIndex.value),
                child: _pages[controller.currentIndex.value],
              ),
            ),

            // Mini Player
            MiniPlayerWidget(),
          ],
        );
      }),
      bottomNavigationBar: Obx(() {
        final slide = podcastController.percentage.value;
        return AnimatedSlide(
          duration: const Duration(milliseconds: 100),
          // curve: Curves.easeInOut,
          offset: Offset(0, slide),
          child: Container(
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.only(left: 12.w, right: 12.w, bottom: 18.h),
            height: 83.h,
            decoration: BoxDecoration(
              color: AppColors.blackShade.withOpacity(0.4),
              borderRadius: BorderRadius.circular(100.r),
              border: Border.all(color: AppColors.blackBorder, width: 2),
            ),
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                BackdropFilter(
                  filter: ImageFilter.compose(
                    outer: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    inner: ColorFilter.matrix(darkMatrix),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blackShade.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                  ),
                ),
                MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  removeBottom: true,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      splashFactory: InkSparkle.splashFactory,
                      highlightColor: Colors.transparent,
                    ),
                    child: BottomNavigationBar(
                      currentIndex: controller.currentIndex.value,
                      onTap: controller.changeTab,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      selectedItemColor: Colors.white,
                      unselectedItemColor: Colors.grey,
                      selectedLabelStyle: TextStyle(
                        fontFamily: AppFonts.sf,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontFamily: AppFonts.sf,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                      items: [
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Icon(LucideIcons.inbox500),
                          ),
                          label: 'Home',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Icon(LucideIcons.headphones500),
                          ),
                          label: 'Audio',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Icon(LucideIcons.chartBarBig500),
                          ),
                          label: 'Browse',
                        ),
                        BottomNavigationBarItem(
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 2.0),
                            child: Icon(LucideIcons.user500),
                          ),
                          label: 'You',
                        ),
                        // BottomNavigationBarItem(
                        //   icon: Padding(
                        //     padding: const EdgeInsets.only(bottom: 2.0),
                        //     child: Icon(LucideIcons.user500),
                        //   ),
                        //   label: 'You',
                        // ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showGenerateSheet(BuildContext context) async {
    await FamilyModalSheet.show<void>(
      context: context,
      contentBackgroundColor: AppColors.blackShade,
      builder: (ctx) {
        return const GenerateSheet();
      },
    );
  }
}

class GenerateSheet extends StatelessWidget {
  const GenerateSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + Close
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add Link",
                style: TextStyle(
                  fontSize: 22.sp,
                  fontFamily: AppFonts.sf,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            "Enter a link to generate a podcast",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              fontFamily: AppFonts.sf,
              fontWeight: FontWeight.w300,
              color: Colors.grey[400],
            ),
          ),
          20.verticalSpace,
          // Input field
          TextField(
            autofocus: true,
            decoration: InputDecoration(
              hintText: "Enter text...",
              fillColor: Colors.grey[900],
              filled: true,

              border: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.blackBorder, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          15.verticalSpace,
          // Generate button
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary, width: 1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: Text(
                "Generate",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: AppFonts.sf,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          20.verticalSpace,
        ],
      ),
    );
  }
}
