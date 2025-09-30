import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/layout_controller.dart';
import '../controllers/podcast_controller.dart';
import '../utils/app_colors.dart';
import '../utils/app_fonts.dart';

class ArticleWebViewPage extends StatefulWidget {
  final String url;
  final String title;
  static const String routeName = '/articleWebView';

  const ArticleWebViewPage({super.key, required this.url, required this.title});

  @override
  State<ArticleWebViewPage> createState() => _ArticleWebViewPageState();
}

class _ArticleWebViewPageState extends State<ArticleWebViewPage> {
  late final WebViewController _controller;
  final PodcastController _podcastController = Get.find<PodcastController>();
  final LayoutController _layoutController = Get.find<LayoutController>();

  var isLoading = true.obs;
  var isProcessing = false.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            isLoading.value = true;
          },
          onPageFinished: (String url) {
            isLoading.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _handleBlipIt() async {
    if (isProcessing.value) return;

    try {
      isProcessing.value = true;

      // Navigate first
      _layoutController.pushToAudioPage(context);

      // Now send request to process article
      await _podcastController.processArticle(widget.url);
    } catch (e) {
      debugPrint('Error processing article: $e');
      Get.snackbar(
        'Error',
        'Failed to create blip: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red.withOpacity(0.9),
        colorText: Colors.white,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        backgroundColor: AppColors.scaffoldBackground,
        surfaceTintColor: AppColors.scaffoldBackground,
        leading: IconButton(
          icon: Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () {
            context.pop();
          },
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            color: Colors.white,
            fontFamily: AppFonts.sf,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: Icon(LucideIcons.rotateCw, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          Obx(
            () => isLoading.value
                ? LinearProgressIndicator(
                    value: 1.0,
                    color: AppColors.primary,
                    backgroundColor: Colors.transparent,
                    minHeight: 2.h,
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
      floatingActionButton: Obx(
        () => FloatingActionButton.extended(
          onPressed: isProcessing.value ? null : _handleBlipIt,
          backgroundColor: isProcessing.value ? Colors.grey : AppColors.primary,
          elevation: 8,
          icon: isProcessing.value
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text('🪄', style: TextStyle(fontSize: 20.sp)),
          label: Text(
            isProcessing.value ? 'Processing...' : 'Blip It',
            style: TextStyle(
              color: Colors.white,
              fontFamily: AppFonts.sf,
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
