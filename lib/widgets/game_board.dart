import 'package:flutter/material.dart';

class GameBoard extends StatelessWidget {
  final List<int> pits;
  final int? selectedPit;
  final int currentPlayer;
  final Function(int) onPitTap;
  final Map<int, GlobalKey> pitKeys;

  const GameBoard({
    super.key,
    required this.pits,
    required this.selectedPit,
    required this.currentPlayer,
    required this.onPitTap,
    required this.pitKeys,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF704522),
            Color(0xFF382013),
            Color(0xFF704522),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFD6A85C),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player 2: top row, pits 0–6.
          _buildRow(List.generate(7, (index) => index)),

          const SizedBox(height: 10),

          // Player 1: bottom row, pits 13–7.
          _buildRow(List.generate(7, (index) => 13 - index)),
        ],
      ),
    );
  }

  Widget _buildRow(List<int> indexes) {
    return Row(
      children: indexes.map((index) {
        final isCurrentPlayerPit = currentPlayer == 1
            ? index >= 7
            : index <= 6;

        final stoneColor = index >= 7
            ? const Color(0xFFB8860B)
            : const Color(0xFFD8D0B8);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: _buildPit(
              index,
              isCurrentPlayerPit,
              stoneColor,
              pitKeys[index]!,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPit(
    int index,
    bool isCurrentPlayerPit,
    Color stoneColor,
    GlobalKey pitKey,
  ) {
    final isSelected = selectedPit == index;

    return GestureDetector(
      onTap: isCurrentPlayerPit && pits[index] > 0
          ? () => onPitTap(index)
          : null,
      child: AspectRatio(
        key: pitKey,
        aspectRatio: 0.92,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: isSelected
                  ? [
                      const Color(0xFF805522),
                      const Color(0xFF352013),
                    ]
                  : [
                      const Color(0xFF392416),
                      const Color(0xFF160E09),
                    ],
            ),
            border: Border.all(
              color: isSelected
                  ? Colors.white
                  : const Color(0xFFB88746),
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: _buildStones(pits[index], stoneColor),
          ),
        ),
      ),
    );
  }

  Widget _buildStones(int count, Color stoneColor) {
    if (count == 0) {
      return const SizedBox.shrink();
    }

    final visibleStones = count > 16 ? 16 : count;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: List.generate(
            visibleStones,
            (index) => Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(stoneColor, Colors.white, 0.12)!,
                    Color.lerp(stoneColor, Colors.black, 0.45)!,
                  ],
                ),
                border: Border.all(
                  color: Color.lerp(
                    stoneColor,
                    Colors.black,
                    0.65,
                  )!,
                  width: 0.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (count > 16)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }
}