# Sounds

The Control window plays sound effects and board music through the host's Mac. The Display
window and the phones are silent.

| Sound | File | When it plays |
|---|---|---|
| Wrong answer | `incorrect` | A team is marked wrong (clue, Daily Double, or Final) |
| Timer running out | `timer_warning` | The last 5 seconds of the clue timer; ticks speed up and end with a tone at zero |
| Daily Double | `daily_double` | The game enters the Daily Double phase |
| Final Macpardy | `final_macpardy` | The Final Macpardy category is revealed |
| Background music | `background_music` | Looping, quietly, while the board is showing |

The timer warning stops when the timer is paused or reset or the phase changes. Pausing and
resuming inside the last 5 seconds picks the ticks up at the matching point.

## Settings

The toolbar's **Sound** menu and **Settings > Sound** (⌘,) have the same two switches, *Sound
Effects* and *Background Music*. Both are on by default and are remembered between launches
(`UserDefaults`). Both screens bind straight to `SoundPlayer.shared` (not `@AppStorage`, since
the player caches its values), so they always agree.

## Files

`Macpardy/Resources/Sounds/*.wav` are synthesized placeholders (generated from sine and saw
waves, so nothing to license), not recordings.

To use your own recording, replace the file with one of the same name and format (`.wav`).
No code changes are needed. The file names are the raw values of `SoundEffect`.

## Code

- `Services/Sound/SoundEffect.swift` — the sounds, and `SoundCue` (what each game phase triggers).
- `Services/Sound/SoundPlayer.swift` — `SoundPlayer.shared`, plus the two switches.
- `MacpardyApp` forwards phase changes to `SoundPlayer.handle(phase:)`; `GameTimer` starts the
  warning; the score buttons play the wrong-answer sound.
- Sound uses no new entitlements.
