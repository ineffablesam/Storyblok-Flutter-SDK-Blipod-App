import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:example/models/category_model.dart';
import 'package:example/utils/app_assets.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:example/utils/custom_tap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';

import '../utils/app_colors.dart';
import 'article_webview_page.dart';

class BrowsePage extends StatelessWidget {
  const BrowsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            stretch: true,
            collapsedHeight: 120.h,
            surfaceTintColor: AppColors.scaffoldBackground,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: SafeArea(
                top: true,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 18.w,
                    vertical: 2.h,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Browse',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          fontFamily: AppFonts.sf,
                        ),
                      ),
                      Text(
                        'Browse content across categories',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade400,
                          fontFamily: AppFonts.sf,
                        ),
                      ),
                      8.verticalSpace,
                      SizedBox(
                        height: 45.h,
                        child: TextField(
                          decoration: InputDecoration(
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14.r),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.blackBorder,
                              ),
                            ),
                            prefixIcon: Icon(
                              LucideIcons.search,
                              size: 20.sp,
                              color: Colors.grey.shade400,
                            ),
                            fillColor: AppColors.blackShade,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(14.r),
                              ),
                              borderSide: BorderSide(
                                color: AppColors.primary,
                                width: 1.5.w,
                              ),
                            ),
                            hintText: 'Search',
                            hintStyle: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey.shade400,
                              fontFamily: AppFonts.sf,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                10.verticalSpace,
                storyblokPage('browse'),
                400.verticalSpace,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoriesWidget extends StatelessWidget {
  final StoryblokBlok blok;
  final Map<String, dynamic> props;

  const CategoriesWidget({super.key, required this.blok, required this.props});

  static Widget builder(
    BuildContext context,
    StoryblokBlok blok,
    Map<String, dynamic> props,
  ) {
    return CategoriesWidget(blok: blok, props: props);
  }

  @override
  Widget build(BuildContext context) {
    final categories =
        categoryFromDynamic(props['categories']).categories ?? [];

    return StoryblokEditable(
      content: blok.toJson(),
      child: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12.h,
          crossAxisSpacing: 12.w,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return _BuildCategoryCard(category: categories[index]);
        },
      ),
    );
  }
}

class _BuildCategoryCard extends StatelessWidget {
  final CategoryElement category;

  const _BuildCategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final name = category.name ?? "Untitled";
    final thumb = category.thumbnail ?? "";
    final color = category.color?.color ?? "#000000";

    return CustomTap(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SubCategoriesPage(category: category),
          ),
        );
      },
      child: SizedBox(
        width: 200,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.r),
          child: Stack(
            alignment: Alignment.bottomCenter,
            fit: StackFit.expand,
            children: [
              thumb.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: "https:$thumb",
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) =>
                          Image.asset(AppAssets.logo, fit: BoxFit.cover),
                      placeholder: (context, url) => Image.asset(
                        AppAssets.thumbnailSmall,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Image.asset(AppAssets.logo, fit: BoxFit.cover),
              _CategoryInfoOverlay(name: name, clr: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryInfoOverlay extends StatelessWidget {
  final String name;
  final String clr;
  const _CategoryInfoOverlay({required this.name, required this.clr});

  @override
  Widget build(BuildContext context) {
    Color color = Color(int.parse(clr.substring(1), radix: 16) + 0xFF000000);
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(color: color, height: 2.h),
        Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(color: Colors.black.withOpacity(0.4)),
                ),
              ),
            ),
            Container(
              height: 58.h,
              width: double.infinity,
              padding: EdgeInsets.all(8.w),
              color: Colors.black.withOpacity(0.6),
              child: Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// SubCategories + Articles Page
class SubCategoriesPage extends StatelessWidget {
  final CategoryElement category;

  const SubCategoriesPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final subCategories = category.subCategory ?? [];
    final articles =
        category.article ?? []; // assuming `articles` list exists in model

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            pinned: true,
            surfaceTintColor: AppColors.scaffoldBackground,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                category.name ?? "Untitled",
                style: TextStyle(color: Colors.white, fontFamily: AppFonts.sf),
              ),
            ),
          ),

          /// Subcategories Grid
          if (subCategories.isNotEmpty)
            SliverToBoxAdapter(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                ),
                itemCount: subCategories.length,
                itemBuilder: (context, index) {
                  return _BuildCategoryCard(category: subCategories[index]);
                },
              ),
            ),

          /// Articles List
          if (articles.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final article = articles[index];
                return _BuildArticleCard(article: article);
              }, childCount: articles.length),
            ),
        ],
      ),
    );
  }
}

/// Article Card
class _BuildArticleCard extends StatelessWidget {
  final Article article;

  const _BuildArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final thumb = article.thumbnail ?? "";
    final articleUrl = article.link?.url ?? "";

    return ListTile(
      leading: thumb.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: "https:$thumb",
                width: 50.w,
                height: 50.h,
                fit: BoxFit.cover,
              ),
            )
          : Image.asset(AppAssets.thumbnailSmall, width: 50.w, height: 50.h),
      title: Text(
        article.name ?? "Untitled",
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: AppFonts.sf,
          color: Colors.white,
        ),
      ),
      subtitle: Text(
        article.subtitle ?? "",
        style: TextStyle(color: Colors.grey.shade400, fontSize: 12.sp),
      ),
      onTap: () {
        if (articleUrl.isEmpty) {
          const snackBar = SnackBar(
            content: Text('Article URL is not available.'),
            duration: Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
          return;
        }

        context.push(
          ArticleWebViewPage.routeName,
          extra: {'url': articleUrl, 'title': article.name ?? "Article"},
        );
      },
    );
  }
}
