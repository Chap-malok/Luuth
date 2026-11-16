import 'package:flutter/material.dart';
import 'screens/game_screen.dart';

void main() {
  runApp(const LuuthApp());
}

class LuuthApp extends StatelessWidget {
  const LuuthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luuth',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF17130F),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF302217),
              Color(0xFF17130F),
              Color(0xFF0D0B09),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 35),

                const Text(
                  'LUUTH',
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                    color: Color(0xFFD6A65B),
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'THE HERITAGE STRATEGY GAME',
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 3,
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 55),

                const Text(
                  'Welcome to Luuth',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                const Text(
                  'Experience a traditional South Sudanese '
                  'strategy game in a modern world.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white70,
                    height: 1.6,
                  ),
                ),

                const SizedBox(height: 35),

                // NEW GAME BUTTON

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD6A65B),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GameScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'NEW GAME',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 35),

                const Text(
                  'GAME MODES',
                  style: TextStyle(
                    color: Color(0xFFD6A65B),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 18),

                _buildModeCard(
                  icon: Icons.people_alt_outlined,
                  title: 'Local Multiplayer',
                  subtitle: 'Play with a friend on one device',
                ),

                const SizedBox(height: 14),

                _buildModeCard(
                  icon: Icons.smart_toy_outlined,
                  title: 'Play Against AI',
                  subtitle: 'Challenge the computer',
                ),

                const SizedBox(height: 14),

                _buildModeCard(
                  icon: Icons.public,
                  title: 'Online Multiplayer',
                  subtitle: 'Coming in a future update',
                ),

                const SizedBox(height: 35),

                const Text(
                  'PRESERVING HERITAGE THROUGH TECHNOLOGY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9,
                    letterSpacing: 1.5,
                    color: Colors.white38,
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF292019),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF6F5435),
          width: 0.7,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFD6A65B),
            size: 30,
          ),

          const SizedBox(width: 17),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios,
            color: Color(0xFFD6A65B),
            size: 16,
          ),
        ],
      ),
    );
  }
}