import 'package:flutter/material.dart';

class TasbihCounter extends StatefulWidget {
  @override
  _TasbihCounterState createState() => _TasbihCounterState();
}

class _TasbihCounterState extends State<TasbihCounter> with TickerProviderStateMixin {
  int count33 = 0;
  int count66 = 0;
  int count99 = 0;

  // Animation controller for bead movement
  late AnimationController _controller33;
  late AnimationController _controller66;
  late AnimationController _controller99;
  late Animation _animation33;
  late Animation _animation66;
  late Animation _animation99;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _controller33 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _controller66 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);
    _controller99 = AnimationController(duration: const Duration(milliseconds: 500), vsync: this);

    // Define animation
    _animation33 = Tween(begin: 0.0, end: 1.0).animate(_controller33);
    _animation66 = Tween(begin: 0.0, end: 1.0).animate(_controller66);
    _animation99 = Tween(begin: 0.0, end: 1.0).animate(_controller99);
  }

  String getQuranicVerse(int beadsCount, int count) {
    if (beadsCount == 33) {
      return count == 33
          ? "وَقُولُوا حَمْدًا لِلَّهِ وَاللَّهُ أَكْبَرُ"
          : "Say: 'Praise be to Allah, and Allah is the Greatest.'"; // Example verse
    } else if (beadsCount == 66) {
      return count == 66
          ? "سُبْحَانَ اللَّـهِ وَبِحَمْدِهِ"
          : "Glory be to Allah and praise Him.";
    } else if (beadsCount == 99) {
      return count == 99
          ? "اللَّهُ أَكْبَرُ"
          : "Allah is the Greatest.";
    }
    return "";
  }

  // Update the counter and trigger the animation
  void incrementCounter(int beadsCount) {
    setState(() {
      if (beadsCount == 33) {
        count33 = (count33 + 1) % 34;  // Reset after 33
        _controller33.forward(from: 0.0); // Trigger animation for 33
      } else if (beadsCount == 66) {
        count66 = (count66 + 1) % 67;  // Reset after 66
        _controller66.forward(from: 0.0); // Trigger animation for 66
      } else if (beadsCount == 99) {
        count99 = (count99 + 1) % 100;  // Reset after 99
        _controller99.forward(from: 0.0); // Trigger animation for 99
      }
    });
  }

  // Widget to build each bead counter with animation
  Widget buildBeadCounter(int beadsCount, int count, Animation animation, AnimationController controller) {
    return GestureDetector(
      onTap: () => incrementCounter(beadsCount),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.green.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '$count / $beadsCount Beads',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 20),

            // Beads Row with Animation
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // Horizontal scroll
                  child: Row(
                    children: List.generate(
                      count,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        margin: const EdgeInsets.symmetric(horizontal: 2.0),
                        child: Icon(
                          Icons.circle,
                          color: Colors.green.withOpacity(animation.value),
                          size: 25,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 10),

            // Remaining beads (empty circles)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Horizontal scroll
              child: Row(
                children: List.generate(
                  beadsCount - count,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Icon(
                      Icons.circle_outlined,
                      color: Colors.green.withOpacity(0.5),
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              getQuranicVerse(beadsCount, count),
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih Counter'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildBeadCounter(33, count33, _animation33, _controller33),
            buildBeadCounter(66, count66, _animation66, _controller66),
            buildBeadCounter(99, count99, _animation99, _controller99),
          ],
        ),
      ),
    );
  }
}