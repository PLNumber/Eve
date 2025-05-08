//lib/provider/audio_provider.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioProvider with ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  final List<String> _musicList = [
    'Vivaldi_Spring.mp3',
    'Vivaldi_Summer.mp3',
    'Vivaldi_fallen.mp3',
    'Vivaldi_Winter.mp3',
  ];

  bool _isPlaying = false;
  double _volume = 0.5;
  String _currentMusic = 'Vivaldi_Spring.mp3';

  bool get isPlaying => _isPlaying;
  double get volume => _volume;
  String get currentMusic => _currentMusic;
  List<String> get musicList => _musicList;

  AudioProvider() {
    _initAudio();
  }

  //음악 초기 설정
  Future<void> _initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    _isPlaying = prefs.getBool('sound_enabled') ?? true;
    _volume = prefs.getDouble('sound_volume') ?? 0.5;
    _currentMusic = prefs.getString('music_filename') ?? 'Vivaldi_Spring.mp3';

    print("🎧 초기화: isPlaying=$_isPlaying, volume=$_volume, currentMusic=$_currentMusic");

    try {
      await _setMusic(_currentMusic);
      if (_isPlaying) {
        print("▶️ 음악 재생 시도");
        await _player.resume();
      }
    } catch (e) {
      print("❌ _initAudio 오류: $e");
    }

    notifyListeners();
  }


  //음악 설정
  Future<void> _setMusic(String filename) async {
    _currentMusic = filename;
    print("🎼 음악 설정: $filename");

    try {
      await _player.setSource(AssetSource('audio/$filename'));
      await _player.setReleaseMode(ReleaseMode.loop);
      await _player.setVolume(_volume);
    } catch (e) {
      print("❌ _setMusic 오류: $e");
    }
  }


  // 음악 실행
  Future<void> togglePlay() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      if (_isPlaying) {
        print("⏸ 음악 일시 정지");
        await _player.pause();
        await prefs.setBool('sound_enabled', false);
      } else {
        print("▶️ 음악 재생");
        await _player.resume();
        await prefs.setBool('sound_enabled', true);
      }
      _isPlaying = !_isPlaying;
    } catch (e) {
      print("❌ togglePlay 오류: $e");
    }

    notifyListeners();
  }


  // 음량 설정
  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    _volume = value;
    await _player.setVolume(_volume);
    await prefs.setDouble('sound_volume', _volume);
    notifyListeners();
  }

  //음악 변경 설정
  Future<void> changeMusic(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    await _player.stop(); // 현재 음악 멈춤
    await _setMusic(filename);
    await prefs.setString('music_filename', filename);
    if (_isPlaying) await _player.resume(); // 소리가 켜져있으면 바로 재생
    notifyListeners();
  }
}
