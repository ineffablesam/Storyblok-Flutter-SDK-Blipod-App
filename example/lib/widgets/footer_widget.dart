import 'package:example/utils/app_assets.dart';
import 'package:flutter/material.dart';

class FooterWidget extends StatelessWidget {
  const FooterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.footer,
      fit: BoxFit.cover,
      width: double.infinity,
      repeat: ImageRepeat.repeatX,
    );
  }
}
