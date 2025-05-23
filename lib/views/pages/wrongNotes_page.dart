import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WrongNotePage extends StatelessWidget {
  const WrongNotePage({super.key});

  //틀린 단어 리스트 표시
  Future<List<String>> _loadIncorrectWords() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!doc.exists || doc.data() == null) return [];

    final data = doc.data();
    final List<dynamic>? words = data?['incorrectWords'];
    return words?.cast<String>() ?? [];
  }

  // 단어 뜻 표시
  Future<Map<String, dynamic>?> fetchWordDetail(String word) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vocab')
        .where('어휘', isEqualTo: word)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return snapshot.docs.first.data();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('오답노트')),
      body: FutureBuilder<List<String>>(
        future: _loadIncorrectWords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final words = snapshot.data ?? [];
          if (words.isEmpty) {
            return const Center(child: Text('저장된 오답이 없습니다.'));
          }

          return ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                title: Text(word),
                  onTap: () async {
                    final wordData = await fetchWordDetail(word);
                    if (wordData == null) {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(word),
                          content: Text("단어 정보가 없습니다."),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기')),
                          ],
                        ),
                      );
                      return;
                    }

                    final meanings = (wordData['의미'] as List?)?.cast<String>() ?? [];
                    final pos = (wordData['품사'] as List?)?.cast<String>() ?? [];
                    final grade = wordData['등급'] ?? '';

                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text('$word (${pos.isNotEmpty ? pos.first : '품사 없음'})'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (grade.isNotEmpty) Text('$grade'),
                            ...meanings.map((m) => Text('$m')).toList(),
                          ],
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text('닫기')),
                        ],
                      ),
                    );
                  }

              );
            },
          );
        },
      ),
    );
  }
}
