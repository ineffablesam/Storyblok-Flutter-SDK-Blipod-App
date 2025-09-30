// lib/widgets/category_list_widget.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

import '../controllers/layout_controller.dart';
import '../utils/app_colors.dart';
import '../utils/custom_tap.dart';

class CategoryListWidget extends StatelessWidget {
  final StoryblokBlok blok;
  final Map<String, dynamic> props;

  const CategoryListWidget({
    super.key,
    required this.blok,
    required this.props,
  });

  static Widget builder(
    BuildContext context,
    StoryblokBlok blok,
    Map<String, dynamic> props,
  ) {
    return CategoryListWidget(blok: blok, props: props);
  }

  @override
  Widget build(BuildContext context) {
    final title = props['title'] as String? ?? 'For You';
    final categories = List<Map<String, dynamic>>.from(
      props['categories'] ?? [],
    );

    return SimpleStoryblokEditable(
      content: blok.toJson(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
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
                    Get.find<LayoutController>().goToPage(2);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Browse All',
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
          8.verticalSpace,
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final catTitle = cat['title'] as String? ?? '';
                final catSubtitle = cat['subtitle'] as String? ?? '';
                final catImage = cat['image'] as String? ?? '';
                final route = cat['route'] as String? ?? '';

                return SizedBox(
                  width: 200,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14.r),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        catImage.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: "https:$catImage",
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, size: 40),
                              ),
                        Container(
                          height: 58.h,
                          width: double.infinity,
                          decoration: BoxDecoration(color: Colors.black54),
                          child: Padding(
                            padding: EdgeInsets.all(8.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  catTitle,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  catSubtitle,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
