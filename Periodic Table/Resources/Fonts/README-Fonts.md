# App font: DM Mono

This app uses **DM Mono** (monospace) from [Google Fonts](https://fonts.google.com/specimen/DM+Mono). Fonts are registered in `Periodic-Table-Info.plist` under `UIAppFonts`.

## Registered faces

- **DMMono-Regular**, **DMMono-Medium**, **DMMono-Light** (and italic variants)

`AppFont` uses `DMMono-Regular` for body text and `DMMono-Medium` for headings and emphasis. If font files are missing from the target, the system will substitute a default font.

## If fonts don’t appear

- Ensure each font file is in the app target’s **Copy Bundle Resources** build phase.
- `UIAppFonts` entries must match the **exact filename** in the bundle (e.g. `DMMono-Regular.ttf` if the file has a `.ttf` extension).
