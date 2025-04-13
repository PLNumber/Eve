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

  Future<void> _initAudio() async {
    final prefs = await SharedPreferences.getInstance();
    _isPlaying = prefs.getBool('sound_enabled') ?? true;
    _volume = prefs.getDouble('sound_volume') ?? 0.5;
    _currentMusic = prefs.getString('music_filename') ?? 'Vivaldi_Spring.mp3';

    await _setMusic(_currentMusic);

    if (_isPlaying) {
      await _player.resume();
    }

    notifyListeners();
  }

  Future<void> _setMusic(String filename) async {
    _currentMusic = filename;
    await _player.setSource(AssetSource('audio/$filename'));
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(_volume);
  }

  Future<void> togglePlay() async {
    final prefs = await SharedPreferences.getInstance();
    if (_isPlaying) {
      await _player.pause();
      await prefs.setBool('sound_enabled', false);
    } else {
      await _player.resume();
      await prefs.setBool('sound_enabled', true);
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> setVolume(double value) async {
    final prefs = await SharedPreferences.getInstance();
    _volume = value;
    await _player.setVolume(_volume);
    await prefs.setDouble('sound_volume', _volume);
    notifyListeners();
  }

  Future<void> changeMusic(String filename) async {
    final prefs = await SharedPreferences.getInstance();
    await _player.stop(); // 현재 음악 멈춤
    await _setMusic(filename);
    await prefs.setString('music_filename', filename);
    if (_isPlaying) await _player.resume(); // 소리가 켜져있으면 바로 재생
    notifyListeners();
  }
}
