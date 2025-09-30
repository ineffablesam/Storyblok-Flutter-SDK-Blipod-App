import 'package:example/controllers/auth_controller.dart';
import 'package:example/utils/app_assets.dart';
import 'package:example/utils/app_fonts.dart';
import 'package:example/widgets/footer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';
import 'package:web_smooth_scroll/web_smooth_scroll.dart';

import '../utils/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _scrollController;

  @override
  void initState() {
    // initialize scroll controllers
    _scrollController = ScrollController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: WebSmoothScroll(
        controller: _scrollController,
        child: _BuildHomeBody(),
      ),
    );
  }
}

class _BuildHomeBody extends StatelessWidget {
  const _BuildHomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          // title: const Text('Home'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          floating: true,
          snap: true,
          collapsedHeight: 80.h,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              padding: EdgeInsets.only(top: 30.h, left: 16.w, right: 16.w),
              child: Row(
                children: [
                  Row(
                    children: [
                      // CircleAvatar(radius: 20),
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.blackBorder,
                            width: 2.w,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(50.r),
                          child: Image.asset(
                            AppAssets.logo,
                            width: 40.w,
                            height: 40.w,
                          ),
                        ),
                      ),
                      12.horizontalSpace,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Welcome ${authController.user.value?.userMetadata?['name'] ?? 'User'}',
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontFamily: AppFonts.sf,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Explore Podcasts',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontFamily: AppFonts.sf,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.all(15.w),
                    decoration: BoxDecoration(
                      color: AppColors.blackShade,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.blackBorder),
                    ),
                    child: Icon(
                      LucideIcons.search,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            centerTitle: true,
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            children: [
              storyblokPage('home'),
              150.verticalSpace,
              FooterWidget(),
              // safe-bottom padding
              60.verticalSpace,
            ],
          ),
        ),
      ],
    );
  }
}
