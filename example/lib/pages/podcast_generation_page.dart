import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../controllers/podcast_controller.dart';
import '../models/article_generation.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';
import '../utils/custom_tap.dart';

class PodcastGenerationPage extends StatefulWidget {
  final ArticleGeneration article;
  // route name for navigation
  static const String routeName = '/podcast-generation';

  const PodcastGenerationPage({super.key, required this.article});

  @override
  State<PodcastGenerationPage> createState() => _PodcastGenerationPageState();
}

class _PodcastGenerationPageState extends State<PodcastGenerationPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final PodcastController podcastController = Get.find<PodcastController>();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Obx(() {
          // Find the current article from the controller's list
          final currentArticle = podcastController.articleGenerations
              .firstWhereOrNull((a) => a.id == widget.article.id);

          if (currentArticle == null) {
            return Center(
              child: Text(
                'Article not found',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.sf,
                  fontSize: 16.sp,
                ),
              ),
            );
          }

          // If completed, show success and auto-navigate
          if (currentArticle.isCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              podcastController.startPlaying(currentArticle);
              Get.back();
            });
          }

          return Column(
            children: [
              _buildAppBar(context),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      children: [
                        40.verticalSpace,
                        _buildStatusIcon(currentArticle),
                        24.verticalSpace,
                        _buildTitle(currentArticle),
                        16.verticalSpace,
                        _buildProgressCard(currentArticle),
                        24.verticalSpace,
                        _buildStatusTimeline(currentArticle),
                        if (currentArticle.estimatedTimeRemaining != null) ...[
                          24.verticalSpace,
                          _buildEstimatedTime(currentArticle),
                        ],
                        if (currentArticle.isFailed) ...[
                          24.verticalSpace,
                          _buildErrorCard(currentArticle),
                        ],
                        40.verticalSpace,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          CustomTap(
            onTap: () {
              context.pop();
            },
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: AppColors.blackShade.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: AppColors.blackBorder.withOpacity(0.3),
                ),
              ),
              child: Icon(
                LucideIcons.arrowLeft,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ),
          16.horizontalSpace,
          Text(
            'Generation Status',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.sf,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(ArticleGeneration article) {
    return RotationTransition(
      turns: article.isGenerating
          ? _animationController
          : AlwaysStoppedAnimation(0),
      child: Container(
        width: 120.w,
        height: 120.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: article.isCompleted
                ? [AppColors.primary, AppColors.primary.withOpacity(0.6)]
                : article.isFailed
                ? [Colors.red, Colors.red.withOpacity(0.6)]
                : [Colors.orange, Colors.orange.withOpacity(0.6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color:
                  (article.isCompleted
                          ? AppColors.primary
                          : article.isFailed
                          ? Colors.red
                          : Colors.orange)
                      .withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Icon(
          article.isCompleted
              ? LucideIcons.circleCheck
              : article.isFailed
              ? LucideIcons.x
              : LucideIcons.loader,
          size: 60.sp,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitle(ArticleGeneration article) {
    return Column(
      children: [
        Text(
          article.articleTitle ?? 'Generating Article',
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.sf,
            fontSize: 24.sp,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        8.verticalSpace,
        Text(
          article.isCompleted
              ? 'Your podcast is ready!'
              : article.isFailed
              ? 'Generation failed'
              : 'Please wait while we generate your podcast',
          style: TextStyle(
            color: Colors.grey.shade400,
            fontFamily: AppFonts.sf,
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProgressCard(ArticleGeneration article) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.blackShade.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blackBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: AppFonts.sf,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${article.progressPercentage}%',
                style: TextStyle(
                  color: article.isCompleted
                      ? AppColors.primary
                      : article.isFailed
                      ? Colors.red
                      : Colors.orange,
                  fontFamily: AppFonts.sf,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          16.verticalSpace,
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: article.progressPercentage / 100,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                article.isCompleted
                    ? AppColors.primary
                    : article.isFailed
                    ? Colors.red
                    : Colors.orange,
              ),
              minHeight: 8.h,
            ),
          ),
          16.verticalSpace,
          Text(
            article.detailedStatus,
            style: TextStyle(
              color: Colors.grey.shade300,
              fontFamily: AppFonts.sf,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline(ArticleGeneration article) {
    final stages = [
      {'name': 'Initializing', 'icon': LucideIcons.sparkles},
      {'name': 'Generating Summary', 'icon': LucideIcons.fileText},
      {'name': 'Generating TTS', 'icon': LucideIcons.mic},
      {'name': 'Uploading to Storage', 'icon': LucideIcons.upload},
      {'name': 'Completed', 'icon': LucideIcons.circleCheck},
    ];

    int currentStageIndex = _getCurrentStageIndex(article.detailedStatus);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.blackShade.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.blackBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Generation Stages',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.sf,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          20.verticalSpace,
          ...List.generate(stages.length, (index) {
            final stage = stages[index];
            final isCompleted = index < currentStageIndex;
            final isCurrent =
                index == currentStageIndex && article.isGenerating;
            final isFailed = article.isFailed && index == currentStageIndex;

            return Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary.withOpacity(0.2)
                            : isCurrent
                            ? Colors.orange.withOpacity(0.2)
                            : isFailed
                            ? Colors.red.withOpacity(0.2)
                            : Colors.grey.shade800,
                        border: Border.all(
                          color: isCompleted
                              ? AppColors.primary
                              : isCurrent
                              ? Colors.orange
                              : isFailed
                              ? Colors.red
                              : Colors.grey.shade600,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        stage['icon'] as IconData,
                        color: isCompleted
                            ? AppColors.primary
                            : isCurrent
                            ? Colors.orange
                            : isFailed
                            ? Colors.red
                            : Colors.grey.shade600,
                        size: 18.sp,
                      ),
                    ),
                    12.horizontalSpace,
                    Expanded(
                      child: Text(
                        stage['name'] as String,
                        style: TextStyle(
                          color: isCompleted || isCurrent || isFailed
                              ? Colors.white
                              : Colors.grey.shade500,
                          fontFamily: AppFonts.sf,
                          fontSize: 13.sp,
                          fontWeight: isCurrent || isFailed
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        LucideIcons.check,
                        color: AppColors.primary,
                        size: 16.sp,
                      ),
                    if (isCurrent)
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.orange,
                          ),
                        ),
                      ),
                    if (isFailed)
                      Icon(LucideIcons.x, color: Colors.red, size: 16.sp),
                  ],
                ),
                if (index < stages.length - 1)
                  Padding(
                    padding: EdgeInsets.only(left: 19.w),
                    child: Container(
                      width: 2,
                      height: 30.h,
                      color: isCompleted
                          ? AppColors.primary.withOpacity(0.5)
                          : Colors.grey.shade800,
                    ),
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEstimatedTime(ArticleGeneration article) {
    final minutes = (article.estimatedTimeRemaining! / 60).ceil();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.clock, color: Colors.blue, size: 20.sp),
          12.horizontalSpace,
          Text(
            'Estimated time remaining: $minutes ${minutes == 1 ? 'minute' : 'minutes'}',
            style: TextStyle(
              color: Colors.blue,
              fontFamily: AppFonts.sf,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(ArticleGeneration article) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.circleAlert, color: Colors.red, size: 20.sp),
              12.horizontalSpace,
              Text(
                'Error Details',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: AppFonts.sf,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          12.verticalSpace,
          Text(
            article.errorMessage ?? 'An unknown error occurred',
            style: TextStyle(
              color: Colors.red.shade300,
              fontFamily: AppFonts.sf,
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (article.errorStage != null) ...[
            12.verticalSpace,
            Text(
              'Failed at: ${article.errorStage}',
              style: TextStyle(
                color: Colors.red.shade400,
                fontFamily: AppFonts.sf,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          20.verticalSpace,
          CustomTap(
            onTap: () {
              // Implement retry logic here
              Get.snackbar(
                'Retry',
                'Retry functionality coming soon',
                backgroundColor: Colors.orange.withOpacity(0.8),
                colorText: Colors.white,
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.refreshCw, color: Colors.white, size: 16.sp),
                  8.horizontalSpace,
                  Text(
                    'Retry Generation',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: AppFonts.sf,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getCurrentStageIndex(String detailedStatus) {
    if (detailedStatus.contains('Initializing') ||
        detailedStatus.contains('Starting')) {
      return 0;
    } else if (detailedStatus.contains('Summary')) {
      return 1;
    } else if (detailedStatus.contains('TTS') ||
        detailedStatus.contains('Stream')) {
      return 2;
    } else if (detailedStatus.contains('Upload') ||
        detailedStatus.contains('Storage')) {
      return 3;
    } else if (detailedStatus.contains('Completed')) {
      return 4;
    }
    return 0;
  }
}
