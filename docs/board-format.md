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
always saved as packages.

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
