import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

void main() {
  const sampleRate = 44100;
  final numSamples = (sampleRate * 1.6).toInt();
  final samples = Int16List(numSamples);
  final beepDefs = [
    [0.0, 0.18],
    [0.35, 0.53],
    [0.70, 0.88],
  ];
  for (final b in beepDefs) {
    final s0 = (b[0] * sampleRate).toInt();
    final s1 = (b[1] * sampleRate).toInt();
    final len = s1 - s0;
    final atk = (0.005 * sampleRate).toInt();
    for (int i = s0; i < s1 && i < numSamples; i++) {
      final p = i - s0;
      final env = p < atk ? p / atk : 1.0 - ((p - atk) / (len - atk));
      final v =
          22000 * sin(2 * pi * 880 * p / sampleRate) * env.clamp(0.0, 1.0);
      samples[i] = v.round().clamp(-32768, 32767);
    }
  }
  final n = numSamples;
  final buf = ByteData(44 + n * 2);
  void w(int o, String s) {
    for (int i = 0; i < s.length; i++) buf.setUint8(o + i, s.codeUnitAt(i));
  }

  w(0, 'RIFF');
  buf.setUint32(4, 36 + n * 2, Endian.little);
  w(8, 'WAVE');
  w(12, 'fmt ');
  buf.setUint32(16, 16, Endian.little);
  buf.setUint16(20, 1, Endian.little);
  buf.setUint16(22, 1, Endian.little);
  buf.setUint32(24, sampleRate, Endian.little);
  buf.setUint32(28, sampleRate * 2, Endian.little);
  buf.setUint16(32, 2, Endian.little);
  buf.setUint16(34, 16, Endian.little);
  w(36, 'data');
  buf.setUint32(40, n * 2, Endian.little);
  for (int i = 0; i < n; i++)
    buf.setInt16(44 + i * 2, samples[i], Endian.little);
  File(
    'assets/sounds/timer_done.wav',
  ).writeAsBytesSync(buf.buffer.asUint8List());
  print('Generated ${(44 + n * 2) ~/ 1024} KB');
}
