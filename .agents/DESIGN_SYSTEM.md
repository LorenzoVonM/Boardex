# Design System

## Framework

Always `useMaterial3: true` in `ThemeData`. No Material 2 APIs.

## Color Tokens

**All colors must be referenced via `AppColors` (`lib/utils/theme_utils.dart`). Never use inline hex literals, `Color(0xFF...)` constructors, or named CSS colors anywhere in the UI.** If a color you need does not have a token yet, add it to `AppColors` first, then reference it. This keeps every color in the app traceable to a single source of truth.

### Brand Palette
| Token | Hex | Use |
|---|---|---|
| `AppColors.headerCoral` | `#F88379` | Screen titles, primary headers |
| `AppColors.brandTeal` | `#2C9FAF` | Brand accents, metric icons |
| `AppColors.brandBlue` | `#305A8C` | Brand accents |
| `AppColors.brandPeach` | `#FFB7A3` | Soft brand highlights |
| `AppColors.brandRose` | `#E85D75` | Strong accents |

### Match Result Colors
| Token | Hex | Outcome |
|---|---|---|
| `AppColors.resultWon` | `#2EAF61` | Win |
| `AppColors.resultTie` | `#4F8EE8` | Draw |
| `AppColors.resultLost` | `#D1495B` | Loss |

Never refer to outcomes as "Win/Lose" — use **Win / Draw / Loss**.

### Other Semantic Tokens
- Weight difficulty: `weightEasy`, `weightMedium`, `weightHard`, `weightExtreme`
- Rating: `ratingUnrated`, `ratingLow`, `ratingFair`, `ratingHigh`
- Marketplace: `sellGreen*`, `tradeBlue*`
- Ownership: `ownedTeal*`, `notOwnedSlate*`

## Match Result Tags

Use `buildMatchResultTag()` for any Win/Draw/Loss badge. Do not build a custom badge from scratch.

```dart
buildMatchResultTag(match.result)                          // compact (default)
buildMatchResultTag(match.result, size: MatchResultTagSize.regular)
buildMatchResultTag(match.result, uppercase: true)
```

The `MatchResultUi` extension on `MatchResult` provides `.color`, `.icon`, and `.label` for custom rendering when the tag widget isn't suitable.

## Utility Color Functions

```dart
Color c = getWeightColor(game.weight);   // 0.0–5.0 range
Color c = getRatingColor(game.rating);   // 0.0–10.0 range
```

## Responsive Layout

Use `LayoutBuilder` and `MediaQuery` for any layout that adapts to screen width. Avoid fixed pixel widths for containers that must work on both mobile and desktop (macOS target exists).
