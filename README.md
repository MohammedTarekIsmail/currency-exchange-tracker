# Currency Exchange Tracker

A Flutter app showing live exchange rates for USD, EUR, GBP, SAR, and JPY against the Egyptian
Pound (EGP), with historical charts and offline support.

## Features

- **Exchange Rates List** — live rates for 5 currencies against EGP, with daily change (
  color-coded), pull-to-refresh, and loading/error/empty states.
- **Currency Detail** — tap any currency to see its current rate, daily change, and a 7-day
  historical line chart.
- **Offline Support** — cached rates are shown when there's no internet connection, with a "last
  updated" indicator. The app auto-refreshes when connectivity returns.

## Architecture

Built with Clean Architecture (domain / data / presentation layers) and BLoC for state management.

```
lib/
  core/                    # shared error types, network utilities, theming
  features/
    exchange_rates/
      domain/              # entities, repository interfaces, use cases
      data/                # models, remote/local data sources, repository impl
      presentation/
        bloc/              # BLoCs, events, states
        screens/           # top-level screens
        widgets/           # reusable UI components
```

## Getting Started

1. Clone the repo
2. Install dependencies:

```bash
   flutter pub get
```

3. Run the app:

```bash
   flutter run
```

## Running Tests

```bash
flutter test
```

## Tech Stack

- **State management:** flutter_bloc
- **Networking:** dio
- **Local storage:** shared_preferences
- **Charts:** fl_chart
- **DI:** get_it
- **Testing:** mocktail, bloc_test

## API

Uses the free, open [Currency Exchange Rates API](https://github.com/fawazahmed0/exchange-api) — no
API key required.