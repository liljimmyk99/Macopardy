# Features and use cases

What Macopardy does, from the point of view of the people using it. For how it's built, see
[architecture.md](architecture.md).

## Who uses it

| Person | Where | What they do |
|---|---|---|
| **Host** | Control window on their Mac | Builds or loads a game, runs it, keeps score |
| **Audience / contestants** | Display window on a TV or projector | Watch the board, clues, answers, and scores |
| **Teams (optional)** | Phone browser | Join a team, buzz in, submit Final Macpardy wagers |

A game is three rounds, like the TV show: **Macpardy** (6 categories × 5 clues),
**Double Macpardy** (6 × 5), and **Final Macpardy** (one clue). Up to 4 teams play.

## 1. Getting a game

The start screen (Control window) uses the board's look: three tiles styled like board
columns — **Play** (⌘O), **New Board** (⌘N), and **Edit Board** (⌘E). If an auto-saved game
exists, a banner below them shows its round and team count with **Resume** and **Discard**
(Discard asks first).

### Play
- Pick a `.macpardy` package or a `.json` board and play it.
- If an auto-saved game exists, the app first asks: **Resume** it, start a **New Game**
  (discards the save), or cancel.
- Double-clicking a `.macpardy` file in Finder also opens it (ignored while a game is in progress).

### New Board
A sheet with two options:
- **Build in the editor** — opens the *Create Macpardy Game* window (see §2).
- **Import from CSV** — download a template, fill it in a spreadsheet, upload it. Valid files
  are saved as a `.json` board and the game starts. Every problem is listed by row and column;
  nothing is partly imported. Details: [csv-import.md](csv-import.md).

### Edit Board
- Opens a `.json`, `.macpardy` / `.zip`, or `.csv` board in the same editor as New Game,
  pre-filled.
- A file that doesn't fit the editor (not 6 × 5, missing Final, broken JSON, …) shows a sheet
  listing each problem and where it is; the user stays on the start screen.

## 2. Building and editing a board (editor window)

- Game title, plus a title per round (blank = the round's default name).
- 6 categories × 5 clues per round with editable point values; one Final Macpardy category
  and clue.
- Per clue: clue text, correct response, **Daily Double** toggle, and an optional **picture**
  (PNG, JPEG, HEIC, GIF, TIFF, BMP, WebP; up to 25 MB, downscaled to 1920 px).
- Tiles show whether a clue is complete, incomplete, or has an image.
- **Save**: new games are always saved as a `.macpardy` package. Edited games save as `.json`,
  or `.macpardy` if any clue has a picture. After saving, the host can **Play Now**.
- When editing an existing board, closing the window or quitting the app with unsaved changes
  asks **Save… / Don't Save / Cancel**.

## 3. Running a game (Control + Display)

The Control window uses the Display's board look. Its toolbar shows the round title and
progress, a **Buzzers** button, **Show Display**, and on the board **Final Macpardy** and
**Next Round**. On the board phase the host picks clues from a copy of the Display board; Daily
Doubles (a gold **DD** badge) and clues with pictures are marked for the host only. Team scores
run along the bottom with ±100 buttons (right-click a team to reset its score).

The **Buzzers** button shows the join code and how many teams have a phone; its dot turns orange
when a phone stops responding. It opens a popover with the QR code, join code, copyable URL, and
each team's phone status with **Remove phone**. The Display window, opened with
**Show Display**, mirrors the phase full-screen with a scoreboard along the bottom.

| Phase | Host (Control) | Display |
|---|---|---|
| **Setup** | Team cards (max 4): rename, pick a color swatch, remove, **Add Team**; buzzer panel with QR code, join code, URL, and how many teams have a phone; **Start Game** | "Waiting to start game…" |
| **Board** | Pick a clue from the board; **Next Round**; show/hide the Display window | The board, played tiles blanked |
| **Daily Double** | Pick the team and wager (quick-wager buttons), **Show Question** | Daily Double splash |
| **Question** | Clue as a big tile, correct response (host only) with **Reveal Answer**, who buzzed first (or the Daily Double team and wager), 15 s timer ring (start/pause/reset/±5 s), ✓/✗ score buttons on each team card (only the Daily Double team's on a Daily Double), **Return to Board** in the toolbar | Clue (and picture, if any), timer |
| **Answer** | Same screen, answer revealed; score buttons, **Return to Board** | Correct response |
| **Final – Category** | Watch each team's wager status, enter or edit wagers, **Reveal Question** | Final category |
| **Final – Question / Answer** | Reveal answer, adjust scores, **Complete Game** | Final clue, then response |

Scoring rules the app applies:
- Each team gets **correct / wrong** buttons for the clue's value (or its Daily Double or
  Final wager). With no clue up they become ±100 / ±200 manual adjustments. Scores can be reset.
- On a normal clue, *wrong* locks that team's buzzer and re-arms the others; *correct* stops
  the buzzers. Daily Double and Final scoring never touch the buzzers.
- Final Macpardy: teams at $0 or below are excluded and wager 0. A team with no wager when the
  question is revealed bets everything.
- **Complete Game** clears the auto-save and starts a new buzzer session (new join code).

## 4. Phone buzzers (optional)

A game works without phones. When the game starts, the app serves a page on the local network.

- **Joining:** scan the QR code or open the URL, enter the 6-character code, pick a team.
  One phone per team; a claimed team's Join button is disabled for everyone else.
- **Buzzing:** the buzzer is live only while a normal clue is shown. Buzzing early shows a
  "too early" message. On a Daily Double the button can't be pressed.
- **First buzz:** the first buzz the Mac receives wins; buzzes within ~75 ms count as a tie,
  won by the lower score (equal scores: random).
- **Wrong answer:** that team is locked out for the rest of the clue; the others can buzz again.
- **Final Macpardy:** while the category is shown, each eligible phone gets a wager screen
  with its max (its score). Only the first submission counts; after that only the host can
  change it. Excluded teams are told they can't win points.
- **Connection:** a phone that stops answering for 5 s counts as disconnected; the Control
  and Display windows flag the team. The host can remove a team's phone (team and score kept)
  and the phone can rejoin.
- Abuse limits: wrong join codes and claim attempts are rate limited per address.

Wire details: [buzzer-protocol.md](buzzer-protocol.md).

## 5. Saving and resuming

- Once play starts, every game action auto-saves (debounced 300 ms) to `saved_game.json` in
  the app's Application Support folder (sandboxed:
  `~/Library/Containers/jbkiv.Macopardy/Data/Library/Application Support/Macopardy/`).
  Pictures are embedded, so a crash or quit can be resumed from **Play** even if
  the board file moved.
- Resuming starts a new buzzer session; phones drop and rejoin with the new code.
- A save that's corrupt or from a different schema version is discarded, not migrated.

## 6. Sharing the app

`scripts/export.sh` builds an ad-hoc signed `.app` and `.dmg` for trusted sharing (not
notarized). See [EXPORTING.md](../EXPORTING.md).

## Not built yet

Open issues at the time of writing: sounds (#27), animations (#25), and a fix for the control
panel question picker (#26). Also out of scope today: exporting a game to CSV, round titles in
CSV, and contestants submitting written Final answers from their phones.
