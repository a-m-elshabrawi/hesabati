# Hesabati

A Flutter dashboard that puts accounts from several banks on one screen: current accounts,
credit cards, children's cards, transfers between them, and conversion across 150+
currencies from a dated rate snapshot. Built in English and Arabic with full right-to-left
support.

**Status** Work in progress. Demo application: runs entirely on mock data, no banking backend
**Built** August 2025
**Recognition** Best Idea Award, recognised by CODED and Boursa Kuwait

## Why this exists

Anyone in Kuwait with accounts at more than one bank has more than one banking app, and
none of them will tell you your total. The question "how much money do I actually have"
requires opening three apps and doing arithmetic. Aggregation is the product.

The child card feature came from the same place. Parents hand a card to a teenager and then
have no way to set a limit or see what it was spent on without asking.

This was the final project for CODED Academy's UniCode Program, which is where the
constraints below come from.

## What this is and is not

Read this before anything else, because the screenshots are misleading if you do not.

**It is not connected to any bank.** There is no backend, no API, no real money. Every
account, balance and transaction is mock data defined in the app.

**The login screen does not authenticate.** It accepts the demo credentials and navigates
onwards. Registration creates a clean in-memory state. There is no user store.

**The biometric and two-factor prompts are animations.** They play a convincing sequence
and then continue. No platform biometric API is called. They exist to demonstrate the
intended flow.

**Exchange rates are a snapshot, not a feed.** 150+ rates were captured to JSON in October
2025 and ship with the app. Conversion arithmetic against that snapshot is real and
correct. The rates themselves are frozen and will drift further from reality every day.

What is real: the entire Flutter application. State management, navigation, the
localisation and RTL layout system, the theming, the FX conversion engine with its ISO 4217
metadata, form validation, and the spending analytics computed from the mock transactions.

Anyone assessing this should read it as an interface and architecture exercise, which is
what it was scoped as. Connecting a real banking backend in Kuwait is a licensing problem,
not an engineering one.

## Stack and rationale

| Layer | Choice | Why |
|---|---|---|
| Framework | Flutter, Dart 3.2.3+ | One codebase for iOS and Android, and the programme was a Flutter track |
| State | Provider with a central `AppState` | The whole app is one user's financial state. A single `ChangeNotifier` with `Consumer` widgets is proportionate. Bloc would have been ceremony at this size |
| Design | Material Design 3 | RTL support is built into the framework's layout widgets, which is most of the Arabic problem solved before I start |
| i18n | `flutter_localizations` with a custom string layer | Two languages and a fixed string set. The generated ARB toolchain was more machinery than the problem needed |
| Formatting | `intl` | Locale-aware number and date formatting, which is not optional once you have Arabic |
| FX data | Static JSON snapshot with ISO 4217 metadata | A live rates API needs a key and a paid tier. A dated snapshot is honest and costs nothing |
| Icons | `flutter_launcher_icons` | Generates the full icon set for every target platform from one source image |

## Design decisions

1. **Right-to-left is a layout property, not a translation.** Arabic is not English with
   different words. Rows reverse, icons that imply direction flip, and number formatting
   changes. Expressing layout in terms of the start and end of the reading order, rather
   than the left and right of the screen, meant one layout follows the locale instead of
   needing a parallel Arabic UI.

2. **All rates are stored against KWD as the base.** Every pair is derived by going through
   the dinar rather than storing a full matrix. 150 currencies as a matrix is 22,500 entries
   that can disagree with each other; as a base plus 150 rates it cannot become internally
   inconsistent.

3. **ISO 4217 metadata is kept separately from the rates.** Currency codes carry a
   minor-unit count, and it is not always two. KWD has three decimal places, JPY has none.
   Formatting a dinar amount to two places is wrong, and it is wrong in the local currency
   of the intended user, which is the worst place to get it wrong.

4. **FX is a self-contained feature module.** `features/fx_snapshot/` has its own
   `data`, `domain`, `ui` and `util` directories. It is the one part of the app with real
   logic worth isolating, and the only part that would survive being lifted into another
   project.

5. **The simulated biometric flow is deliberately obvious in the code.** It is named as a
   simulation rather than dressed up as an integration, because a reader should not have to
   discover that by tracing it.

6. **Deleting the last account is blocked.** An app whose entire premise is aggregation
   makes no sense with zero accounts, and the empty state would be a bug report.

## How currency conversion works

In `features/fx_snapshot/`:

1. `data/snapshot_loader.dart` reads the bundled JSON of rates against KWD and their
   capture timestamp.
2. `data/iso4217_meta.dart` supplies each currency's symbol, name and minor-unit count.
3. `domain/converter.dart` performs the conversion against the KWD-based rates, so any pair
   is derived through the dinar rather than from a stored direct pair.
4. `util/formatting.dart` renders the result using the target currency's own minor units,
   which is why a dinar amount and a yen amount do not show the same number of decimals.
5. Missing rates and invalid input are handled rather than thrown.

The capture timestamp is surfaced in the UI, so a user can see the rates are from a
specific date rather than assuming they are current.

## Project structure

```
lib/
  constants/            Colours, strings, theme
  features/
    fx_snapshot/        The one properly layered feature
      data/             snapshot_loader.dart, iso4217_meta.dart
      domain/           converter.dart, models.dart
      ui/               currency_picker.dart, currency_rates_screen.dart
      util/             formatting.dart
  models/               Account and Transaction
  providers/
    app_state.dart      Single source of truth for the whole app
  screens/              One file per screen, 15 of them
  widgets/              Reusable cards, currency text, bank logos, drawer
```

## Known limitations

**Everything lives in one `AppState`.** It works at this size and it is the obvious first
target for a refactor, split by domain.

**The architecture is inconsistent.** The FX feature is properly layered into data, domain
and UI. The rest of the app is organised by widget type, with logic sitting in screens.
`features/fx_snapshot/` is the pattern the rest of the app should follow.

**There is no persistence.** Closing the app resets it. State lives in memory and nothing
writes to disk, so a "registered" user is gone on restart.

**Rates cannot be refreshed.** Replacing the snapshot means rebuilding the app. There is no
mechanism for updating rates without a release.

## Running it locally

Requires the Flutter SDK 3.2.3 or higher.

```bash
git clone https://github.com/a-m-elshabrawi/hesabati.git
cd hesabati
flutter pub get
flutter run
```

Sign in with `user@example.com` and `password123`, or register to start from an empty
state. The seeded demo account has five accounts, two of which are child cards, and seven
transactions.

To generate the app icons after changing the source image:

```bash
flutter pub run flutter_launcher_icons
```

## AI usage disclosure

AI coding tools were used during the development of this project. All generated code was
reviewed before use.

The shipped application does not call any model at runtime. All AI-related UI in the app is
simulated, as described above.

## Licence

For educational purposes. All data is mock data and no financial transactions are
processed.
