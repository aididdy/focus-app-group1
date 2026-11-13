import 'dart:async';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// --------------------------------------------------
// MAIN APP
// --------------------------------------------------

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Focus Buddy',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF7868E6),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F5FF),
      ),
      home: const FocusBuddyPage(),
    );
  }
}

// --------------------------------------------------
// FOCUS BUDDY PAGE
// --------------------------------------------------

class FocusBuddyPage extends StatefulWidget {
  const FocusBuddyPage({super.key});

  @override
  State<FocusBuddyPage> createState() => _FocusBuddyPageState();
}

class _FocusBuddyPageState extends State<FocusBuddyPage>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _animationController;

  final TextEditingController _taskController = TextEditingController();

  int _selectedMinutes = 25;
  int _remainingSeconds = 25 * 60;
  int _completedSessions = 0;

  bool _isRunning = false;
  
  // Tracks if the user is currently celebrating a completed task
  bool _isCelebrating = false; 

  String _message = "Let's study together!";

  final List<String> _encouragements = [
    "You are doing great!",
    "Keep going! I believe in you!",
    "One step at a time!",
    "You're smarter than you think!",
    "Don't give up. You've got this!",
    "Let's keep learning together!",
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  // --------------------------------------------------
  // TIMER FUNCTIONS
  // --------------------------------------------------

  void _startTimer() {
    if (_isRunning) return;

    // Improved: Check if a task is entered
    if (_taskController.text.trim().isEmpty) {
      setState(() {
        _message = "Please write down what you're working on first!";
        _isCelebrating = false;
      });
      return;
    }

    if (_remainingSeconds <= 0) {
      _resetTimer();
    }

    setState(() {
      _isRunning = true;
      _isCelebrating = false;
      _message = "You've got this! Keep focusing!";
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      }

      if (_remainingSeconds <= 0) {
        timer.cancel();

        setState(() {
          _isRunning = false;
          _completedSessions++;
          _message = "Amazing! You completed your session!";
          _isCelebrating = true; // Trigger celebration jump
        });

        _showCompletionDialog();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isCelebrating = false;
      _message = "Take a breath. You're doing well!";
    });
  }

  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _remainingSeconds = _selectedMinutes * 60;
      _message = "Ready when you are!";
      _isCelebrating = false;
    });
  }

  void _changeDuration(int minutes) {
    if (_isRunning) return;

    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
      _message = "Let's try a $minutes-minute session!";
      _isCelebrating = false;
    });
  }

  void _showCompletionDialog() {
    final completedTask = _taskController.text.trim();

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            "Fantastic work!",
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "🎉",
                style: TextStyle(fontSize: 55),
              ),
              const SizedBox(height: 12),
              Text(
                "You finished: $completedTask",
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Take a short break before your next session.",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _taskController.clear(); // Clear task for next time
                _resetTimer();
              },
              child: const Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  // --------------------------------------------------
  // CHARACTER INTERACTION
  // --------------------------------------------------

  void _encourageUser() {
    final index = DateTime.now().millisecond % _encouragements.length;

    setState(() {
      _message = _encouragements[index];
      _isCelebrating = false;
    });
  }

  // --------------------------------------------------
  // TIME FORMATTING
  // --------------------------------------------------

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalSeconds = _selectedMinutes * 60;

    if (totalSeconds == 0) return 0;

    return 1 - (_remainingSeconds / totalSeconds);
  }

  // --------------------------------------------------
  // MAIN USER INTERFACE
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 18,
          ),
          child: Column(
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "FOCUS BUDDY",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Color(0xFF7868E6),
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Study time!",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF302B50),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Color(0xFF7868E6),
                      size: 28,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              // TASK INPUT
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "What are you working on?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _taskController,
                      enabled: !_isRunning, // Lock input while running
                      decoration: InputDecoration(
                        hintText: "Enter your study task...",
                        prefixIcon: const Icon(Icons.edit_note_rounded),
                        filled: true,
                        fillColor: const Color(0xFFF7F5FF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // CHARACTER AND SPEECH BUBBLE
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFEAE5FF),
                      Color(0xFFF4EFFF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _encourageUser,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          // Celebration jump is much bigger
                          double jumpHeight = _isCelebrating 
                              ? -20 * _animationController.value 
                              : (_isRunning ? -7 * _animationController.value : -3 * _animationController.value);

                          return Transform.translate(
                            offset: Offset(0, jumpHeight),
                            child: child,
                          );
                        },
                        child: const HumanCharacter(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF51477E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Tap your buddy for encouragement!",
                      style: TextStyle(
                        color: Color(0xFF7868A6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // TIMER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Column(
                  children: [
                    const Text(
                      "YOUR FOCUS TIMER",
                      style: TextStyle(
                        letterSpacing: 1.5,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF9289B2),
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    // NEW: VISUAL POMODORO COUNTER
                    _buildPomodoroTracker(),
                    
                    const SizedBox(height: 16),

                    SizedBox(
                      width: 190,
                      height: 190,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 190,
                            height: 190,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: _progress),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, _) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 12,
                                  backgroundColor: const Color(0xFFEAE6F5),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF7868E6),
                                  ),
                                  strokeCap: StrokeCap.round,
                                );
                              },
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _formattedTime,
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF302B50),
                                ),
                              ),
                              Text(
                                _isRunning
                                    ? "STAY FOCUSED"
                                    : "READY TO FOCUS",
                                style: const TextStyle(
                                  fontSize: 10,
                                  letterSpacing: 1,
                                  color: Color(0xFF9289B2),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // TIMER PRESETS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _durationButton(25),
                        const SizedBox(width: 10),
                        _durationButton(15),
                        const SizedBox(width: 10),
                        _durationButton(5),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // START AND PAUSE
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: ElevatedButton.icon(
                            onPressed: _isRunning ? _pauseTimer : _startTimer,
                            icon: Icon(
                              _isRunning
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                            ),
                            label: Text(
                              _isRunning ? "Pause" : "Start Focus",
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7868E6),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _resetTimer,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text("Reset"),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF7868E6),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // COMPLETED SESSIONS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF1D9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFFE9A52A),
                      size: 34,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Focus sessions completed",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF75521A),
                            ),
                          ),
                          Text(
                            "$_completedSessions sessions",
                            style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9C6711),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              const Text(
                "Small steps make big progress.",
                style: TextStyle(
                  color: Color(0xFF9289B2),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // NEW VISUAL TRACKER WIDGET
  // --------------------------------------------------

  Widget _buildPomodoroTracker() {
    // Shows a cycle of 4 sessions
    int cycleProgress = _completedSessions % 4;
    if (_completedSessions > 0 && cycleProgress == 0) cycleProgress = 4;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        bool isFilled = index < cycleProgress;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isFilled ? const Color(0xFF7868E6) : const Color(0xFFF2F0FA),
            shape: BoxShape.circle,
            border: Border.all(
              color: isFilled ? const Color(0xFF7868E6) : const Color(0xFFD4CDF0),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              isFilled ? "🍅" : "○",
              style: TextStyle(
                fontSize: isFilled ? 20 : 16,
                color: isFilled ? Colors.white : Colors.grey,
              ),
            ),
          ),
        );
      }),
    );
  }

  // --------------------------------------------------
  // DURATION BUTTON
  // --------------------------------------------------

  Widget _durationButton(int minutes) {
    final selected = _selectedMinutes == minutes;

    return Expanded(
      child: GestureDetector(
        onTap: () => _changeDuration(minutes),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? const Color(0xFF7868E6)
                : const Color(0xFFF2F0FA),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Column(
            children: [
              Text(
                "${minutes}m",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              Text(
                minutes == 25
                    ? "Focus"
                    : minutes == 15
                        ? "Break"
                        : "Short",
                style: TextStyle(
                  fontSize: 11,
                  color: selected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------
// HUMAN STUDY COMPANION
// --------------------------------------------------

class HumanCharacter extends StatelessWidget {
  const HumanCharacter({super.key});

  @override
  Widget build(BuildContext context) {
    const skin = Color(0xFFFFC49B);
    const hair = Color(0xFF49352F);
    const shirt = Color(0xFF7868E6);
    const trousers = Color(0xFF34476D);

    return SizedBox(
      width: 180,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // LEGS
          Positioned(
            bottom: 4,
            left: 61,
            child: Container(
              width: 20,
              height: 48,
              decoration: BoxDecoration(
                color: trousers,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 61,
            child: Container(
              width: 20,
              height: 48,
              decoration: BoxDecoration(
                color: trousers,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          // SHOES
          Positioned(bottom: 0, left: 52, child: _shoe()),
          Positioned(bottom: 0, right: 52, child: _shoe()),
          // ARMS
          Positioned(
            top: 76,
            left: 36,
            child: Transform.rotate(
              angle: -0.55,
              child: Container(
                width: 23,
                height: 68,
                decoration: BoxDecoration(
                  color: shirt,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          Positioned(
            top: 76,
            right: 36,
            child: Transform.rotate(
              angle: 0.55,
              child: Container(
                width: 23,
                height: 68,
                decoration: BoxDecoration(
                  color: shirt,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
          // HANDS
          Positioned(top: 128, left: 27, child: _hand(skin)),
          Positioned(top: 128, right: 27, child: _hand(skin)),
          // BODY
          Positioned(
            top: 67,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: shirt,
                borderRadius: BorderRadius.circular(23),
                boxShadow: [
                  BoxShadow(
                    color: shirt.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.favorite_rounded,
                  color: Colors.white,
                  size: 23,
                ),
              ),
            ),
          ),
          // NECK
          Positioned(
            top: 51,
            child: Container(
              width: 24,
              height: 24,
              color: skin,
            ),
          ),
          // HEAD
          Positioned(
            top: 7,
            child: Container(
              width: 73,
              height: 75,
              decoration: const BoxDecoration(
                color: skin,
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  // HAIR
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 28,
                      decoration: const BoxDecoration(
                        color: hair,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40),
                          bottomLeft: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // EYES
                  const Positioned(top: 39, left: 20, child: _Eye()),
                  const Positioned(top: 39, right: 20, child: _Eye()),
                  // SMILE
                  Positioned(
                    bottom: 11,
                    left: 29,
                    child: Container(
                      width: 17,
                      height: 8,
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF9C5147),
                            width: 2,
                          ),
                        ),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shoe() {
    return Container(
      width: 35,
      height: 15,
      decoration: BoxDecoration(
        color: const Color(0xFF302B50),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _hand(Color color) {
    return Container(
      width: 19,
      height: 19,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

// --------------------------------------------------
// CHARACTER EYE
// --------------------------------------------------

class _Eye extends StatelessWidget {
  const _Eye();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 9,
      decoration: const BoxDecoration(
        color: Color(0xFF302B50),
        shape: BoxShape.circle,
      ),
    );
  }
}