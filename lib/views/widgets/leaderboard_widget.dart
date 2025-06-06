import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardSection extends StatelessWidget {
  const LeaderboardSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── “리더보드” 제목 ───────────────────────────────────────────
        Text(
          "리더보드",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.015),

        // ─── 1) 경험치 순위 ───────────────────────────────────────────
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🏆 경험치 순위 (상위 5명)",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('experience', descending: true)
                      .limit(5)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("데이터가 없습니다.");
                    }
                    final docs = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(docs.length, (index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final nick = data['nickname'] ?? "닉네임 없음";
                        final exp = data['experience'] ?? 0;
                        return Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                          child: Text(
                            "${index + 1}. $nick — ${exp} EXP",
                            style: TextStyle(fontSize: screenWidth * 0.037),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // ─── 2) 정확도 순위 ───────────────────────────────────────────
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🎯 정확도 순위 (상위 5명)",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("데이터가 없습니다.");
                    }

                    // 1) 전체 문서를 가져와서 정확도(accuracy)를 계산 후 정렬
                    final allDocs = snapshot.data!.docs;
                    final List<Map<String, dynamic>> userList = [];

                    for (var doc in allDocs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final nick = data['nickname'] ?? "닉네임 없음";
                      final correct = (data['correctSolved'] as int?) ?? 0;
                      final total = (data['totalSolved'] as int?) ?? 0;
                      final acc = total > 0 ? correct / total : 0.0;
                      userList.add({
                        'nickname': nick,
                        'accuracy': acc,
                        'correct': correct,
                        'total': total,
                      });
                    }

                    // 내림차순 정렬 (정확도 높은 순)
                    userList.sort((a, b) =>
                        (b['accuracy'] as double).compareTo(a['accuracy'] as double));

                    // 상위 5명만 잘라내기
                    final top5 = userList.length >= 5
                        ? userList.sublist(0, 5)
                        : userList;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(top5.length, (i) {
                        final u = top5[i];
                        final pct = (u['accuracy'] as double) * 100;
                        final nick = u['nickname'] as String;
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.005),
                          child: Text(
                            "${i + 1}. $nick — 정확도: ${pct.toStringAsFixed(1)}%",
                            style: TextStyle(fontSize: screenWidth * 0.037),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.02),

        // ─── 3) 맞춘 횟수 순위 ─────────────────────────────────────────
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🔥 맞춘 횟수 순위 (상위 5명)",
                  style: TextStyle(
                    fontSize: screenWidth * 0.045,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('users')
                      .orderBy('correctSolved', descending: true)
                      .limit(5)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Text("데이터가 없습니다.");
                    }
                    final docs = snapshot.data!.docs;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(docs.length, (index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        final nick = data['nickname'] ?? "닉네임 없음";
                        final correct = (data['correctSolved'] as int?) ?? 0;
                        return Padding(
                          padding:
                          EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                          child: Text(
                            "${index + 1}. $nick — 정답: $correct 회",
                            style: TextStyle(fontSize: screenWidth * 0.037),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: screenHeight * 0.03),
      ],
    );
  }
}
