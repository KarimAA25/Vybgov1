import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/constant/constant.dart';
import 'package:flutter/material.dart';
import 'package:customer/theme/app_them_data.dart';
import 'package:google_fonts/google_fonts.dart';

class IntroScreenPage extends StatelessWidget {
  final String title;
  final String body;
  final String image;

  const IntroScreenPage({super.key, required this.title, required this.body, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CachedNetworkImage(
            height: 222,
            width: 343,
            imageUrl: image,
            placeholder: (context, url) => Constant.loader(),
          ),
          const SizedBox(height: 48),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 22, color: AppThemData.black, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, color: AppThemData.black, fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
