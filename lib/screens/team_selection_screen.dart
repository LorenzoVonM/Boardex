import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeamSelectionScreen extends StatefulWidget {
  final int teamCount;

  const TeamSelectionScreen({super.key, required this.teamCount});

  @override
  State<TeamSelectionScreen> createState() => _TeamSelectionScreenState();
}

class _TeamSelectionScreenState extends State<TeamSelectionScreen>
    with TickerProviderStateMixin {
  final Map<int, _TeamTouchPoint> _touchPoints = {};
  Timer? _selectionTimer;
  Timer? _progressTimer;
  bool _isSelecting = false;
  bool _showInstructions = true;
  double _timerProgress = 0.0;
  bool _teamsAssigned = false;
  int? _winningTeam; // index of winning team
  Color? _winningColor;

  // Team colors
  static const List<Color> _teamColors = [
    Color(0xFF4CAF50), // Green
    Color(0xFF2196F3), // Blue
    Color(0xFFFF9800), // Orange
  ];

  static const Color _grayColor = Colors.grey;

  void _onPointerDown(PointerDownEvent event) {
    if (_teamsAssigned) {
      _reset();
      return;
    }

    setState(() {
      _showInstructions = false;
      _touchPoints[event.pointer] = _TeamTouchPoint(
        id: event.pointer,
        position: event.localPosition,
        color: _grayColor,
      );
    });

    _startTimerIfNeeded();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_teamsAssigned) return;

    setState(() {
      if (_touchPoints.containsKey(event.pointer)) {
        _touchPoints[event.pointer] = _touchPoints[event.pointer]!.copyWith(
          position: event.localPosition,
        );
      }
    });
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_teamsAssigned) return;

    setState(() {
      _touchPoints.remove(event.pointer);
    });

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      setState(() {
        _showInstructions = true;
      });
    }
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_teamsAssigned) return;

    setState(() {
      _touchPoints.remove(event.pointer);
    });

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      setState(() {
        _showInstructions = true;
      });
    }
  }

  void _startTimerIfNeeded() {
    if (_selectionTimer != null || _isSelecting) return;

    _isSelecting = true;
    _timerProgress = 0.0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _timerProgress = min(1.0, _timerProgress + (50 / 4000));
      });
    });

    _selectionTimer = Timer(const Duration(seconds: 4), () {
      _assignTeams();
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

  void _assignTeams() {
    _progressTimer?.cancel();
    _progressTimer = null;

    if (_touchPoints.isEmpty) {
      _cancelTimer();
      return;
    }

    HapticFeedback.heavyImpact();

    final random = Random();
    final keys = _touchPoints.keys.toList()..shuffle(random);
    final teamCount = widget.teamCount;

    // Distribute players as evenly as possible
    final Map<int, int> teamAssignment = {}; // pointer id -> team index
    for (int i = 0; i < keys.length; i++) {
      teamAssignment[keys[i]] = i % teamCount;
    }

    // Assign colors based on team
    setState(() {
      for (final entry in teamAssignment.entries) {
        final teamIdx = entry.value;
        _touchPoints[entry.key] = _touchPoints[entry.key]!.copyWith(
          color: _teamColors[teamIdx],
          teamIndex: teamIdx,
        );
      }
      _teamsAssigned = true;
      _timerProgress = 1.0;
    });

    // After a short delay, pick a winning team
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;

      final winTeam = random.nextInt(teamCount);
      HapticFeedback.heavyImpact();

      setState(() {
        _winningTeam = winTeam;
        _winningColor = _teamColors[winTeam];
      });
    });
  }

  void _reset() {
    _cancelTimer();
    setState(() {
      _touchPoints.clear();
      _teamsAssigned = false;
      _winningTeam = null;
      _winningColor = null;
      _showInstructions = true;
    });
  }

  @override
  void dispose() {
    _cancelTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text('${widget.teamCount} Teams'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_teamsAssigned)
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
            // Background — animates to winning team color
            AnimatedContainer(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _winningColor != null
                      ? [
                          _winningColor!.withValues(alpha: 0.3),
                          _winningColor!.withValues(alpha: 0.5),
                          _winningColor!.withValues(alpha: 0.3),
                        ]
                      : [
                          Colors.grey[900]!,
                          Colors.grey[850]!,
                          Colors.grey[900]!,
                        ],
                ),
              ),
            ),

            // Timer progress
            if (_isSelecting && !_teamsAssigned)
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
                      'Hold for 4 seconds to form ${widget.teamCount} teams',
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
              final isWinningTeam =
                  _winningTeam != null && point.teamIndex == _winningTeam;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: point.position.dx - 60,
                top: point.position.dy - 60,
                child: _TeamTouchCircle(
                  color: point.color,
                  isWinningTeam: isWinningTeam,
                  isAssigned: _teamsAssigned,
                  teamLabel: point.teamIndex != null
                      ? 'T${point.teamIndex! + 1}'
                      : null,
                ),
              );
            }),

            // Winning team banner
            if (_winningTeam != null)
              Positioned(
                bottom: 100 + MediaQuery.of(context).viewPadding.bottom,
                left: 0,
                right: 0,
                child: Center(
                  child: _TeamWinnerBanner(
                    teamNumber: _winningTeam! + 1,
                    color: _teamColors[_winningTeam!],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TeamTouchPoint {
  final int id;
  final Offset position;
  final Color color;
  final int? teamIndex;

  _TeamTouchPoint({
    required this.id,
    required this.position,
    required this.color,
    this.teamIndex,
  });

  _TeamTouchPoint copyWith({
    int? id,
    Offset? position,
    Color? color,
    int? teamIndex,
  }) {
    return _TeamTouchPoint(
      id: id ?? this.id,
      position: position ?? this.position,
      color: color ?? this.color,
      teamIndex: teamIndex ?? this.teamIndex,
    );
  }
}

class _TeamTouchCircle extends StatefulWidget {
  final Color color;
  final bool isWinningTeam;
  final bool isAssigned;
  final String? teamLabel;

  const _TeamTouchCircle({
    required this.color,
    required this.isWinningTeam,
    required this.isAssigned,
    this.teamLabel,
  });

  @override
  State<_TeamTouchCircle> createState() => _TeamTouchCircleState();
}

class _TeamTouchCircleState extends State<_TeamTouchCircle>
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
  void didUpdateWidget(_TeamTouchCircle oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAssigned && !oldWidget.isAssigned) {
      // Team color assigned — pulse
      _controller.duration = const Duration(milliseconds: 500);
      _scaleAnimation = Tween<double>(
        begin: 0.9,
        end: 1.0,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
      _controller.forward(from: 0);
    } else if (widget.isWinningTeam && !oldWidget.isWinningTeam) {
      // Winning team — bigger pulse
      _controller.duration = const Duration(milliseconds: 600);
      _scaleAnimation = Tween<double>(
        begin: 1.0,
        end: 1.3,
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.3),
              border: Border.all(
                color: widget.color,
                width: widget.isWinningTeam ? 6 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.color.withValues(alpha: 0.5),
                  blurRadius: widget.isWinningTeam ? 30 : 20,
                  spreadRadius: widget.isWinningTeam ? 10 : 5,
                ),
              ],
            ),
            child: widget.teamLabel != null
                ? Center(
                    child: Text(
                      widget.teamLabel!,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.isWinningTeam ? 28 : 22,
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

class _TeamWinnerBanner extends StatefulWidget {
  final int teamNumber;
  final Color color;

  const _TeamWinnerBanner({required this.teamNumber, required this.color});

  @override
  State<_TeamWinnerBanner> createState() => _TeamWinnerBannerState();
}

class _TeamWinnerBannerState extends State<_TeamWinnerBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

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

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
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
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🎉', style: TextStyle(fontSize: 28)),
                  const SizedBox(height: 4),
                  Text(
                    'TEAM ${widget.teamNumber} STARTS!',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
