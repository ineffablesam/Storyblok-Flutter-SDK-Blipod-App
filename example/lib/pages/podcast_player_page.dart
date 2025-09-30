import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:miniplayer/miniplayer.dart';

import '../controllers/podcast_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class PodcastPlayerScreen extends StatelessWidget {
  final MiniplayerController miniplayerController;
  final PodcastController controller = Get.find<PodcastController>();

  PodcastPlayerScreen({super.key, required this.miniplayerController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Obx(() {
          final currentPodcast = controller.currentPodcast.value;

          if (currentPodcast == null) {
            return Center(
              child: Text(
                'No podcast selected',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16.sp,
                  fontFamily: AppFonts.sf,
                ),
              ),
            );
          }

          return SingleChildScrollView(
            // physics: NeverScrollableScrollPhysics(),
            child: Column(
              children: [
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => miniplayerController.animateToHeight(
                          state: PanelState.MIN,
                        ),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down,
                            color: Colors.white,
                            size: 24.sp,
                          ),
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            'NOW PLAYING',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                              fontFamily: AppFonts.sf,
                            ),
                          ),
                          Text(
                            currentPodcast.status.toUpperCase(),
                            style: TextStyle(
                              color: currentPodcast.isCompleted
                                  ? AppColors.primary
                                  : Colors.grey,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              fontFamily: AppFonts.sf,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => controller.closePlayer(),
                        child: Container(
                          width: 40.w,
                          height: 40.h,
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                20.verticalSpace,

                // Album Art / Thumbnail
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 40.w),
                  width: double.infinity,
                  height: 200.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.3),
                        AppColors.primary.withOpacity(0.1),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Main Icon
                      Container(
                        width: 100.w,
                        height: 100.w,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          LucideIcons.audioLines,
                          color: Colors.white,
                          size: 48.sp,
                        ),
                      ),
                      // Floating decorative icons
                      Positioned(
                        top: 40.h,
                        left: 40.w,
                        child: _buildFloatingIcon(
                          LucideIcons.headphones,
                          Colors.blue,
                        ),
                      ),
                      Positioned(
                        top: 120.h,
                        right: 30.w,
                        child: _buildFloatingIcon(
                          LucideIcons.mic,
                          Colors.purple,
                        ),
                      ),
                      Positioned(
                        bottom: 80.h,
                        left: 30.w,
                        child: _buildFloatingIcon(
                          LucideIcons.volume2,
                          Colors.orange,
                        ),
                      ),
                      Positioned(
                        bottom: 50.h,
                        right: 60.w,
                        child: _buildFloatingIcon(
                          LucideIcons.radio,
                          Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),

                24.verticalSpace,

                // Article Info
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40.w),
                  child: Column(
                    children: [
                      Text(
                        currentPodcast.articleTitle ?? 'Untitled Article',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          fontFamily: AppFonts.sf,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      8.verticalSpace,
                      Text(
                        currentPodcast.articleUrl,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          fontFamily: AppFonts.sf,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (currentPodcast.fileName != null) ...[
                        4.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.fileAudio,
                                color: AppColors.primary,
                                size: 14.sp,
                              ),
                              6.horizontalSpace,
                              Flexible(
                                child: Text(
                                  currentPodcast.fileName!,
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: AppFonts.sf,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                16.verticalSpace,

                // Progress Bar
                Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.primary,
                            inactiveTrackColor: Colors.grey.withOpacity(0.3),
                            thumbColor: AppColors.primary,
                            thumbShape: RoundSliderThumbShape(
                              enabledThumbRadius: 6.r,
                            ),
                            overlayColor: AppColors.primary.withOpacity(0.2),
                            trackHeight: 3.h,
                          ),
                          child: Slider(
                            value: controller.currentPosition.value,
                            max: controller.totalDuration.value > 0
                                ? controller.totalDuration.value
                                : 1.0,
                            onChanged: (value) => controller.seekTo(value),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.formatDuration(
                                controller.currentPosition.value,
                              ),
                              style: TextStyle(
                                fontFamily: AppFonts.sf,
                                color: Colors.grey,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              controller.formatDuration(
                                controller.totalDuration.value,
                              ),
                              style: TextStyle(
                                fontFamily: AppFonts.sf,
                                color: Colors.grey,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                20.verticalSpace,

                // Controls
                Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 50.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildControlButton(
                          LucideIcons.skipBack,
                          onTap: controller.skipBackward,
                        ),
                        _buildPlayButton(controller),
                        _buildControlButton(
                          LucideIcons.skipForward,
                          onTap: controller.skipForward,
                        ),
                      ],
                    ),
                  ),
                ),

                24.verticalSpace,

                // Bottom Controls
                Obx(
                  () => Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomButton(
                          LucideIcons.share2,
                          onTap: () {
                            // Implement share functionality
                            Get.snackbar(
                              'Share',
                              'Share functionality coming soon',
                              backgroundColor: AppColors.primary.withOpacity(
                                0.8,
                              ),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          },
                        ),
                        _buildSpeedButton(controller),
                        _buildBottomButton(
                          LucideIcons.download,
                          onTap: () {
                            if (currentPodcast.audioFileUrl != null) {
                              Get.snackbar(
                                'Download',
                                'Download functionality coming soon',
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.8,
                                ),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            } else {
                              Get.snackbar(
                                'Error',
                                'Audio file not available',
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                20.verticalSpace,

                // Article Summary (if available)
                if (currentPodcast.summaryText != null &&
                    currentPodcast.summaryText!.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.blackShade.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: AppColors.blackBorder.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.fileText,
                                color: AppColors.primary,
                                size: 16.sp,
                              ),
                              8.horizontalSpace,
                              Text(
                                'Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  fontFamily: AppFonts.sf,
                                ),
                              ),
                            ],
                          ),
                          12.verticalSpace,
                          Text(
                            currentPodcast.summaryText!,
                            style: TextStyle(
                              color: Colors.grey.shade300,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              fontFamily: AppFonts.sf,
                              height: 1.5,
                            ),
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                30.verticalSpace,
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFloatingIcon(IconData icon, Color color) {
    return Container(
      width: 36.w,
      height: 36.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 18.sp),
    );
  }

  Widget _buildControlButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56.w,
        height: 56.h,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1),
        ),
        child: Icon(icon, color: Colors.white, size: 24.sp),
      ),
    );
  }

  Widget _buildPlayButton(PodcastController controller) {
    return GestureDetector(
      onTap: controller.togglePlayPause,
      child: Container(
        width: 80.w,
        height: 80.h,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          controller.isPlaying.value ? LucideIcons.pause : LucideIcons.play,
          color: Colors.white,
          size: 36.sp,
        ),
      ),
    );
  }

  Widget _buildBottomButton(IconData icon, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: Colors.grey.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.grey.shade400, size: 20.sp),
      ),
    );
  }

  Widget _buildSpeedButton(PodcastController controller) {
    return GestureDetector(
      onTap: controller.changeSpeed,
      child: Container(
        width: 44.w,
        height: 44.h,
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            '${controller.playbackSpeed.value}x',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              fontFamily: AppFonts.sf,
            ),
          ),
        ),
      ),
    );
  }
}
