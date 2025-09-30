import 'dart:io';

import 'package:example/controllers/auth_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import '../utils/app_fonts.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A), Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                // Top spacing
                SizedBox(height: 40.h),

                // Header Section
                Expanded(
                  flex: 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo/Icon
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF6366F1).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.flash_on_rounded,
                          color: Colors.white,
                          size: 36.sp,
                        ),
                      ),

                      SizedBox(height: 32.h),

                      // Welcome Text
                      Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: AppFonts.sf,
                          letterSpacing: -0.5,
                        ),
                      ),

                      SizedBox(height: 12.h),

                      // Subtitle
                      Text(
                        'Sign in to continue your journey',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF9CA3AF),
                          fontFamily: AppFonts.sf,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Content Section
                Expanded(
                  flex: 3,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Google Sign-in Button
                      Obx(() {
                        return Container(
                          width: double.infinity,
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: authController.isLoading.value
                                  ? null
                                  : () async {
                                      if (!kIsWeb &&
                                          (Platform.isAndroid ||
                                              Platform.isIOS)) {
                                        await authController.signInWithGoogle();
                                      }
                                      authController.fakeSignIn(context);
                                    },
                              borderRadius: BorderRadius.circular(16.r),
                              child: Center(
                                child: authController.isLoading.value
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: const CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Color(0xFF6366F1),
                                              ),
                                        ),
                                      )
                                    : Text(
                                        'Continue with Google',
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1F2937),
                                          fontFamily: AppFonts.sf,
                                          letterSpacing: 0.1,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        );
                      }),

                      SizedBox(height: 32.h),

                      // Alternative Sign-in Button (Optional - you can remove this)
                      Container(
                        width: double.infinity,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFF374151),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              context.go('/layout');
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Center(
                              child: Text(
                                'Explore as Guest',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9CA3AF),
                                  fontFamily: AppFonts.sf,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        height: 56.h,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: const Color(0xFF374151),
                            width: 1.5,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              context.go('/audio-test');
                            },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Center(
                              child: Text(
                                'Explore as Testing Zone',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF9CA3AF),
                                  fontFamily: AppFonts.sf,
                                  letterSpacing: 0.1,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom Section
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Terms and Privacy Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              'By continuing, you agree to our ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF6B7280),
                                fontFamily: AppFonts.sf,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 4.h),

                      // Links Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Handle Terms of Service
                            },
                            child: Text(
                              'Terms of Service',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6366F1),
                                fontFamily: AppFonts.sf,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF6366F1),
                              ),
                            ),
                          ),

                          Text(
                            ' and ',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: const Color(0xFF6B7280),
                              fontFamily: AppFonts.sf,
                            ),
                          ),

                          GestureDetector(
                            onTap: () {
                              // Handle Privacy Policy
                            },
                            child: Text(
                              'Privacy Policy',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF6366F1),
                                fontFamily: AppFonts.sf,
                                decoration: TextDecoration.underline,
                                decorationColor: const Color(0xFF6366F1),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 32.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleGoogleSignIn() {
    // Implement your Google sign-in logic here
    print('Google Sign-in tapped');

    // Example implementation:
    // try {
    //   await GoogleSignIn().signIn();
    //   // Navigate to home screen
    // } catch (error) {
    //   // Handle error
    // }
  }
}
