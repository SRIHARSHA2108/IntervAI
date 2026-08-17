import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:record/record.dart';

class VoiceProfile {
  const VoiceProfile(this.features);
  final List<double> features;
}

class VoiceMatchResult {
  const VoiceMatchResult({required this.matches, required this.similarity});
  final bool matches;
  final double similarity;
}

class OfflineVoiceBiometrics {
  final AudioRecorder _recorder = AudioRecorder();
  final List<int> _audio = [];
  StreamSubscription<Uint8List>? _subscription;
  String? lastError;

  Future<bool> startCapture() async {
    lastError = null;
    try {
      if (!await _recorder.hasPermission()) {
        lastError = 'Microphone permission was denied.';
        return false;
      }
      if (await _recorder.isRecording()) await _recorder.stop();
      await _subscription?.cancel();
      _audio.clear();
      final stream = await _recorder.startStream(
        const RecordConfig(
          encoder: AudioEncoder.pcm16bits,
          sampleRate: 16000,
          numChannels: 1,
        ),
      );
      _subscription = stream.listen(
        _audio.addAll,
        onError: (Object error) => lastError = 'Recording failed: $error',
      );
      return true;
    } catch (error) {
      lastError = 'Unable to start the microphone: $error';
      return false;
    }
  }

  Future<VoiceProfile?> stopAndCreateProfile() async {
    lastError = null;
    try {
      if (!await _recorder.isRecording()) {
        lastError = 'No voice recording is currently active.';
        return null;
      }
      await _recorder.stop();
      await _subscription?.cancel();
      _subscription = null;
      final features = _extract(_audio);
      if (features == null) {
        lastError = 'Not enough clear speech was captured.';
        return null;
      }
      return VoiceProfile(features);
    } catch (error) {
      lastError = 'Unable to finish the recording: $error';
      return null;
    }
  }

  Future<VoiceMatchResult?> stopAndCompare(VoiceProfile profile) async {
    final current = await stopAndCreateProfile();
    if (current == null) return null;
    var distance = 0.0;
    for (var i = 0; i < profile.features.length; i++) {
      distance += pow(profile.features[i] - current.features[i], 2);
    }
    distance = sqrt(distance / profile.features.length);
    final similarity = (1 - distance).clamp(0, 1).toDouble();
    return VoiceMatchResult(matches: similarity >= .62, similarity: similarity);
  }

  List<double>? _extract(List<int> bytes) {
    if (bytes.length < 16000) return null;
    final samples = <double>[];
    for (var i = 0; i + 1 < bytes.length; i += 2) {
      var value = bytes[i] | (bytes[i + 1] << 8);
      if (value >= 32768) value -= 65536;
      samples.add(value / 32768.0);
    }
    final voiced = samples.where((sample) => sample.abs() > .004).toList();
    if (voiced.length < 2000) return null;
    final rms = sqrt(
      voiced.map((v) => v * v).reduce((a, b) => a + b) / voiced.length,
    );
    final meanAbs =
        voiced.map((v) => v.abs()).reduce((a, b) => a + b) / voiced.length;
    final peak = voiced.map((v) => v.abs()).reduce(max);
    var crossings = 0;
    for (var i = 1; i < voiced.length; i++) {
      if ((voiced[i - 1] < 0) != (voiced[i] < 0)) crossings++;
    }
    final features = <double>[rms, meanAbs, peak, crossings / voiced.length];
    final window = max(1, voiced.length ~/ 8);
    for (var section = 0; section < 8; section++) {
      final start = section * window;
      final end = min(voiced.length, start + window);
      if (start >= end) {
        features.add(0);
      } else {
        features.add(
          voiced
                  .sublist(start, end)
                  .map((v) => v.abs())
                  .reduce((a, b) => a + b) /
              (end - start),
        );
      }
    }
    return features;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _recorder.dispose();
  }
}
