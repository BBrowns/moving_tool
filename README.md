# Moving Tool 🏠📦

Een complete verhuismanagement app gebouwd met **Flutter** voor web, desktop en mobiel.

## Features

- ✅ **Taken** - Beheer je verhuistaken per categorie
- 📦 **Inpakken** - Kamers, dozen en items organiseren  
- 🛒 **Inkopen** - Kanban-board voor shopping items
- 💰 **Kosten** - Uitgaven bijhouden met settlement calculator
- 📒 **Playbook** - Journal en notities
- ⚙️ **Instellingen** - Project configuratie

## Getting Started

### Vereisten

- Flutter 3.38+ ([Installatie instructies](https://flutter.dev/docs/get-started/install))

### Installatie

```bash
# Dependencies installeren
flutter pub get

# App draaien (kies je platform)
flutter run -d chrome    # Web
flutter run -d macos     # macOS
flutter run -d ios       # iOS simulator
flutter run -d android   # Android emulator
```

### Building

```bash
flutter build web       # Web build
flutter build macos     # macOS app
flutter build ios       # iOS app
flutter build apk       # Android APK
```

## Projectstructuur

```
lib/
├── core/
│   ├── router/         # GoRouter navigatie
│   └── theme/          # Material 3 theming
├── data/
│   ├── models/         # Domain models
│   ├── providers/      # Riverpod state management
│   └── services/       # Database service
└── features/
    ├── dashboard/      # Overzicht scherm
    ├── tasks/          # Taken beheer
    ├── packing/        # Dozen & kamers
    ├── shopping/       # Inkopen board
    ├── costs/          # Kosten tracker
    ├── playbook/       # Journal & notes
    ├── settings/       # Instellingen
    └── onboarding/     # Setup wizard
```

## Tech Stack

| Technologie | Doel |
|-------------|------|
| Flutter | Cross-platform UI framework |
| Riverpod | State management |
| GoRouter | Declarative routing |
| Material 3 | Design system |

## Legacy React Version

De originele React/Vite versie is beschikbaar in:
- **Branch:** `react-archive`
- **Lokaal:** `_archive/react-legacy/`

---

Built with ❤️ using Flutter
