import 'package:example/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../utils/app_fonts.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Colors.black,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [TopBar()],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  SizedBox(height: 40.h),
                  const ProfileSection(),
                  SizedBox(height: 40.h),
                  const StreakWidget(),
                  10.verticalSpace,
                  const ArchiveButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TopBar extends StatelessWidget {
  const TopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.blackShade,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackBorder, width: 1.w),
            ),
            child: Icon(Icons.link, color: Colors.white, size: 20.sp),
          ),
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.blackShade,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.blackBorder, width: 1.w),
            ),
            child: Icon(Icons.more_horiz, color: Colors.white, size: 20.sp),
          ),
        ],
      ),
    );
  }
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 120.w,
          height: 120.w,
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Sound wave lines
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  final heights = [20.h, 35.h, 25.h, 40.h, 25.h, 35.h, 20.h];
                  return Container(
                    width: 3.w,
                    height: heights[index],
                    margin: EdgeInsets.symmetric(horizontal: 1.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(1.5.r),
                    ),
                  );
                }),
              ),
              // Lightning bolt icon
              Positioned(
                child: Container(
                  width: 24.w,
                  height: 24.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt, color: Colors.orange, size: 16.sp),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          "Anish's Blipod",
          style: TextStyle(
            color: Colors.white,
            fontSize: 28.sp,
            fontFamily: AppFonts.sf,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class StreakWidget extends StatelessWidget {
  const StreakWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '🔥',
                style: TextStyle(fontSize: 24.sp, fontFamily: AppFonts.sf),
              ),
              SizedBox(width: 8.w),
              Text(
                '0 day streak',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFonts.sf,
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                '🔥',
                style: TextStyle(fontSize: 24.sp, fontFamily: AppFonts.sf),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          const WeeklyStreak(),
        ],
      ),
    );
  }
}

class WeeklyStreak extends StatelessWidget {
  const WeeklyStreak({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Mon', 'Tue'];
    final isActive = [false, false, false, true, false, false, false];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (index) {
        return Expanded(
          child: Column(
            children: [
              Text(
                days[index],
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12.sp,
                  fontFamily: AppFonts.sf,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: isActive[index] ? null : Colors.grey[800],
                  shape: BoxShape.circle,
                ),
                child: isActive[index]
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '🔥',
                            style: TextStyle(
                              fontFamily: AppFonts.sf,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class ArchiveButton extends StatelessWidget {
  const ArchiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: () {},
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Archive',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontFamily: AppFonts.sf,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400], size: 24.sp),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
