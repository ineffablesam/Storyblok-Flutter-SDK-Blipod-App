// lib/router.dart
import 'package:example/pages/article_webview_page.dart';
import 'package:example/pages/auth_page.dart';
import 'package:example/pages/dynamic_page.dart';
import 'package:example/pages/home_page.dart';
import 'package:example/pages/podcast_generation_page.dart';
import 'package:example/pages/splash_page.dart';
import 'package:go_router/go_router.dart';

import 'layout.dart';
import 'models/article_generation.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
  routes: [
    // / loads the MainLayout with HomePage as child
    GoRoute(path: '/splash', builder: (context, state) => SplashPage()),
    GoRoute(path: '/auth', builder: (context, state) => AuthPage()),
    GoRoute(path: '/', builder: (context, state) => MainLayout()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: PodcastGenerationPage.routeName,
      builder: (context, state) {
        final article = state.extra as ArticleGeneration;
        return PodcastGenerationPage(article: article);
      },
    ),
    GoRoute(
      path: ArticleWebViewPage.routeName,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>;
        return ArticleWebViewPage(
          url: extra['url'] as String,
          title: extra['title'] as String,
        );
      },
    ),

    ShellRoute(
      builder: (context, state, child) {
        return MainLayout();
      },
      routes: [
        // Dynamic Storyblok pages stay as routes
        GoRoute(
          path: '/:slug',
          name: 'dynamic-page',
          builder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return DynamicStoryblokPage(slug: slug);
          },
        ),
      ],
    ),
  ],
);
