//버전1

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class LeaderboardSection extends StatelessWidget {
//   const LeaderboardSection({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       children: [
//         // ─── “리더보드” 제목 ───────────────────────────────────────────
//         Text(
//           "랭킹",
//           style: TextStyle(
//             fontSize: screenWidth * 0.05,
//             fontWeight: FontWeight.bold,
//           ),
//           textAlign: TextAlign.center,
//         ),
//         SizedBox(height: screenHeight * 0.015),
//
//         // ─── 1) 경험치 순위 ───────────────────────────────────────────
//         Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🏆 경험치 순위 (상위 5명)",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.045,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 FutureBuilder<QuerySnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .orderBy('experience', descending: true)
//                       .limit(5)
//                       .get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Text("데이터가 없습니다.");
//                     }
//                     final docs = snapshot.data!.docs;
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List.generate(docs.length, (index) {
//                         final data = docs[index].data() as Map<String, dynamic>;
//                         final nick = data['nickname'] ?? "닉네임 없음";
//                         final exp = data['experience'] ?? 0;
//                         return Padding(
//                           padding:
//                           EdgeInsets.symmetric(vertical: screenHeight * 0.005),
//                           child: Text(
//                             "${index + 1}. $nick — ${exp} EXP",
//                             style: TextStyle(fontSize: screenWidth * 0.037),
//                           ),
//                         );
//                       }),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         SizedBox(height: screenHeight * 0.02),
//
//         // ─── 2) 정확도 순위 ───────────────────────────────────────────
//         Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🎯 정확도 순위 (상위 5명)",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.045,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 FutureBuilder<QuerySnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Text("데이터가 없습니다.");
//                     }
//
//                     // 1) 전체 문서를 가져와서 정확도(accuracy)를 계산 후 정렬
//                     final allDocs = snapshot.data!.docs;
//                     final List<Map<String, dynamic>> userList = [];
//
//                     for (var doc in allDocs) {
//                       final data = doc.data() as Map<String, dynamic>;
//                       final nick = data['nickname'] ?? "닉네임 없음";
//                       final correct = (data['correctSolved'] as int?) ?? 0;
//                       final total = (data['totalSolved'] as int?) ?? 0;
//                       final acc = total > 0 ? correct / total : 0.0;
//                       userList.add({
//                         'nickname': nick,
//                         'accuracy': acc,
//                         'correct': correct,
//                         'total': total,
//                       });
//                     }
//
//                     // 내림차순 정렬 (정확도 높은 순)
//                     userList.sort((a, b) =>
//                         (b['accuracy'] as double).compareTo(a['accuracy'] as double));
//
//                     // 상위 5명만 잘라내기
//                     final top5 = userList.length >= 5
//                         ? userList.sublist(0, 5)
//                         : userList;
//
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List.generate(top5.length, (i) {
//                         final u = top5[i];
//                         final pct = (u['accuracy'] as double) * 100;
//                         final nick = u['nickname'] as String;
//                         return Padding(
//                           padding: EdgeInsets.symmetric(
//                               vertical: screenHeight * 0.005),
//                           child: Text(
//                             "${i + 1}. $nick — 정확도: ${pct.toStringAsFixed(1)}%",
//                             style: TextStyle(fontSize: screenWidth * 0.037),
//                           ),
//                         );
//                       }),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         SizedBox(height: screenHeight * 0.02),
//
//         // ─── 3) 맞춘 횟수 순위 ─────────────────────────────────────────
//         Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: EdgeInsets.all(screenWidth * 0.04),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "🔥 맞춘 횟수 순위 (상위 5명)",
//                   style: TextStyle(
//                     fontSize: screenWidth * 0.045,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: screenHeight * 0.01),
//                 FutureBuilder<QuerySnapshot>(
//                   future: FirebaseFirestore.instance
//                       .collection('users')
//                       .orderBy('correctSolved', descending: true)
//                       .limit(5)
//                       .get(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return Center(child: CircularProgressIndicator());
//                     }
//                     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                       return Text("데이터가 없습니다.");
//                     }
//                     final docs = snapshot.data!.docs;
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: List.generate(docs.length, (index) {
//                         final data = docs[index].data() as Map<String, dynamic>;
//                         final nick = data['nickname'] ?? "닉네임 없음";
//                         final correct = (data['correctSolved'] as int?) ?? 0;
//                         return Padding(
//                           padding:
//                           EdgeInsets.symmetric(vertical: screenHeight * 0.005),
//                           child: Text(
//                             "${index + 1}. $nick — 정답: $correct 회",
//                             style: TextStyle(fontSize: screenWidth * 0.037),
//                           ),
//                         );
//                       }),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//
//         SizedBox(height: screenHeight * 0.03),
//       ],
//     );
//   }
// }


//버전2
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:eve/l10n/gen_l10n/app_localizations.dart';

/// 경험치 순으로 정렬된 상위 유저 리스트를 “순위 · 아이디 · 맞은 문제 · 제출(전체) · 정답 비율” 형태로
/// 화면에 보여주는 위젯입니다.
class LeaderboardSection extends StatelessWidget {
  /// 상위 몇 명까지 보여줄지 지정 (기본값: 5명)
  final int limitCount;

  const LeaderboardSection({Key? key, this.limitCount = 5}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 컬럼 폭 비율: 아이디 · 맞은문제 · 제출 · 정확도
    // 화면이 좁을 때 글씨가 잘리는 걸 막기 위해, 가중치(flex)를 적절히 분배했습니다.
    const idFlex = 3;
    const solvedFlex = 2;
    const totalFlex = 2;
    const accFlex = 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ─── “리더보드” 제목 ───────────────────────────────────────────
        Text(
          "랭킹",
          style: TextStyle(
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: screenHeight * 0.015),

        // ─── 헤더 행 (순위 · 아이디 · 맞은문제 · 제출 · 정답비율) ────────────
        Container(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
          decoration: BoxDecoration(
            color: Theme.of(context).dividerColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  "순위",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ),
              Expanded(
                flex: idFlex,
                child: Text(
                  "아이디",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ),
              Expanded(
                flex: solvedFlex,
                child: Text(
                  "맞은문제",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ),
              Expanded(
                flex: totalFlex,
                child: Text(
                  "제출",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ),
              Expanded(
                flex: accFlex,
                child: Text(
                  "정답비율",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.038,
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.008),

        // ─── 실제 데이터 행 (FutureBuilder: Firestore에서 상위 limitCount명 가져오기) ──────────────────
        FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .orderBy('experience', descending: true)
              .limit(limitCount)
              .get(),
          builder: (context, snapshot) {
            // 로딩 중 표시
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            // 에러 혹은 데이터 없음 처리
            if (snapshot.hasError) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  "리더보드를 불러오는 중 오류가 발생했습니다.",
                  style: TextStyle(fontSize: screenWidth * 0.036),
                  textAlign: TextAlign.center,
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                child: Text(
                  "등록된 사용자가 없습니다.",
                  style: TextStyle(fontSize: screenWidth * 0.036),
                  textAlign: TextAlign.center,
                ),
              );
            }

            final docs = snapshot.data!.docs;

            return Column(
              children: List.generate(docs.length, (index) {
                final data = docs[index].data() as Map<String, dynamic>;

                // Firestore에 저장된 필드 추출
                final nick = (data['nickname'] as String?) ?? "익명";
                final correct = (data['correctSolved'] as int?) ?? 0;
                final total = (data['totalSolved'] as int?) ?? 0;
                // 정확도 계산 (total이 0이면 0)
                final accRatio = total > 0 ? correct / total * 100 : 0.0;
                final accText = "${accRatio.toStringAsFixed(1)}%";

                return Container(
                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.008),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).dividerColor, width: 0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      // 순위 (1, 2, 3, …)
                      Expanded(
                        flex: 1,
                        child: Text(
                          "${index + 1}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.037),
                        ),
                      ),
                      // 아이디(nickname)
                      Expanded(
                        flex: idFlex,
                        child: Text(
                          nick,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.037),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 맞은 문제(correctSolved)
                      Expanded(
                        flex: solvedFlex,
                        child: Text(
                          "$correct",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.037),
                        ),
                      ),
                      // 제출(totalSolved)
                      Expanded(
                        flex: totalFlex,
                        child: Text(
                          "$total",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.037),
                        ),
                      ),
                      // 정답 비율(정확도)
                      Expanded(
                        flex: accFlex,
                        child: Text(
                          accText,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.037),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            );
          },
        ),

        SizedBox(height: screenHeight * 0.02),
      ],
    );
  }
}