# Pomodo

A minimal macOS menu bar app combining a Pomodoro timer and a to-do list — designed to stay out of your way while keeping you focused.

---

## What it does

Pomodo lives entirely in your menu bar. There is no dock icon, no full window — just a small timer display at the top of your screen and a compact popover when you need it.

The popover has two views you switch between with a single arrow button:

- **Timer view** — a large countdown with preset durations, a live progress bar, and the name of your current top task
- **Todo view** — a minimal task list with drag-to-reorder, Pomodoro session tracking per task, and persistent storage

---

## Features

### Timer
- Live countdown displayed directly in the menu bar, always visible
- Menu bar width adapts automatically between `mm:ss` and `hh:mm` modes
- Tap the time display to edit — just type digits, no colons needed
  - Up to 4 digits → `mm:ss` format (e.g. `2953` → `29:53`)
  - 5–6 digits → `hh mm` format (e.g. `01030` → `01h 30m`)
- Quick preset buttons: 15m, 30m, 45m
- Blinking animation while in edit mode for clear visual feedback
- Live progress bar that fills as the session runs
- Start, pause, and skip controls

### To-do list
- Add tasks with Enter or the `+` button
- Check off tasks by clicking the checkbox
- Drag tasks to reorder them
- Right-click any task to delete it
- Pomodoro dot indicators per task (up to 4 sessions shown)
- Tasks persist across app restarts using SwiftData
- The topmost incomplete task automatically appears in the timer view

---

## Tech stack

| | |
|---|---|
| Language | Swift |
| UI framework | SwiftUI |
| Persistence | SwiftData |
| Reactive logic | Combine |
| Platform | macOS 14+ |


---

## Project structure

```
FocusDo/
├── App/
│   ├── Pomodo.swift              — entry point, SwiftData container setup
│   └── AppDelegate.swift         — menu bar item, popover, timer observation
├── Models/
│   └── Task.swift                — SwiftData model with title, order, pomodoro count
├── ViewModels/
│   ├── TimerViewModel.swift      — countdown logic, edit parsing, progress
│   └── TodoViewModel.swift       — task CRUD, drag reorder
└── Views/
    ├── Color+Hex.swift           — hex color extension
    ├── ContentView.swift         — root view, tab switching
    ├── HeaderView.swift          — timer echo, navigation buttons
    ├── TimerView.swift           — countdown display, presets, progress bar
    └── TodoView.swift            — task list, input field
 
```

---

## Getting started

1. Clone the repo
2. Open `FocusDo.xcodeproj` in Xcode (macOS 14+ / Xcode 15+ required)
3. Select your Mac as the run target
4. Hit ▶

No external dependencies. No package manager setup required.

---

## Roadmap

- [ ] Notification when a session ends
- [ ] Pomodoro count auto-increments when timer completes on a task
- [ ] Settings panel (custom default duration, break duration)
- [ ] Break timer after focus session

