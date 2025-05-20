import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioProvider0 with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true; // Настройка звука
  double _volume = 0.5; // Мягкая громкость по умолчанию

  DateTime? _lastPlayedTime;
  static const _minInterval = Duration(seconds: 20);

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> playNotificationSound() async {
    if (!_isSoundEnabled) return;
    try {

      final now = DateTime.now();
      // Проверяем, прошло ли достаточно времени с последнего воспроизведения
      if (_lastPlayedTime == null || now.difference(_lastPlayedTime!) >= _minInterval) {
        // Здесь ваша логика воспроизведения звука, например:
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource('sound4.mp3'));
        _lastPlayedTime = now;
        notifyListeners();
      }

    } catch (e) {
      print('Ошибка воспроизведения звука: $e');
    }
  }

  Future<void> playSound(String assetPath) async {
    if (!_isSoundEnabled) return;
    try {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      print('Ошибка воспроизведения звука: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}










class AudioProvider with ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;
  double _volume = 0.5;
  DateTime? _lastPlayedTime;
  static const _minInterval = Duration(seconds: 2);

  bool get isSoundEnabled => _isSoundEnabled;
  double get volume => _volume;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
    notifyListeners();
  }

  void setVolume(double volume) {
    _volume = volume.clamp(0.0, 1.0);
    notifyListeners();
  }

  Future<void> playNotificationSound() async {
    debugPrint('AudioProvider: Попытка воспроизведения звука...');
    if (!_isSoundEnabled) {
      debugPrint('AudioProvider: Звук отключён (_isSoundEnabled = false)');
      return;
    }

    try {
      final now = DateTime.now();
      if (_lastPlayedTime == null || now.difference(_lastPlayedTime!) >= _minInterval) {
        debugPrint('AudioProvider: Воспроизведение звука sound4.mp3...');
        await _audioPlayer.setVolume(_volume);
        await _audioPlayer.play(AssetSource('sound4.mp3'));
        _lastPlayedTime = now;
        notifyListeners();
      } else {
        debugPrint('AudioProvider: Интервал меньше $_minInterval, звук не воспроизведён');
      }
    } catch (e) {
      debugPrint('AudioProvider: Ошибка воспроизведения звука: $e');
    }
  }

  Future<void> playSound(String assetPath) async {
    debugPrint('AudioProvider: Воспроизведение звука $assetPath...');
    if (!_isSoundEnabled) {
      debugPrint('AudioProvider: Звук отключён (_isSoundEnabled = false)');
      return;
    }

    try {
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('AudioProvider: Ошибка воспроизведения звука: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('AudioProvider: Dispose, освобождение AudioPlayer...');
    _audioPlayer.dispose();
    super.dispose();
  }
}