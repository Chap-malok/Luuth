import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

import '../game/game_state.dart';
import '../game/game_engine.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late GameState gameState;

  int? selectedPit;
  bool isAnimating = false;

  // Audio players.
  late final AudioPlayer movementAudioPlayer;
  late final AudioPlayer landingAudioPlayer;

  final Map<int, GlobalKey> pitKeys = {
    for (int i = 0; i < 14; i++) i: GlobalKey(),
  };

  final GlobalKey animationLayerKey = GlobalKey();

  late AnimationController stoneController;
  late AnimationController landingController;

  Offset stoneStart = Offset.zero;
  Offset stoneEnd = Offset.zero;

  bool showMovingStone = false;

  // Landing bounce properties.
  bool showLandingBounce = false;
  Offset landingPosition = Offset.zero;

  // Relay pickup animation properties.
  bool showRelayPickup = false;
  Offset relayPickupPosition = Offset.zero;
  int relayPickupCount = 0;

  @override
  void initState() {
    super.initState();

    gameState = GameState.initial();

    // Create separate players so movement and landing
    // sounds do not interfere with each other.
    movementAudioPlayer = AudioPlayer();
    landingAudioPlayer = AudioPlayer();

    stoneController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    landingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  // Play the stone movement sound.
  Future<void> _playMovementSound() async {
    try {
      await movementAudioPlayer.stop();

      await movementAudioPlayer.play(
        AssetSource('audio/stone_move.wav'),
      );
    } catch (_) {
      // Sound errors should never interrupt gameplay.
    }
  }

  // Play the stone landing sound.
  Future<void> _playLandingSound() async {
    try {
      await landingAudioPlayer.stop();

      await landingAudioPlayer.play(
        AssetSource('audio/stone_land.wav'),
      );
    } catch (_) {
      // Sound errors should never interrupt gameplay.
    }
  }

  @override
  void dispose() {
    stoneController.dispose();
    landingController.dispose();

    unawaited(movementAudioPlayer.dispose());
    unawaited(landingAudioPlayer.dispose());

    super.dispose();
  }

  // Find the centre of a pit relative to the animation layer.
  Offset? getPitPosition(int pitIndex) {
    final pitContext = pitKeys[pitIndex]?.currentContext;
    final layerContext = animationLayerKey.currentContext;

    if (pitContext == null || layerContext == null) {
      return null;
    }

    final pitObject = pitContext.findRenderObject();
    final layerObject = layerContext.findRenderObject();

    if (pitObject is! RenderBox || layerObject is! RenderBox) {
      return null;
    }

    final pitCenter = pitObject.localToGlobal(
      pitObject.size.center(Offset.zero),
    );

    return layerObject.globalToLocal(pitCenter);
  }

  // Animate one stone between two pits, then bounce on landing.
  Future<void> animateStone(int fromPit, int toPit) async {
    final start = getPitPosition(fromPit);
    final end = getPitPosition(toPit);

    if (start == null || end == null) {
      return;
    }

    stoneController.reset();

    setState(() {
      stoneStart = start;
      stoneEnd = end;
      showMovingStone = true;
      showLandingBounce = false;
    });

    // Play the movement sound as the stone travels.
    unawaited(_playMovementSound());

    // First: move the stone to the destination.
    await stoneController.forward();

    if (!mounted) return;

    // Play the landing sound when the stone arrives.
    unawaited(_playLandingSound());

    setState(() {
      showMovingStone = false;
      landingPosition = end;
      showLandingBounce = true;
    });

    // Second: perform the small landing bounce.
    landingController.reset();
    await landingController.forward();

    if (!mounted) return;

    setState(() {
      showLandingBounce = false;
    });
  }

  // Animate all stones being picked up from a relay pit.
  Future<void> animateRelayPickup(
    int pitIndex,
    int stonesCount,
  ) async {
    final position = getPitPosition(pitIndex);

    if (position == null) {
      return;
    }

    stoneController.reset();

    setState(() {
      relayPickupPosition = position;
      relayPickupCount = stonesCount;
      showRelayPickup = true;
    });

    await stoneController.forward();

    if (!mounted) return;

    setState(() {
      showRelayPickup = false;
    });
  }

  // Process all movement events produced by the game engine.
  Future<void> handlePitTap(int index) async {
    if (isAnimating) return;

    final result = GameEngine.playMove(gameState, index);

    if (!result.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.error ?? 'Invalid move.'),
          duration: const Duration(seconds: 2),
        ),
      );

      return;
    }

    setState(() {
      isAnimating = true;
      selectedPit = index;
    });

    await WidgetsBinding.instance.endOfFrame;

    for (final event in result.events) {
      if (!mounted) return;

      switch (event.type) {
        case LuuthMoveEventType.initialPickup:
          setState(() {
            gameState = GameState(
              pits: List<int>.from(event.boardState),
              currentPlayer: gameState.currentPlayer,
            );
          });

          await Future.delayed(
            const Duration(milliseconds: 120),
          );

          break;

        case LuuthMoveEventType.stoneMovement:
          if (event.fromPit != null && event.toPit != null) {
            await animateStone(
              event.fromPit!,
              event.toPit!,
            );
          }

          if (!mounted) return;

          // Update the destination after the landing bounce.
          setState(() {
            gameState = GameState(
              pits: List<int>.from(event.boardState),
              currentPlayer: gameState.currentPlayer,
            );
          });

          await Future.delayed(
            const Duration(milliseconds: 50),
          );

          break;

        case LuuthMoveEventType.relayPickup:
          if (event.pitIndex != null) {
            await animateRelayPickup(
              event.pitIndex!,
              event.stonesInHand,
            );
          }

          if (!mounted) return;

          setState(() {
            gameState = GameState(
              pits: List<int>.from(event.boardState),
              currentPlayer: gameState.currentPlayer,
            );
          });

          await Future.delayed(
            const Duration(milliseconds: 100),
          );

          break;
      }
    }

    if (!mounted) return;

    setState(() {
      gameState = result.state!;
      selectedPit = null;
      isAnimating = false;
      showMovingStone = false;
      showLandingBounce = false;
      showRelayPickup = false;
    });
  }

  void restartGame() {
    if (isAnimating) return;

    setState(() {
      gameState = GameState.initial();
      selectedPit = null;
      showMovingStone = false;
      showLandingBounce = false;
      showRelayPickup = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final player1Turn =
        gameState.currentPlayer == LuuthPlayer.player1;

    return Scaffold(
      backgroundColor: const Color(0xFF17130F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17130F),
        foregroundColor: const Color(0xFFD6A85C),
        title: const Text('LUUTH'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: restartGame,
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart game',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildPlayerInfo(
                'PLAYER 2',
                gameState.stonesOnSide(LuuthPlayer.player2),
                !player1Turn,
              ),

              const SizedBox(height: 24),

              Stack(
                key: animationLayerKey,
                clipBehavior: Clip.none,
                children: [
                  GameBoard(
                    pits: gameState.pits,
                    selectedPit: selectedPit,
                    currentPlayer: player1Turn ? 1 : 2,
                    onPitTap: handlePitTap,
                    pitKeys: pitKeys,
                  ),

                  // Moving stone with rotation and arc movement.
                  if (showMovingStone)
                    AnimatedBuilder(
                      animation: stoneController,
                      builder: (context, child) {
                        final t = Curves.easeInOutCubic.transform(
                          stoneController.value,
                        );

                        final position = Offset.lerp(
                          stoneStart,
                          stoneEnd,
                          t,
                        )!;

                        final arcHeight = 28 * 4 * t * (1 - t);

                        final animatedPosition = Offset(
                          position.dx,
                          position.dy - arcHeight,
                        );

                        final rotation =
                            0.35 * math.sin(math.pi * t);

                        final scale =
                            1 + (0.08 * math.sin(math.pi * t));

                        return Positioned(
                          left: animatedPosition.dx - 6,
                          top: animatedPosition.dy - 6,
                          child: Transform.rotate(
                            angle: rotation,
                            child: Transform.scale(
                              scale: scale,
                              child: child!,
                            ),
                          ),
                        );
                      },
                      child: _buildMovingStone(),
                    ),

                  // Landing bounce effect.
                  if (showLandingBounce)
                    AnimatedBuilder(
                      animation: landingController,
                      builder: (context, child) {
                        final t = landingController.value;

                        final bounceHeight =
                            9 *
                            math.sin(t * math.pi * 2) *
                            (1 - t);

                        final scale =
                            1 + (0.18 * math.sin(math.pi * t));

                        return Positioned(
                          left: landingPosition.dx - 6,
                          top: landingPosition.dy -
                              6 -
                              bounceHeight,
                          child: Transform.scale(
                            scale: scale,
                            child: child!,
                          ),
                        );
                      },
                      child: _buildMovingStone(),
                    ),

                  // Stones rising out of a relay pit.
                  if (showRelayPickup)
                    AnimatedBuilder(
                      animation: stoneController,
                      builder: (context, child) {
                        final t = Curves.easeOutCubic.transform(
                          stoneController.value,
                        );

                        final upwardMovement = 35 * t;

                        return Positioned(
                          left: relayPickupPosition.dx - 20,
                          top: relayPickupPosition.dy -
                              20 -
                              upwardMovement,
                          child: Opacity(
                            opacity: 1 - t,
                            child: Transform.scale(
                              scale: 1 + (0.3 * t),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: _buildRelayPickupStones(),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              _buildPlayerInfo(
                'PLAYER 1',
                gameState.stonesOnSide(LuuthPlayer.player1),
                player1Turn,
              ),

              const SizedBox(height: 22),

              Text(
                player1Turn
                    ? 'PLAYER 1 — YOUR TURN'
                    : 'PLAYER 2 — YOUR TURN',
                style: const TextStyle(
                  color: Color(0xFFD6A85C),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Select a pit on your side to play.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Appearance of an individual moving square stone.
  Widget _buildMovingStone() {
    final stoneColor =
        gameState.currentPlayer == LuuthPlayer.player1
            ? const Color(0xFFB8860B)
            : const Color(0xFFD8D0B8);

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(stoneColor, Colors.white, 0.2)!,
            Color.lerp(stoneColor, Colors.black, 0.4)!,
          ],
        ),
        border: Border.all(
          color: Color.lerp(stoneColor, Colors.black, 0.6)!,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 5,
            offset: const Offset(1, 2),
          ),
        ],
      ),
    );
  }

  // Visual cluster of stones picked up during relay sowing.
  Widget _buildRelayPickupStones() {
    final stoneColor =
        gameState.currentPlayer == LuuthPlayer.player1
            ? const Color(0xFFB8860B)
            : const Color(0xFFD8D0B8);

    final visibleCount =
        relayPickupCount > 9 ? 9 : relayPickupCount;

    return SizedBox(
      width: 40,
      height: 40,
      child: Wrap(
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        spacing: 3,
        runSpacing: 3,
        children: List.generate(
          visibleCount,
          (index) {
            return Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(stoneColor, Colors.white, 0.2)!,
                    Color.lerp(stoneColor, Colors.black, 0.4)!,
                  ],
                ),
                border: Border.all(
                  color: Color.lerp(stoneColor, Colors.black, 0.6)!,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPlayerInfo(
    String name,
    int stones,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFF3B2113)
            : const Color(0xFF21140D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive
              ? const Color(0xFFD6A85C)
              : Colors.white12,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFFD6A85C)
                  : Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '$stones Stones',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
