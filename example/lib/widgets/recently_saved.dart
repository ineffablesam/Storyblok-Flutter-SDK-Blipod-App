import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

import '../controllers/layout_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../utils/custom_tap.dart';

class RecentlySavedWidget extends StatelessWidget {
  final StoryblokBlok blok;
  final Map<String, dynamic> props;

  const RecentlySavedWidget({
    super.key,
    required this.blok,
    required this.props,
  });

  static Widget builder(
    BuildContext context,
    StoryblokBlok blok,
    Map<String, dynamic> props,
  ) {
    return RecentlySavedWidget(blok: blok, props: props);
  }

  @override
  Widget build(BuildContext context) {
    final title = props['title'] as String? ?? 'Recently Saved';
    return StoryblokEditable(
      content: blok.toJson(),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppFonts.sf,
                  ),
                ),
                CustomTap(
                  onTap: () {
                    // use GetxController  LayoutController to  goToPage(3)
                    Get.find<LayoutController>().goToPage(1);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontFamily: AppFonts.sf,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          4.verticalSpace,
          // _BuildEmptyState(),
          _BuildSavedList(),
        ],
      ),
    );
  }
}

class _BuildSavedList extends StatelessWidget {
  const _BuildSavedList({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blackShade.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            removeBottom: true,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (context, index) => Padding(
                padding: EdgeInsets.symmetric(vertical: 7.h),
                child: Divider(
                  color: Colors.grey.shade800,
                  height: 1.h,
                  thickness: 1,
                  indent: 24.w,
                  endIndent: 24.w,
                ),
              ),
              itemBuilder: (context, index) => const _BuildSavedCard(),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuildSavedCard extends StatelessWidget {
  const _BuildSavedCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
      child: Row(
        children: [
          Row(
            spacing: 10,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 50.w,
                  height: 50.w,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cricket T20 World Cup 2025',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFonts.sf,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Author Name',
                    style: TextStyle(
                      color: Colors.grey.shade300,
                      fontFamily: AppFonts.sf,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  Text(
                    'Thursday 18 Sep, 2025',
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontFamily: AppFonts.sf,
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          CustomTap(
            onTap: () {
              // Navigate to all categories page
              // context.go('/saved');
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(LucideIcons.circlePlay, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildEmptyState extends StatelessWidget {
  const _BuildEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.blackShade.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 50.w),
          child: Column(
            children: [
              Text(
                'No recently saved podcasts.',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.sf,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
