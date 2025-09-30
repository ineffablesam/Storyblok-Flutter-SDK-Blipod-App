import 'dart:ui';

import 'package:example/utils/app_colors.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:miniplayer/miniplayer.dart';

import '../controllers/podcast_controller.dart';
import '../pages/podcast_player_page.dart';

class MiniPlayerWidget extends StatelessWidget {
  final PodcastController controller = Get.find<PodcastController>();
  final MiniplayerController miniplayerController = MiniplayerController();

  MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetX<PodcastController>(
      builder: (controller) {
        if (!controller.isPlayerVisible.value) return SizedBox.shrink();

        return Container(
          margin: EdgeInsets.only(
            bottom: controller.isExpanded.value ? 0 : 110.h,
          ),
          child: Miniplayer(
            controller: miniplayerController,
            minHeight: 80.h,
            maxHeight: MediaQuery.of(context).size.height,
            curve: Curves.easeInOut,
            duration: Duration(milliseconds: 300),
            elevation: 8,
            backgroundColor: Colors.transparent,
            onDismissed: () => controller.closePlayer(),
            onDismiss: () => controller.closePlayer(),
            builder: (height, percentage) {
              debugPrint('Miniplayer height: $height, percentage: $percentage');
              final bool isExpanded = percentage > 0.2;
              // Schedule state update after this build
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.percentage.value = percentage;
                controller.isExpanded.value = isExpanded;
              });

              if (isExpanded) {
                return PodcastPlayerScreen(
                  miniplayerController: miniplayerController,
                );
              } else {
                return _buildMiniPlayer();
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildMiniPlayer() {
    return GetX<PodcastController>(
      builder: (controller) => Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.blackShade.withOpacity(0.8),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.blackBorder.withOpacity(0.8),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Progress bar
                  SizedBox(
                    height: 2.h,
                    child: LinearProgressIndicator(
                      value: controller.progress,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),

                  // Main content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Thumbnail
                          Container(
                            width: 48.w,
                            height: 48.w, // keep square
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFFE8F4FD), Color(0xFFB8E0FF)],
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '∞',
                                style: TextStyle(
                                  color: Color(0xFF1877F2),
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          10.horizontalSpace,

                          // Title + Subtitle (Flexible to avoid overflow)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  controller.currentPodcast.value?.fileName ??
                                      'Unknown Title',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontFamily: AppFonts.sf,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  controller.currentPodcast.value?.fileName ??
                                      'Unknown Subtitle',
                                  style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 12.sp,
                                    fontFamily: AppFonts.sf,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(width: 10.w),

                          // Play/Pause button
                          GestureDetector(
                            onTap: controller.togglePlayPause,
                            child: Container(
                              width: 44.w,
                              height: 44.w,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                controller.isPlaying.value
                                    ? Icons.pause
                                    : Icons.play_arrow,
                                color: Colors.black,
                                size: 20.sp,
                              ),
                            ),
                          ),

                          SizedBox(width: 8.w),

                          // Close button
                          GestureDetector(
                            onTap: controller.closePlayer,
                            child: Container(
                              width: 32.w,
                              height: 32.w,
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
