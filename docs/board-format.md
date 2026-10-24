# Board file format

Boards are saved as `.macpardy` packages. A package is a zip archive:

```
board.json      { "formatVersion": 2, "boards": [ ...MacpardyBoard... ] }
images/<file>   one file per question image
```

- A question's image is referenced from `board.json` by relative path:
  `"image": { "path": "images/<question-id>.jpg" }`. Image bytes are never inlined in `board.json`.
- A package with only `board.json` (no `images/`) is valid.
- Only `images/<name>` paths are read; anything else (e.g. `../`) is ignored.
- A missing or corrupt image doesn't stop the board loading; the question screen shows a placeholder.
- Files with a `formatVersion` newer than the app supports are rejected.

## Legacy boards

Format 1 is a plain `.json` file containing `[MacpardyBoard]`. These still open from
"Open Existing Game", as does a bare `board.json` in the format 2 shape. New boards are
always saved as packages (edited boards are the exception, see below).

## Images

Set in `ImageImporter`:

| | |
|---|---|
| Accepted formats | PNG, JPEG, HEIC/HEIF, GIF (first frame), TIFF, BMP, WebP — checked from file contents |
| Max source file | 25 MB |
| Stored size | Longest side downscaled to 1920 px (smaller images are not upscaled) |
| Stored encoding | PNG if the image has transparency, otherwise JPEG at 85% quality; metadata is dropped |

One image per question, shown on the contestant question screen only (not the answer,
control, or phone buzzer screens).

## Auto-save

The auto-saved game (`Application Support/Macopardy/saved_game.json`) embeds image bytes
(base64), so resuming works even if the original board file was moved or deleted.

## Boards imported from CSV

Games imported from CSV (see [csv-import.md](csv-import.md)) are saved as a plain `.json` file
in the format 2 shape (`{ "formatVersion": 2, "boards": [...] }`), since they have no images.

## Editing an existing board

"Edit Existing Game" on the start screen opens a `.json`, `.macpardy` (or `.zip`), or `.csv`
board in the same editor as "Create Game", filled in. Loading goes through `BoardLoader`, which
picks the reader by file extension and reuses the readers above and the CSV importer.

- The editor needs one Macpardy round, one Double Macpardy round, and one Final Macpardy round
  with exactly one clue. In each of the first two rounds every category must have the same
  point values; any values are fine (the editor keeps them), not only the defaults.
- The game title is the Macpardy board's title without its " - Macpardy" suffix; if the
  board doesn't have one, the file name is used.
- A file that can't be loaded is not partly loaded. The start screen lists what's wrong:
  the field path for JSON (e.g. `boards[0].categories[2].title`), the row and column for CSV.
- Saving an edited board asks where to save it, so the original is only replaced if the user
  picks it. It's saved as plain `.json` unless a clue has a picture, in which case it's a
  `.macpardy` package. Afterwards the user can play it right away.
- Auto-saved games can't be opened for editing.
