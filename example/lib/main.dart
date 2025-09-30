// lib/main.dart
import 'dart:ui';

import 'package:device_frame/device_frame.dart';
import 'package:example/pages/browse_page.dart';
import 'package:example/router.dart';
import 'package:example/utils/theme/app_theme.dart';
import 'package:example/widgets/categories_widget.dart';
import 'package:example/widgets/feature_widget.dart';
import 'package:example/widgets/recently_saved.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:storyblok_flutter/storyblok_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'controllers/auth_controller.dart';

final supabase = Supabase.instance.client;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: "https://sethozoyxgoarhziwzqv.supabase.co",
    anonKey:
        "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNldGhvem95eGdvYXJoeml3enF2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTg2OTM1NTMsImV4cCI6MjA3NDI2OTU1M30.pMyBNAATHfqInWlZ2eaMStMgeIf_JxTMKgN9HOs-lMg",
  );
  Get.put(AuthController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus &&
            currentFocus.focusedChild != null) {
          FocusManager.instance.primaryFocus?.unfocus();
        }
      },
      child: StoryblokApp(
        config: const StoryblokConfig(
          token: 'zKrvuq0FVrrU7Zv5zvjycgtt',
          version: StoryblokVersion.published,
          debug: true,
        ),
        components: _getStoryblokComponents(),
        onError: (error) {
          debugPrint('Storyblok Error: $error');
        },
        child: ScreenUtilInit(
          designSize: ScreenUtil.defaultSize,
          minTextAdapt: false,
          splitScreenMode: false,
          builder: (context, child) {
            return GetMaterialApp.router(
              scrollBehavior: MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                },
              ),
              title: 'AppTheme Example',
              routerDelegate: router.routerDelegate,
              routeInformationParser: router.routeInformationParser,
              routeInformationProvider: router.routeInformationProvider,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme.copyWith(
                splashFactory: InkSparkle.splashFactory,
              ),
              themeMode: ThemeMode.dark,
              debugShowCheckedModeBanner: false,
              builder: (context, child) {
                if (kIsWeb) {
                  return DeviceFrame(
                    device: Devices.ios.iPhone15ProMax,
                    isFrameVisible: true,
                    screen: child ?? const SizedBox(),
                  );
                }
                return child!;
              },
            );
          },
        ),
      ),
    );
  }
}

// Component Registry - register once globally
Map<String, StoryblokComponentBuilder> _getStoryblokComponents() {
  return {
    'feature': (context, blok, props) =>
        FeatureWidget(blok: blok, props: props),
    'grid': (context, blok, props) =>
        CategoryListWidget(blok: blok, props: props),
    'recently_saved': (context, blok, props) =>
        RecentlySavedWidget(blok: blok, props: props),
    'all_categories': (context, blok, props) =>
        CategoriesWidget(blok: blok, props: props),
  };
}
