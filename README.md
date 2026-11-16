# LUUTH

### Preserving Traditional Games Through Technology

**Luuth** is a mobile game project inspired by a traditional board game played in Nuer and Dinka communities in South Sudan. The project aims to bring this traditional game to mobile devices while preserving its gameplay mechanics and cultural identity.

The application is being developed with Flutter and Dart, with Android as the initial target platform and iOS planned for a future release.

---

## Project Status

**Status:** Active Development  
**Platform:** Android (initial target), iOS (planned)  
**Framework:** Flutter  
**Programming Language:** Dart

Luuth is currently under development. Features and gameplay mechanics are being implemented and tested.

## Game Overview

Luuth uses a board consisting of two rows of seven pits, giving a total of fourteen pits.

### Initial Board Setup

- 14 pits in total.
- 7 pits assigned to each player.
- Each pit starts with 4 stones.
- Total starting stones: 56.
- Each player controls one row of seven pits.

### Gameplay Mechanics

The currently documented gameplay rules include:

1. **Pit Selection:** A player selects a pit from their own side of the board.
2. **Sowing:** Stones are distributed one at a time into subsequent pits.
3. **Movement Direction:** Stones move anticlockwise around the board.
4. **Relay Sowing:** If the last stone lands in a non-empty pit, the player collects all stones from that pit and continues sowing.
5. **Turn Completion:** If the last stone lands in an empty pit, the turn ends.

Additional capture, scoring, and winning rules will be documented as they are finalized.

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform mobile development |
| Dart | Application programming language |
| Android Studio | Android development environment |
| Visual Studio Code | Code editing and development |
| Git | Version control |

## Project Structure

The application is organized into separate components to make development and maintenance easier.

```text
luuth/
├── android/
├── assets/
│   └── audio/
├── lib/
│   ├── game/
│   │   ├── game_engine.dart
│   │   └── game_state.dart
│   ├── screens/
│   │   └── game_screen.dart
│   ├── widgets/
│   │   └── game_board.dart
│   └── main.dart
├── test/
├── pubspec.yaml
└── README.md
```

## Getting Started

### Prerequisites

Before running the project, install:

- Flutter SDK
- Dart SDK (included with Flutter)
- Android Studio
- Visual Studio Code
- Android Emulator or a physical Android device

### Installation

Clone the repository:

```bash
git clone https://github.com/Chap-malok/Luuth.git
```

Navigate into the project directory:

```bash
cd luuth
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

## Development Roadmap

Planned development activities include:

- [x] Establish the Flutter project.
- [x] Create the initial 14-pit board structure.
- [x] Implement the initial stone distribution.
- [x] Implement basic sowing mechanics.
- [x] Implement relay sowing mechanics.
- [ ] Complete stone movement animations.
- [ ] Improve gameplay sound effects.
- [ ] Finalize capture and scoring rules.
- [ ] Implement game completion and winning conditions.
- [ ] Add multiplayer functionality.
- [ ] Conduct gameplay testing.
- [ ] Prepare the first Android release.
- [ ] Plan the iOS release.

*The checklist reflects development progress and will be updated as features are tested and completed.*

## Cultural Background

Luuth is inspired by a traditional game associated with Nuer and Dinka communities in South Sudan.

This project seeks to contribute to the preservation and digital representation of traditional games by making them accessible to a wider audience through mobile technology.

## License

A project license has not yet been selected.