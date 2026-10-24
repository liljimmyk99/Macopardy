# Creating a game from CSV

**New Game** offers two paths: build the game in the editor, or import it from a CSV file.

1. Click **Download Template** to save a CSV with the headers and a complete example game
   (same as [`csv-import-example.csv`](csv-import-example.csv)).
2. Edit it in any spreadsheet app and export it as **CSV (UTF-8)**.
3. Click **Upload CSV**. If the file is valid, click **Save and Play** to save the game as a
   `.json` board (keep it; it reopens from **Open Existing Game**) and start playing.

If anything is wrong, nothing is imported and every problem is listed with its row and
column. The game's title comes from the CSV's file name.

## Layout

One row per clue. Row 1 is the header. Columns can be in any order, headers are
case-insensitive, and extra columns (e.g. `notes`) are ignored. Header names are fixed
English identifiers and are not translated.

| Column | Required | Allowed values |
|---|---|---|
| `round` | yes | `single`, `double`, or `final` (case-insensitive) |
| `category` | yes | Category title. Rows with the same title (ignoring case) in the same round are one category. Categories appear in the order they're first used. |
| `value` | yes, except `final` | `single`: 200, 400, 600, 800, 1000. `double`: 400, 800, 1200, 1600, 2000. A leading `$` and thousands separators are allowed (`$1,000`). Leave empty for `final`. |
| `question` | yes | The clue shown to contestants. |
| `answer` | yes | The correct response. |
| `daily_double` | no | `yes`/`y`/`true`/`1`/`x`, or `no`/`n`/`false`/`0`/empty. Not allowed on `final`. |

A valid file has:

- `single` and `double` rounds with exactly **6 categories**, each with exactly **one clue per
  value** (5 clues). This matches the game editor.
- Exactly **one** `final` row.
- Any number of Daily Doubles in `single` and `double` (the editor doesn't limit them
  either; the template uses one and two).

Rows can be in any order; clues are sorted by value. Completely empty rows are skipped.

## Encoding and quoting

- UTF-8, with or without a byte-order mark. Any language works.
- Standard CSV quoting (RFC 4180): wrap a cell in `"` to include commas, line breaks, or
  quotes; write a quote inside a quoted cell as `""`. Spreadsheet apps do this for you.
- Row numbers in error messages are spreadsheet rows, so a cell with a line break still
  counts as one row.

## Not supported

- Pictures. Add them later in the editor (see [board-format.md](board-format.md)).
- Exporting an existing game to CSV.
- Partial imports, multiple sheets, or Excel/Numbers/Google Sheets files directly — export
  as CSV first.

## Code

- `Services/CSVImport/CSVParser.swift` — CSV reading and writing.
- `Services/CSVImport/CSVBoardImporter.swift` — schema, validation, conversion to `MacpardyBoard`.
- `Services/CSVImport/CSVBoardTemplate.swift` — the downloadable template.
- `Views/Control/NewGameView/NewGameView.swift` — the New Game sheet.
