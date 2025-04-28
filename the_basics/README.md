# the_basics

A new Flutter project.


# Project Structure Guide

```
lib/
├── data/                  # Data layer implementation
│   └── repositories/      # All repository classes - they have direct contact to firebase
│       ├── auth_repo.dart
│       └── user_repo.dart
│
├── features/              # Feature-based organization - each new feature like auth, schedules is separated into respactable dirs
│   └── X_feature/         # Example feature 
│       ├── controllers/   # Business logic
│       ├── models/        # Feature-specific models
│       ├── screens/       # Full page views
│       └── widgets/       # Reusable UI components
│
├── utils/                 # Shared utilities
│   ├── themes/            # App theming
│   └── validators/        # Validation logic
│
└── main.dart              # Application entry point
```
