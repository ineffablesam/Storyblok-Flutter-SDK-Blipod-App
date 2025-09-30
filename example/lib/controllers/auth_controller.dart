import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var user = Rxn<User>();

  /// Google Client IDs
  static const webClientId =
      '384183779621-1j7l1lhei0u3vsjf2irgh3prud945g5f.apps.googleusercontent.com';
  static const iosClientId =
      '384183779621-hasnghd0v1ghcbqikl3f5oln7c20jeat.apps.googleusercontent.com';
  final scopes = ['email', 'profile'];

  Future<void> fakeSignIn(BuildContext context) async {
    try {
      isLoading.value = true;

      // Create a dummy user object
      final fakeUser = User(
        id: "ce275d54-579e-463f-95a7-5cec946cc791",
        appMetadata: {"provider": "mock"},
        userMetadata: {"name": "Mock User"},
        aud: "authenticated",
        createdAt: DateTime.now().toIso8601String(),
        role: "authenticated",
        isAnonymous: false,
      );

      // Create dummy session
      final fakeSession = Session(
        accessToken: "fake_access_token_123",
        refreshToken: "fake_refresh_token_456",
        tokenType: "bearer",
        user: fakeUser,
      );

      // Save tokens like a real login
      await saveUserSession(fakeSession);

      // Set the user in your controller
      user.value = fakeUser;

      debugPrint("✅ Fake sign-in successful as ${fakeUser.id}");
      // go to /home
      context.go('/layout');
    } catch (e, st) {
      debugPrint("❌ Fake sign-in failed: $e\n$st");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      isLoading.value = true;
      final googleSignIn = GoogleSignIn.instance;

      await googleSignIn.initialize(
        serverClientId: webClientId,
        clientId: iosClientId,
      );

      // Try lightweight authentication first, fallback to full authentication
      GoogleSignInAccount? googleUser = await googleSignIn
          .attemptLightweightAuthentication();

      // If lightweight auth fails, try full authentication
      googleUser ??= await googleSignIn.authenticate();

      if (googleUser == null) {
        throw AuthException('Google sign-in was cancelled by user.');
      }

      /// Authorization is required to obtain the access token with the appropriate scopes for Supabase authentication,
      /// while also granting permission to access user information.
      final authorization =
          await googleUser.authorizationClient.authorizationForScopes(scopes) ??
          await googleUser.authorizationClient.authorizeScopes(scopes);

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw AuthException('No ID Token found.');
      }

      // Sign into Supabase with Google ID token
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: authorization.accessToken,
      );

      if (response.session != null) {
        await saveUserSession(response.session!);
        user.value = response.session!.user;
      }
    } catch (e) {
      Get.snackbar(
        "Login Failed",
        e.toString().isNotEmpty ? e.toString() : 'An unknown error occurred.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveUserSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("access_token", session.accessToken);
    await prefs.setString("refresh_token", session.refreshToken ?? "");
  }

  Future<void> loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString("access_token");
      final refreshToken = prefs.getString("refresh_token");

      if (accessToken != null && refreshToken != null) {
        debugPrint("Restoring session from saved tokens...");
        // Use both access and refresh tokens to restore session
        final AuthResponse response = await supabase.auth.setSession(
          refreshToken,
        );
        if (response.session != null) {
          user.value = response.session!.user;
          debugPrint("Session restored successfully.");
        }
      }
    } catch (e) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("refresh_token");
    }
  }

  Future<void> signOut() async {
    try {
      final googleSignIn = GoogleSignIn.instance;

      // Sign out from Google
      await googleSignIn.signOut();

      // Sign out from Supabase
      await supabase.auth.signOut();

      // Clear stored session
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove("access_token");
      await prefs.remove("refresh_token");

      user.value = null;
    } catch (e) {
      Get.snackbar(
        "Sign Out Error",
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadSavedUser();
  }
}
