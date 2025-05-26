import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:html_unescape/html_unescape.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({Key? key}) : super(key: key);

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  final TextEditingController _ctrl = TextEditingController();
  final HtmlUnescape _unescape = HtmlUnescape();
  List<dynamic> _exactMatches = [];
  List<dynamic> _partialMatches = [];
  bool _isLoading = false;
  String? _error;

  Future<void> _search(String query) async {
    final cleanQuery = _normalizeText(query);
    if (cleanQuery.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _exactMatches = [];
      _partialMatches = [];
    });

    try {
      final apiKey = dotenv.env['OURMALSAEM_API_KEY']!;
      final uri = Uri.parse(
        'https://opendict.korean.go.kr/api/search'
        '?key=$apiKey'
        '&q=${Uri.encodeComponent(cleanQuery)}'
        '&req_type=json'
        '&num=50'
        '&part=word',
      );

      final res = await http.get(uri);
      if (res.statusCode == 200) {
        final body = json.decode(res.body);
        final items = body['channel']['item'] as List<dynamic>? ?? [];

        _exactMatches =
            items.where((e) {
              final word = (e['word'] ?? '').replaceAll(RegExp(r'[\^\-]'), '');
              return word == cleanQuery;
            }).toList();

        _partialMatches =
            items.where((e) {
              final word = (e['word'] ?? '').replaceAll(RegExp(r'[\^\-]'), '');
              return word.contains(cleanQuery) && word != cleanQuery;
            }).toList();

        if (_exactMatches.isEmpty && _partialMatches.isEmpty) {
          _error = '검색 결과가 없습니다.';
        }
      } else {
        _error = 'API 오류: ${res.statusCode}';
      }
    } catch (e) {
      _error = '네트워크 오류: ${e.toString()}';
    }

    setState(() {
      _isLoading = false;
    });
  }

  String _normalizeText(String input) {
    return input
        .replaceAll(RegExp(r'[\^\n\r\t]'), '')
        .replaceAll(RegExp(r'\s+'), '')
        .trim();
  }

  String formatWordForDisplay(String word) {
    // return word.replaceAll('^', '·').replaceAll('-', '‧');
    return word.replaceAll('^', ' ').replaceAll('-', '');
  }

  Widget _buildEntryCard(Map<String, dynamic> item) {
    final word = formatWordForDisplay(item['word'] ?? '');
    final rawSense = item['sense'];
    final senses =
        (rawSense is List)
            ? rawSense.cast<Map<String, dynamic>>()
            : [rawSense as Map<String, dynamic>];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'NotoSansKR',
              ),
            ),
            const SizedBox(height: 8),
            ...senses.map((sense) {
              final rawDef = sense['definition'] ?? '';
              final def =
                  _unescape
                      .convert(rawDef)
                      .replaceAll(RegExp(r'<\/?FL>'), '') // <FL> 또는 </FL> 제거
                      .replaceAll('?', '')
                      .trim();

              final pos = sense['pos'];
              final cat = sense['cat'];

              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKR',
                      color: Colors.black87,
                    ),
                    children: [
                      if (cat != null && cat.toString().trim().isNotEmpty)
                        TextSpan(
                          text: '「$cat」 ',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      if (pos != null && pos.toString().trim().isNotEmpty)
                        TextSpan(
                          text: '[$pos] ',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      TextSpan(text: def),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('우리말샘 사전')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: '검색어를 입력하세요',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: _search,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _search(_ctrl.text),
                  child: const Text('검색'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red))
            else
              Expanded(
                child: ListView(
                  children: [
                    /// 정확한 결과
                    const Text(
                      '🔍 정확히 일치하는 단어',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_exactMatches.isEmpty)
                      const Text('일치하는 결과가 없습니다.')
                    else
                      ..._exactMatches.map((e) => _buildEntryCard(e)),
                    const SizedBox(height: 24),

                    /// 포함된 결과
                    const Text(
                      '📃 포함된 단어 결과',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (_partialMatches.isEmpty)
                      const Text('포함된 단어가 없습니다.')
                    else
                      ..._partialMatches.map((e) => _buildEntryCard(e)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
