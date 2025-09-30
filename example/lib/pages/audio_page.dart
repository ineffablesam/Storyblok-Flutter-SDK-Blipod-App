import 'package:example/utils/app_assets.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:example/utils/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_popup/flutter_popup.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:soft_edge_blur/soft_edge_blur.dart';

import '../controllers/podcast_controller.dart';
import '../pages/podcast_generation_page.dart';
import '../utils/app_colors.dart';

class AudioPage extends StatelessWidget {
  const AudioPage({super.key});

  @override
  Widget build(BuildContext context) {
    final PodcastController podcastController = Get.find<PodcastController>();
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            expandedHeight: 300.0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              stretchModes: [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
                StretchMode.fadeTitle,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  SoftEdgeBlur(
                    edges: [
                      EdgeBlur(
                        type: EdgeType.topEdge,
                        size: 70,
                        sigma: 30,
                        controlPoints: [
                          ControlPoint(
                            position: 0.5,
                            type: ControlPointType.visible,
                          ),
                          ControlPoint(
                            position: 1,
                            type: ControlPointType.transparent,
                          ),
                        ],
                      ),
                      EdgeBlur(
                        type: EdgeType.bottomEdge,
                        size: 290,
                        sigma: 10,
                        tintColor: Colors.black,
                        controlPoints: [
                          ControlPoint(
                            position: 0.3,
                            type: ControlPointType.visible,
                          ),
                          ControlPoint(
                            position: 1,
                            type: ControlPointType.transparent,
                          ),
                        ],
                      ),
                    ],
                    child: Image.asset(
                      AppAssets.audioBanner,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Audio',
                              style: TextStyle(
                                fontSize: 45.sp,
                                fontFamily: AppFonts.sf,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: Colors.white,
                              ),
                            ),
                            Spacer(),
                            Obx(() {
                              final completedCount = podcastController
                                  .articleGenerations
                                  .where((a) => a.isCompleted)
                                  .length;
                              return completedCount > 0
                                  ? CustomTap(
                                      onTap: () {
                                        final firstCompleted = podcastController
                                            .articleGenerations
                                            .firstWhere((a) => a.isCompleted);
                                        podcastController.startPlaying(
                                          firstCompleted,
                                        );
                                      },
                                      child: CircleAvatar(
                                        radius: 26.r,
                                        backgroundColor: AppColors.primary,
                                        child: Icon(
                                          Icons.play_arrow_rounded,
                                          color: AppColors.blackShade,
                                          size: 24.sp,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink();
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [_BuildAudioList(), 400.verticalSpace],
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildAudioList extends StatelessWidget {
  const _BuildAudioList({super.key});

  @override
  Widget build(BuildContext context) {
    final PodcastController podcastController = Get.find<PodcastController>();

    return Obx(() {
      if (podcastController.isLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.h),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      if (podcastController.articleGenerations.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 50.h, horizontal: 24.w),
            child: Column(
              children: [
                Icon(
                  LucideIcons.audioLines,
                  size: 64.sp,
                  color: Colors.grey.shade600,
                ),
                16.verticalSpace,
                Text(
                  'No audio articles yet',
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontFamily: AppFonts.sf,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                8.verticalSpace,
                Text(
                  'Generate your first article to see it here',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontFamily: AppFonts.sf,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                24.verticalSpace,
                // refresh button
                CustomTap(
                  onTap: () => podcastController.refreshArticles(),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Text(
                        'Refresh',
                        style: TextStyle(
                          color: AppColors.blackShade,
                          fontFamily: AppFonts.sf,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.blackShade.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.blackBorder.withOpacity(0.3),
              width: 1,
            ),
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
                itemCount: podcastController.articleGenerations.length,
                separatorBuilder: (context, index) => 4.verticalSpace,
                itemBuilder: (context, index) {
                  final article = podcastController.articleGenerations[index];
                  return _BuildAudioCard(article: article);
                },
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _BuildAudioCard extends StatelessWidget {
  final article;

  const _BuildAudioCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final PodcastController podcastController = Get.find<PodcastController>();
    final GlobalKey anchorKey = GlobalKey();
    final popupKey = GlobalKey<CustomPopupState>();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      child: CustomTap(
        onTap: () {
          if (article.isCompleted) {
            podcastController.startPlaying(article);
          } else if (article.isGenerating) {
            context.push(PodcastGenerationPage.routeName, extra: article);
          } else if (article.isFailed) {
            context.push(PodcastGenerationPage.routeName, extra: article);
          }
        },
        child: Row(
          children: [
            Row(
              spacing: 10,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    color: article.isCompleted
                        ? AppColors.primary.withOpacity(0.2)
                        : article.isFailed
                        ? Colors.red.withOpacity(0.2)
                        : Colors.orange.withOpacity(0.2),
                    child: Icon(
                      article.isCompleted
                          ? LucideIcons.circleCheck
                          : article.isFailed
                          ? LucideIcons.x
                          : LucideIcons.loader,
                      color: article.isCompleted
                          ? AppColors.primary
                          : article.isFailed
                          ? Colors.red
                          : Colors.orange,
                      size: 24.sp,
                    ),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.55,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.articleTitle ?? 'Untitled Article',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: AppFonts.sf,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        article.isCompleted
                            ? 'Ready to play'
                            : article.isFailed
                            ? 'Generation failed'
                            : article.detailedStatus,
                        style: TextStyle(
                          color: article.isCompleted
                              ? Colors.green.shade300
                              : article.isFailed
                              ? Colors.red.shade300
                              : Colors.orange.shade300,
                          fontFamily: AppFonts.sf,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (article.isGenerating)
                        Row(
                          children: [
                            Text(
                              '${article.progressPercentage}%',
                              style: TextStyle(
                                color: Colors.grey.shade400,
                                fontFamily: AppFonts.sf,
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            4.horizontalSpace,
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2.r),
                                child: LinearProgressIndicator(
                                  value: article.progressPercentage / 100,
                                  backgroundColor: Colors.grey.shade800,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange,
                                  ),
                                  minHeight: 3.h,
                                ),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          _formatDate(article.createdAt),
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontFamily: AppFonts.sf,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            CustomPopup(
              anchorKey: anchorKey,
              key: popupKey,
              content: Container(
                decoration: BoxDecoration(
                  color: AppColors.blackShade,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.blackBorder.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem(
                      icon: LucideIcons.share2,
                      label: 'Share',
                      onTap: () {
                        // popupKey.currentState?.close();
                      },
                    ),
                    Divider(
                      height: 1,
                      color: AppColors.blackBorder.withOpacity(0.2),
                    ),
                    _buildMenuItem(
                      icon: LucideIcons.download,
                      label: 'Download',
                      onTap: () {
                        // popupKey.currentState?.close();
                      },
                    ),
                    if (article.isFailed) ...[
                      Divider(
                        height: 1,
                        color: AppColors.blackBorder.withOpacity(0.2),
                      ),
                      _buildMenuItem(
                        icon: LucideIcons.refreshCw,
                        label: 'Retry',
                        onTap: () {
                          // popupKey.currentState?.context();
                        },
                      ),
                    ],
                    Divider(
                      height: 1,
                      color: AppColors.blackBorder.withOpacity(0.2),
                    ),
                    _buildMenuItem(
                      icon: LucideIcons.trash2,
                      label: 'Delete',
                      onTap: () {
                        // popupKey.currentState?.close();
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(14.w),
                child: Icon(
                  LucideIcons.ellipsisVertical,
                  color: Colors.grey.shade300,
                  size: 16.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return CustomTap(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16.sp,
              color: isDestructive ? Colors.red : Colors.grey.shade300,
            ),
            12.horizontalSpace,
            Text(
              label,
              style: TextStyle(
                color: isDestructive ? Colors.red : Colors.grey.shade300,
                fontFamily: AppFonts.sf,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }
}
