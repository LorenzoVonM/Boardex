import 'dart:async';
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../utils/theme_utils.dart';
import '../widgets/glass_app_bar.dart';

enum _TimerState { idle, running, paused, finished }

class TimerToolScreen extends StatefulWidget {
  const TimerToolScreen({super.key});

  @override
  State<TimerToolScreen> createState() => _TimerToolScreenState();
}

class _TimerToolScreenState extends State<TimerToolScreen>
    with SingleTickerProviderStateMixin {
  int _selectedMinutes = 3;
  int _selectedSeconds = 0;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  _TimerState _state = _TimerState.idle;
  Timer? _ticker;
  final AudioPlayer _audioPlayer = AudioPlayer();

  late final AnimationController _pulseAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );

  final FixedExtentScrollController _minCtrl = FixedExtentScrollController(
    initialItem: 3,
  );
  final FixedExtentScrollController _secCtrl = FixedExtentScrollController(
    initialItem: 0,
  );

  @override
  void dispose() {
    _ticker?.cancel();
    WakelockPlus.disable();
    _pulseAnim.dispose();
    _audioPlayer.dispose();
    _minCtrl.dispose();
    _secCtrl.dispose();
    super.dispose();
  }

  void _start() {
    final total = _selectedMinutes * 60 + _selectedSeconds;
    if (total == 0) return;
    WakelockPlus.enable();
    setState(() {
      _totalSeconds = total;
      _remainingSeconds = total;
      _state = _TimerState.running;
    });
    _runTicker();
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _state = _TimerState.paused);
  }

  void _resume() {
    WakelockPlus.enable();
    setState(() => _state = _TimerState.running);
    _runTicker();
  }

  void _reset() {
    _ticker?.cancel();
    WakelockPlus.disable();
    _pulseAnim
      ..stop()
      ..reset();
    setState(() {
      _remainingSeconds = 0;
      _totalSeconds = 0;
      _state = _TimerState.idle;
    });
  }

  void _runTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingSeconds <= 1) {
        _ticker?.cancel();
        setState(() {
          _remainingSeconds = 0;
          _state = _TimerState.finished;
        });
        WakelockPlus.disable();
        SystemSound.play(SystemSoundType.alert);
        _audioPlayer.play(AssetSource('sounds/timer_done.wav'));
        _pulseAnim.repeat(reverse: true);
        _tripleVibrate();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  // Three 600ms vibrations with 300ms gaps via the Vibrator API
  Future<void> _tripleVibrate() async {
    if (!await Vibration.hasVibrator()) return;
    Vibration.vibrate(pattern: [0, 600, 300, 600, 300, 600]);
  }

  String get _displayTime {
    final sec = _state == _TimerState.idle
        ? _selectedMinutes * 60 + _selectedSeconds
        : _remainingSeconds;
    return '${(sec ~/ 60).toString().padLeft(2, '0')}:${(sec % 60).toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0 || _state == _TimerState.idle) return 1.0;
    return _remainingSeconds / _totalSeconds;
  }

  Color get _arcColor {
    if (_state == _TimerState.finished) return AppColors.resultLost;
    if (_state == _TimerState.running || _state == _TimerState.paused) {
      if (_remainingSeconds <= 10) return AppColors.resultLost;
      if (_totalSeconds > 0 && _remainingSeconds <= _totalSeconds * 0.25) {
        return AppColors.ratingLow;
      }
    }
    return AppColors.brandTeal;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isIdle = _state == _TimerState.idle;
    final isFinished = _state == _TimerState.finished;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const GlassAppBar(
        title: 'Timer',
        titleColor: AppColors.brandTeal,
        titleIcon: Icons.timer_rounded,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top + kToolbarHeight + 8,
            ),

            // Arc + time display
            Expanded(
              child: Center(
                child: ScaleTransition(
                  scale: Tween<double>(begin: 1.0, end: 1.04).animate(
                    CurvedAnimation(
                      parent: _pulseAnim,
                      curve: Curves.easeInOut,
                    ),
                  ),
                  child: SizedBox(
                    width: 270,
                    height: 270,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(270, 270),
                          painter: _TimerArcPainter(
                            progress: _progress,
                            arcColor: _arcColor,
                            trackColor: colorScheme.outlineVariant.withValues(
                              alpha: 0.3,
                            ),
                            glowing: _state == _TimerState.running,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 200),
                              style: TextStyle(
                                fontSize: 56,
                                fontWeight: FontWeight.w200,
                                letterSpacing: 3,
                                color: isFinished
                                    ? AppColors.resultLost
                                    : colorScheme.onSurface,
                              ),
                              child: Text(_displayTime),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 200),
                              child: switch (_state) {
                                _TimerState.paused => Text(
                                  'PAUSED',
                                  key: const ValueKey('paused'),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 2.5,
                                    color: colorScheme.outline,
                                  ),
                                ),
                                _TimerState.finished => Text(
                                  "TIME'S UP",
                                  key: const ValueKey('done'),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 2.5,
                                    color: AppColors.resultLost,
                                  ),
                                ),
                                _ => const SizedBox.shrink(
                                  key: ValueKey('empty'),
                                ),
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Scroll-wheel time picker (idle only)
            AnimatedSize(
              duration: const Duration(milliseconds: 280),
              curve: Curves.easeInOut,
              child: isIdle
                  ? Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _buildPickers(context),
                    )
                  : const SizedBox.shrink(),
            ),

            // Action buttons
            Padding(
              padding: EdgeInsets.fromLTRB(
                28,
                12,
                28,
                20 + MediaQuery.of(context).viewPadding.bottom,
              ),
              child: _buildButtons(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickers(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final numStyle = TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.w300,
      color: colorScheme.onSurface,
    );
    final labelStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 1.5,
      color: colorScheme.outline,
    );

    Widget wheel({
      required FixedExtentScrollController ctrl,
      required int count,
      required ValueChanged<int> onChanged,
    }) {
      return SizedBox(
        height: 130,
        width: 72,
        child: ListWheelScrollView.useDelegate(
          controller: ctrl,
          itemExtent: 46,
          physics: const FixedExtentScrollPhysics(),
          perspective: 0.003,
          diameterRatio: 1.5,
          onSelectedItemChanged: onChanged,
          childDelegate: ListWheelChildBuilderDelegate(
            childCount: count,
            builder: (_, i) => Center(
              child: Text(i.toString().padLeft(2, '0'), style: numStyle),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('min', style: labelStyle),
            const SizedBox(height: 4),
            wheel(
              ctrl: _minCtrl,
              count: 100,
              onChanged: (v) => setState(() => _selectedMinutes = v),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20),
          child: Text(
            ' : ',
            style: numStyle.copyWith(fontSize: 36, color: colorScheme.outline),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('sec', style: labelStyle),
            const SizedBox(height: 4),
            wheel(
              ctrl: _secCtrl,
              count: 60,
              onChanged: (v) => setState(() => _selectedSeconds = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final buttonShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    );
    const fullWidth = Size(double.infinity, 56);

    return switch (_state) {
      _TimerState.idle => FilledButton.icon(
        onPressed: (_selectedMinutes + _selectedSeconds) > 0 ? _start : null,
        icon: const Icon(Icons.play_arrow_rounded, size: 26),
        label: const Text('Start', style: TextStyle(fontSize: 17)),
        style: FilledButton.styleFrom(
          minimumSize: fullWidth,
          backgroundColor: AppColors.brandTeal,
          foregroundColor: Colors.white,
          shape: buttonShape,
        ),
      ),
      _TimerState.running => Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _pause,
              icon: const Icon(Icons.pause_rounded, size: 26),
              label: const Text('Pause', style: TextStyle(fontSize: 17)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                shape: buttonShape,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 56,
            width: 56,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: buttonShape,
              ),
              child: const Icon(Icons.stop_rounded),
            ),
          ),
        ],
      ),
      _TimerState.paused => Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: _resume,
              icon: const Icon(Icons.play_arrow_rounded, size: 26),
              label: const Text('Resume', style: TextStyle(fontSize: 17)),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 56),
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                shape: buttonShape,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            height: 56,
            width: 56,
            child: OutlinedButton(
              onPressed: _reset,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: buttonShape,
              ),
              child: const Icon(Icons.stop_rounded),
            ),
          ),
        ],
      ),
      _TimerState.finished => FilledButton.icon(
        onPressed: _reset,
        icon: const Icon(Icons.replay_rounded, size: 26),
        label: const Text('Reset', style: TextStyle(fontSize: 17)),
        style: FilledButton.styleFrom(
          minimumSize: fullWidth,
          backgroundColor: AppColors.resultLost,
          foregroundColor: Colors.white,
          shape: buttonShape,
        ),
      ),
    };
  }
}

class _TimerArcPainter extends CustomPainter {
  final double progress;
  final Color arcColor;
  final Color trackColor;
  final bool glowing;

  const _TimerArcPainter({
    required this.progress,
    required this.arcColor,
    required this.trackColor,
    required this.glowing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 18;
    const strokeWidth = 15.0;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = trackColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    if (sweepAngle <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Glow behind arc when running
    if (glowing) {
      canvas.drawArc(
        rect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = arcColor.withValues(alpha: 0.3)
          ..strokeWidth = strokeWidth * 2.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }

    // Main arc
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = arcColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_TimerArcPainter old) =>
      old.progress != progress ||
      old.arcColor != arcColor ||
      old.glowing != glowing;
}
