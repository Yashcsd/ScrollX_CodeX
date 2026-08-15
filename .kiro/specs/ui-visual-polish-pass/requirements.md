# Requirements Document

## Introduction

This spec covers a precise visual polish pass on the ScrollX Flutter gaming app. The goal is to tighten the "console / plastic 3D" brand identity across all screens — Feed, Games, Leaderboard, Profile, and game screens — without touching game logic (`lib/games/**`) or icon assets. All changes must be cohesive, consistent, and must not break the existing hard solid-shadow language.

The yellow-first palette (#E4D400 primary, #FFD600 active, #B89800–#9A8A00 for hard shadows) and National Park font must be preserved. Apple design principles are used for feel only (spacing rhythm, sizing discipline, interaction polish) — not for colors or typography choices.

---

## Glossary

- **AppTheme**: The class in `lib/core/app_theme.dart` that holds all color tokens and `BoxShadow` constants.
- **GameTheme**: The helpers and tokens in `lib/core/game_theme.dart` shared across all 21 game screens.
- **YellowButton**: The shared `YellowButton` widget in `game_theme.dart` used as the primary CTA in game screens.
- **PillChip**: The shared `PillChip` widget in `lib/widgets/pill_chip.dart` used for category filter rows on Games and Leaderboard screens.
- **Hard shadow**: A `BoxShadow` with `blurRadius: 0`, no opacity, and a solid darker shade of the parent element's color. Zero blur, zero opacity, solid color only.
- **kYellow**: `Color(0xFFE4D400)` — the primary console yellow brand color.
- **kYellowDark**: `Color(0xFFB89800)` or `Color(0xFF9A8A00)` — the hard shadow color for yellow surfaces.
- **kDark**: `Color(0xFF1A1A1A)` — the primary dark/near-black used throughout.
- **consoleYellow**: `Color(0xFFFFD600)` — the active/brighter yellow for nav buttons.
- **FilterRow**: The horizontally scrollable row of `PillChip` widgets below the yellow header on the Games screen.
- **HeroCard**: The white floating card on the yellow section of the Leaderboard screen.
- **RankTile**: Each row in the leaderboard list (`_RankTile` widget).
- **ProfileHeaderCard**: The yellow-background + white-card profile header on the Profile screen.
- **EmptySection**: The empty state placeholder widget (`_EmptySection`) used inside section cards on the Profile screen.
- **GameBackgroundScreen**: Any game screen that currently uses a full-screen yellow or tinted background (e.g., Typing Speed, Number Sequence).
- **kGameGradient**: The `LinearGradient` constant in `game_theme.dart` used as atmospheric background on game screens.
- **BouncePressWidget**: The shared press-scale interaction wrapper widget.

---

## Requirements

### Requirement 1: Play Button Visual Treatment

**User Story:** As a player, I want the full-width play CTA to have a pure white background with dark text, so it stands out clearly against both dark and colored feed card backgrounds.

#### Acceptance Criteria

1. WHEN the play button (full-width CTA) is rendered on a feed card, THE Play_Button SHALL display a pure white (`#FFFFFF`) background.
2. WHEN the play button is rendered, THE Play_Button SHALL display its label text and icon in dark color (`#1A1A1A`).
3. THE Play_Button SHALL retain the existing mustard hard shadow (solid `#B89800`, zero blur, `Offset(0, 5)`).
4. THE Play_Button SHALL retain its existing pill/highly-rounded corner radius (28px).
5. WHEN the play button is pressed, THE Play_Button SHALL animate a scale-down to approximately 0.95–0.97 via `BouncePressWidget`.

---

### Requirement 2: Filter Chip Row — Remove Underline Artifact

**User Story:** As a user browsing games, I want the category filter chip row to appear clean without any border or underline below it, so the UI looks polished.

#### Acceptance Criteria

1. THE Filter_Row container on the Games screen SHALL have no bottom border, no `BoxDecoration` border, and no `Divider` widget rendered below the chip row.
2. WHILE the filter row is scrolled horizontally, THE Filter_Row SHALL maintain zero visible separator between itself and the game grid below.
3. THE Filter_Row background SHALL remain solid white (`Colors.white`) with symmetric vertical padding of 12px.

---

### Requirement 3: White Content Frame — Internal Padding and Corner Visibility

**User Story:** As a user, I want white content frames and cards to have adequate internal breathing room so content is never cramped and rounded corners are fully visible.

#### Acceptance Criteria

1. THE White_Content_Frame (any white card or sheet sitting on a colored header) SHALL apply internal padding of at least 16px on all sides, with 20–24px preferred on top, left, and right edges.
2. WHEN a white card has rounded corners, THE White_Content_Frame SHALL ensure no child content clips the corner radius.
3. THE White_Content_Frame corner radius SHALL be 18–24px for general cards, and 50px top-left + top-right only for "sheet sliding over header" layouts (see Requirement 8).

---

### Requirement 4: Selected Category Chip — White Text and Bold Weight

**User Story:** As a user, I want the selected/active category chip to show white text on yellow background with semi-bold weight, so it is immediately distinguishable from unselected chips.

#### Acceptance Criteria

1. WHEN a `PillChip` is in the active state, THE PillChip SHALL display its label text in pure white (`#FFFFFF`).
2. WHEN a `PillChip` is in the active state, THE PillChip SHALL display its label text at font weight w600–w700.
3. WHEN a `PillChip` is in the active state, THE PillChip SHALL keep its yellow background fill (`AppTheme.consoleYellow` or `kYellow`).
4. WHEN a `PillChip` is in the inactive state, THE PillChip SHALL display its label in muted dark text (`AppTheme.textSec`) on a pale neutral fill, with no change to the existing inactive appearance.
5. THE PillChip active text color change SHALL apply to every filter row in the app that uses `PillChip`, including the Games screen filter row and the Leaderboard Global/Nearby filter pills.

---

### Requirement 5: Trophy / Badge Circle Background

**User Story:** As a user viewing the empty badges state or achievement areas, I want trophy icon circles to have a pure black background so the yellow trophy icon pops with high contrast.

#### Acceptance Criteria

1. THE Trophy_Circle (the 80×80 circle container holding the 🏆 emoji on the Leaderboard empty state) SHALL have a background color of pure black (`#1A1A1A` or `Colors.black`).
2. WHEN the trophy or achievement icon is rendered inside the circle, THE Trophy_Circle icon SHALL remain yellow (no color change to the emoji or icon).
3. THE Trophy_Circle in the Profile `_EmptySection` (when `icon == Icons.emoji_events_rounded`) SHALL have a background color of pure black (`#1A1A1A`).
4. THE Trophy_Circle hard shadow SHALL remain in place (solid mustard shadow, zero blur).

---

### Requirement 6: White Sheet on Yellow Header — Top Corners Only

**User Story:** As a user viewing screens with a yellow header and white content below, I want the white card/sheet to have only top-left and top-right rounded corners (radius 50) with square bottom corners, creating a "sheet sliding up over yellow" effect.

#### Acceptance Criteria

1. WHEN a white content sheet sits directly on a yellow header background, THE White_Sheet SHALL apply `BorderRadius.only(topLeft: Radius.circular(50), topRight: Radius.circular(50))`.
2. THE White_Sheet bottom corners SHALL have zero radius (square).
3. THE White_Sheet treatment SHALL be applied consistently to: the Games screen (white filter row + content area sliding over yellow header), the Profile screen header white card, and any other screen using the yellow-header + white-content layout.
4. THE White_Sheet SHALL retain its existing white background and hard shadow.

---

### Requirement 7: Leaderboard Row Visual Treatment

**User Story:** As a user viewing the leaderboard, I want rank tiles to have a pure white background with a thin black border, and the #1 player row to have a special 3D raised bottom-only treatment, so rank hierarchy is visually clear.

#### Acceptance Criteria

1. THE RankTile container SHALL use a pure white (`#FFFFFF`) background for all rank rows.
2. THE RankTile container SHALL display a black solid border (`Color(0xFF1A1A1A)`) with a width 1px thinner than the current thickness (current is ~1.5px; target is 1px).
3. WHEN `rank == 1`, THE RankTile SHALL receive a strong bottom-only hard shadow or bottom border that creates a raised/3D-plastic feel (e.g., `BoxShadow` solid dark color, `blurRadius: 0`, `offset: Offset(0, 4)`).
4. WHEN `rank > 1`, THE RankTile SHALL NOT receive the special bottom-only 3D treatment; it SHALL keep a standard thin border only.
5. THE RankTile "You" highlighted row (isMe == true) SHALL keep its existing yellow border accent in addition to the base white background.

---

### Requirement 8: User Profile Yellow Block — Flat Avatar Square

**User Story:** As a user viewing my profile, I want the yellow avatar square to appear flat and clean without any shadow, border elevation, or box decoration noise.

#### Acceptance Criteria

1. THE Profile_Avatar (the yellow 64×64 circle or rounded square with initials in the profile header) SHALL have no `boxShadow`.
2. THE Profile_Avatar SHALL have no elevated border beyond the yellow background fill itself.
3. THE Profile_Avatar SHALL retain its yellow (`AppTheme.primary`) background color and dark initials text.

---

### Requirement 9: Game Screen Background — Black Instead of Full-Screen Yellow

**User Story:** As a player, I want game screens that currently use a full-screen yellow background to instead show a black (#1A1A1A) background, so cards, buttons, and UI chrome stand out clearly and the console aesthetic is reinforced.

#### Acceptance Criteria

1. WHEN a game screen uses a full-screen solid yellow (`kYellow` / `Color(0xFFE4D400)`) as its root scaffold or container background, THE Game_Screen SHALL replace that background with `kDark` (`Color(0xFF1A1A1A)`).
2. THE Game_Screen SHALL preserve all card, button, and UI chrome colors — only the root background behind them changes.
3. THE Game_Screen constraint SHALL apply specifically to game screens in the yellow tint family (e.g., Typing Speed, Number Sequence, and any other game whose `GameTint.deep` is in the yellow/gold family).
4. IF a game screen background is already non-yellow (teal, purple, coral, etc.), THEN THE Game_Screen SHALL leave that background unchanged.

---

### Requirement 10: Atmospheric Gradients on Game Backgrounds

**User Story:** As a player, I want game play screens with full-screen backgrounds to use a subtle multi-stop gradient as an atmospheric layer, so the experience feels modern and premium without breaking the yellow brand identity.

#### Acceptance Criteria

1. WHERE a game screen requires a full-screen or large section background gradient, THE Game_Screen SHALL use the existing `kGameGradient` constant from `game_theme.dart` or a per-game variant derived from it.
2. THE Game_Screen gradient SHALL NOT be applied to buttons, chips, or primary CTAs — gradients are for background surfaces only.
3. THE Game_Screen gradient SHALL keep the existing yellow brand color as the dominant hue; any gradient is a subtle atmospheric layer, not a replacement for brand yellow.
4. THE kGameGradient constant in `game_theme.dart` SHALL be extendable with per-game tint variants following the existing `GameTint` pattern.
5. IF a game screen background has already been changed to black per Requirement 9, THEN THE Game_Screen SHALL optionally apply a dark-to-black gradient (`Color(0xFF2A2A2A)` to `Color(0xFF1A1A1A)`) rather than the yellow gradient.

---

### Requirement 11: Spacing and Breathing Room — Global Standard

**User Story:** As a user navigating the app, I want all screens to have generous, consistent internal padding so no content ever feels cramped or clipped.

#### Acceptance Criteria

1. THE App_UI internal card padding SHALL be a minimum of 16px on all sides; preferred range is 16–24px.
2. THE App_UI corner radii SHALL follow: primary CTAs at 24–28px pill radius, cards and sheets at 18–24px, filter chips at full pill (`BorderRadius.circular(999)`), and yellow-header white sheets at 50px top corners only.
3. WHEN a scrollable content area sits within a card or sheet, THE App_UI SHALL ensure the last item has sufficient bottom padding (minimum 16px) so it is never hidden behind the bottom navigation bar.
4. THE App_UI yellow token SHALL be `AppTheme.primary` (`#E4D400`) consistently used across every screen. IF any screen hard-codes a different yellow hex value, THEN THE App_UI SHALL replace it with the `AppTheme.primary` constant.

---

### Requirement 12: Micro-Interaction Press Scale

**User Story:** As a player, I want interactive buttons and cards to give tactile feedback with a subtle scale-down on press, so the app feels responsive and physical.

#### Acceptance Criteria

1. WHEN a user presses a primary CTA button, THE Button SHALL animate a scale-down to 0.95–0.97 using `BouncePressWidget` or an equivalent `GestureDetector` + `AnimationController` approach.
2. THE BouncePressWidget scale behavior SHALL be consistent across: play buttons on feed cards, game cards in the grid, leaderboard rank tiles, and any other tappable card surface.
3. THE Button scale animation SHALL complete its full press-and-release cycle within 250ms to feel snappy rather than sluggish.

---

### Requirement 13: Token Centralization — AppTheme and GameTheme First

**User Story:** As a developer maintaining the codebase, I want all new visual constants introduced by this polish pass to be defined in `app_theme.dart` or `game_theme.dart` first, so every screen reads from shared tokens and future changes require edits in one place.

#### Acceptance Criteria

1. THE App_UI new color constants (e.g., `playButtonBg`, `chipActiveText`, `trophyCircleBg`, `sheetTopRadius`) SHALL be declared in `AppTheme` class in `lib/core/app_theme.dart` before being referenced in any screen or widget file.
2. THE GameTheme new gradient variants and per-game dark backgrounds SHALL be declared in `lib/core/game_theme.dart` before being referenced in individual game screens.
3. IF an existing screen file hard-codes a value that is now covered by a new token, THEN THE Screen SHALL be updated to reference the token rather than the literal value.
4. THE App_UI SHALL NOT introduce any new external dependencies or packages to achieve these visual changes.
