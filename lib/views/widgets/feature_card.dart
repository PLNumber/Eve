/* lib/views/widgets/feature_card.dart */

import 'package:flutter/material.dart';

// 메인화면 카드
class FeatureCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap;

  const FeatureCard({
    Key? key,
    required this.imagePath,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var imageWidth = screenSize.width * 0.25; // 화면 너비의 25%를 이미지 너비로 사용
    var imageHeight = imageWidth; // 너비와 높이를 같게 설정

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: imageWidth, height: imageHeight),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black, // 다크 모드에 따라 색상 변경
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
