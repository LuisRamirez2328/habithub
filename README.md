# HabitHarbor — SwiftUI Habit Tracker

A native **iOS habit tracker** built with SwiftUI that helps you build streaks, one day at a time.

- **SwiftUI + Swift Charts** — dark, minimal interface with a green accent, weekly charts, streak flame, and a today-progress ring.
- **@Observable architecture** — a single observable `HabitStore` backed by Codable JSON persistence in the app sandbox.
- **Testable core** — all business logic (streaks, weekly progress, persistence) lives in the `HabitCore` Swift package, covered by XCTest unit tests.
- **CI on macOS** — `swift test` for the core plus an `xcodebuild` simulator build of the app, all in GitHub Actions.

## Project structure

```
habithub/
├── Package.swift                  # Swift package (HabitCore)
├── Sources/HabitCore/             # Pure logic, no UI:
│   ├── Habit.swift                #   model + sample data
│   ├── StreakCalculator.swift     #   streak math (calendar-injectable)
│   └── HabitStore.swift           #   @Observable store + JSON persistence
├── Tests/HabitCoreTests/          # XCTest suite
├── HabitHarbor/                   # iOS app target (SwiftUI)
│   ├── HabitHarborApp.swift
│   ├── Theme.swift
│   └── Views/                     # List, card, detail + chart, add habit
├── project.yml                    # XcodeGen spec (generates .xcodeproj)
└── .github/workflows/ci.yml       # CI: swift test + xcodebuild
```

## Requirements

- macOS with **Xcode 15+** (iOS 17 SDK) and [XcodeGen](https://github.com/yonaskolb/XcodeGen)
- Install XcodeGen once: `brew install xcodegen`

## Running the app

```bash
xcodegen generate       # creates HabitHarbor.xcodeproj
open HabitHarbor.xcodeproj
```

Select the **HabitHarbor** scheme and an iOS 17 Simulator, then press ⌘R. The app starts with four sample habits; your data is persisted to the app's sandbox.

## Running the tests

Core logic tests (no simulator needed):

```bash
swift test
```

## Features

- Create habits with a title, emoji icon, accent color and a weekly goal (1–7 days).
- Tap the checkmark to mark a habit done today; progress ring updates instantly.
- Each habit tracks its **current streak** (broken if neither today nor yesterday is done) and its **longest streak**.
- Detail view shows a Swift Charts bar chart of the last 7 days plus per-habit stats.
- Data survives relaunches via `JSONEncoder`/`JSONDecoder` (injectable storage URL for tests).
