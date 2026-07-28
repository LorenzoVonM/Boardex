import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SinglePlayerSelectionScreen extends StatefulWidget {
  const SinglePlayerSelectionScreen({super.key});

  @override
  State<SinglePlayerSelectionScreen> createState() =>
      _SinglePlayerSelectionScreenState();
}

class _SinglePlayerSelectionScreenState
    extends State<SinglePlayerSelectionScreen>
    with TickerProviderStateMixin {
  final Map<int, _TouchPoint> _touchPoints = {};
  Timer? _selectionTimer;
  bool _isSelecting = false;
  bool _showInstructions = true;
  double _timerProgress = 0.0;
  Timer? _progressTimer;

  // Sequential numbering state
  final Map<int, int> _assignedNumbers = {}; // pointer id -> assigned number
  int _nextNumber = 1;
  bool _isAssigning = false;
  Timer? _assignTimer;
  Color? _winnerColor; // background color for first player

  final List<Color> _colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.amber,
    Colors.cyan,
  ];

  int _colorIndex = 0;

  Color _getNextColor() {
    final color = _colors[_colorIndex % _colors.length];
    _colorIndex++;
    return color;
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_isAssigning || _assignedNumbers.isNotEmpty) {
      // Reset if assignment is done or in progress
      _reset();
      return;
    }

    setState(() {
      _showInstructions = false;
      _touchPoints[event.pointer] = _TouchPoint(
        id: event.pointer,
        position: event.localPosition,
        color: _getNextColor(),
      );
    });

    _startTimerIfNeeded();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_isAssigning || _assignedNumbers.isNotEmpty) return;

    setState(() {
      if (_touchPoints.containsKey(event.pointer)) {
        _touchPoints[event.pointer] = _touchPoints[event.pointer]!.copyWith(
          position: event.localPosition,
        );
      }
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_isAssigning || _assignedNumbers.isNotEmpty) return;

    setState(() {
      _touchPoints.remove(event.pointer);
    });

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      setState(() {
        _showInstructions = true;
        _colorIndex = 0;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_isAssigning || _assignedNumbers.isNotEmpty) return;

    setState(() {
      _touchPoints.remove(event.pointer);
    });

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      setState(() {
        _showInstructions = true;
        _colorIndex = 0;
      });
    }
  }

  void _startTimerIfNeeded() {
    if (_selectionTimer != null || _isSelecting) return;

    _isSelecting = true;
    _timerProgress = 0.0;

    // Progress timer for visual feedback
    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _timerProgress = min(1.0, _timerProgress + (50 / 4000));
      });
    });

    _selectionTimer = Timer(const Duration(seconds: 4), () {
      _selectWinner();
    });
  }

  void _cancelTimer() {
    _selectionTimer?.cancel();
    _selectionTimer = null;
    _progressTimer?.cancel();
    _progressTimer = null;
    _isSelecting = false;
    _timerProgress = 0.0;
  }

  void _selectWinner() {
    _progressTimer?.cancel();
    _progressTimer = null;

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      return;
    }

    HapticFeedback.heavyImpact();

    setState(() {
      _timerProgress = 1.0;
      _isAssigning = true;
    });

    // Shuffle the keys randomly for assignment order
    final keys = _touchPoints.keys.toList()..shuffle(Random());
    _nextNumber = 1;

    // Assign numbers sequentially with a delay between each
    _assignNextNumber(keys, 0);
  }

  void _assignNextNumber(List<int> keys, int index) {
    if (index >= keys.length) {
      // Done assigning
      setState(() => _isAssigning = false);
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _assignedNumbers[keys[index]] = _nextNumber;
      if (_nextNumber == 1) {
        _winnerColor = _touchPoints[keys[index]]!.color;
      }
      _nextNumber++;
    });

    _assignTimer = Timer(const Duration(milliseconds: 500), () {
      _assignNextNumber(keys, index + 1);
    });
  }

  void _reset() {
    _cancelTimer();
    _assignTimer?.cancel();
    _assignTimer = null;
    setState(() {
      _touchPoints.clear();
      _assignedNumbers.clear();
      _nextNumber = 1;
      _isAssigning = false;
      _winnerColor = null;
      _showInstructions = true;
      _colorIndex = 0;
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    _assignTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Competitive'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_assignedNumbers.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _reset,
              tooltip: 'Reset',
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Background - animates to winner color
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _winnerColor != null
                      ? [
                          _winnerColor!.withValues(alpha: 0.4),
                          _winnerColor!.withValues(alpha: 0.6),
                          _winnerColor!.withValues(alpha: 0.4),
                        ]
                      : [
                          Colors.grey[900]!,
                          Colors.grey[850]!,
                          Colors.grey[900]!,
                        ],
                ),
              ),
            ),

            // Timer progress indicator at bottom
            if (_isSelecting && _assignedNumbers.isEmpty)
              Positioned(
                bottom: MediaQuery.of(context).viewPadding.bottom,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: _timerProgress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.5),
                  ),
                  minHeight: 4,
                ),
              ),

            // Instructions
            if (_showInstructions)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app,
                      size: 80,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Everyone place a finger\non the screen',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hold for 4 seconds',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ),
              ),

            // Touch circles
            ..._touchPoints.entries.map((entry) {
              final point = entry.value;
              final number = _assignedNumbers[entry.key];

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: point.position.dx - 60,
                top: point.position.dy - 60,
                child: _TouchCircle(
                  color: point.color,
                  isWinner: number == 1,
                  progress: _timerProgress,
                  number: number,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _TouchPoint {
  final int id;
  final Offset position;
  final Color color;

  _TouchPoint({required this.id, required this.position, required this.color});

  _TouchPoint copyWith({int? id, Offset? position, Color? color}) {
    return _TouchPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
    );
  }
}

class _TouchCircle extends StatefulWidget {
  final Color color;
  final bool isWinner;
  final double progress;
  final int? number;

  const _TouchCircle({
    required this.color,
    required this.isWinner,
    required this.progress,
    this.number,
  });

  @override
  State<_TouchCircle> createState() => _TouchCircleState();
}

class _TouchCircleState extends State<_TouchCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(_TouchCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.number != null && oldWidget.number == null) {
      // Number just assigned — pulse animation
      _controller.duration = const Duration(milliseconds: 500);
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: widget.isWinner ? 1.4 : 1.15,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.3),
              border: Border.all(
                color: widget.color,
                width: widget.isWinner ? 6 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: widget.isWinner ? 30 : 20,
                  spreadRadius: widget.isWinner ? 10 : 5,
                ),
              ],
            ),
            child: widget.number != null
                ? Center(
                    child: Text(
                      '${widget.number}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isWinner ? 40 : 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
          ),
        );
      },
    );
  }
}
