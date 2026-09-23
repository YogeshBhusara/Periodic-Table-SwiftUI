# Periodic Table

A native **SwiftUI** iOS app for exploring chemical elements in a **dark widget interface**—near-black canvas, stippled display numbers, atmospheric category cards, and a yellow signal accent.

---

## What this app is

Periodic Table is a **learning and reference** companion for the elements: browse by category, open rich detail sheets, compare properties side by side, and test yourself with a quiz. The UI is **information-dense by design** (atomic numbers, symbols, configurations, discovery history) but presented as **stacked widget cards** so exploration feels like a polished product—not a static textbook.

---

## Why this app exists

- **Education** – The periodic table is foundational to chemistry; the app makes it **quick to explore** patterns (groups, periods, metals vs non-metals) without hunting through paper charts or generic websites.
- **Retention & curiosity** – Short quiz modes, comparisons, and **visual hooks** (orbital diagrams, 3D Bohr models where data exists) support **active learning** rather than passive reading.
- **Delight on purpose** – Science apps often default to utilitarian UIs. Here, **atmospheric category meshes**, **stippled numerals**, and **spring-based motion** are intentional: they reward exploration and keep the experience **memorable** on a device people use every day.

---

## Visual language

The app stays in **dark mode**. Color lives inside the cards. The canvas stays near-black.

| Where it shows up | Role |
|-------------------|------|
| **Canvas** | Near-black background, fine **dot grid**, and a soft **category glow** behind the content. |
| **Element cards & detail** | **Atmospheric meshes** (deep edge, saturated middle, bright glow) with a light top edge and a colored shadow. |
| **Hero numbers** | Atomic numbers are **stippled display numerals**. Small tracked labels sit above them. |
| **Signal accent** | A yellow waveform runs through hero cards. Primary actions use the same **yellow pill**. |
| **Learn, quiz, menu** | Elevated dark panels on the same canvas so secondary screens match the carousel. |

---

## Complex UI & animations

Animations are used to **orient the user**, **connect related UI**, and **avoid jarring jumps** when data or selection changes—not only for decoration.

| Technique | What it does in the app |
|-----------|-------------------------|
| **Matched geometry / namespace** | Card → detail transitions share identity where possible so the interface feels like **one continuous surface** opening into depth. |
| **Spring curves (e.g. “Spotify-style”)** | Carousel and overlay motion use **tuned springs** (response + damping) for **smooth, non-bouncy** movement that still feels alive. |
| **Sheet presentation** | Custom animation on the detail sheet pairs with **presentation detents** so expand/collapse feels **linked** to the card metaphor. |
| **Parallax & background motion** | A large stippled atomic number sits behind the carousel and shifts at a different rate than the card. |
| **Orbital & canvas** | Timeline-driven **Canvas** drawing animates electron shells; **3D Bohr** views use WebKit + Three.js for interactive models when URLs are available. |
| **Filters & state** | Filter and search updates are wrapped in **easing** so lists and carousels don’t snap disorientingly. |

Together, these choices keep the app **responsive** under load (lazy patterns, intentional grouping) while the **motion language** stays consistent: **springs for spatial transitions**, **ease for content fades**, and a slow **signal waveform** on hero cards.

---

## Features (overview)

| Area | Highlights |
|------|------------|
| **Elements** | **Page-style carousel** of element cards; category colors; large ambient atomic number; **3D Bohr** strip when a model URL exists; tap to open **detail sheet**. |
| **Learn** | **Property comparator** for side-by-side values; **Quiz** with multiple modes (random, category, property), streaks, and hints. |
| **Detail** | Description, electron configuration, oxidation states, history, fun facts, **related elements**, pronunciation (speech), share. |
| **Menu** | **Favorites**, **Settings**, filters (category, mass, electronegativity, search, favorites-only). |

---

## Architecture & stack

- **SwiftUI** first, **MVVM-style** state: `ElementDataStore`, `UIStateManager`, `QuizManager` as observable sources; views stay declarative.
- **Protocol-oriented** models (`ElementCard`, categories) and **async** data loading where appropriate.
- **Accessibility** considered (labels, Dynamic Type–friendly fonts in the design system).

---

## Design system (summary)

- **Theme** – Near-black canvas (`#07070A`), yellow signal accent (`#E6FF47`), and a **category mesh** for each family (alkali through noble gases).
- **Typography** – **SF Pro Rounded** for titles and symbols; **SF Pro Text** for body; **SF Mono** for data. Hero metrics use a **dot-lattice mask** (`DottedDisplay`) rather than a separate font file.
- **Spacing** – 4pt grid–style scale. Hero cards use a **32pt** continuous corner radius.
- **Shared surfaces** – `VibeSurface.swift` holds the canvas, mesh fill, dotted numerals, signal wave, and widget chrome.

---

## Requirements

- **Xcode** 15+
- **iOS** 17+
- **Swift** 5.9+

---

## Setup

1. Clone the repository.
2. Open **`Periodic Table.xcodeproj`** in Xcode.
3. Set your **development team** under **Signing & Capabilities**.
4. Build and run (**⌘R**) on a simulator or device.

---

## Data sources

- Element data is loaded from **[Bowserinator/Periodic-Table-JSON](https://github.com/Bowserinator/Periodic-Table-JSON)** (CSV pipeline in-app), with a **bundled JSON** fallback.
- **3D Bohr** models use **[Search AR EDU](https://storage.googleapis.com/search-ar-edu/periodic-table/)** GLB assets when URLs are present in the dataset.

---

## License

Specify your license here (e.g. MIT) and add a `LICENSE` file in the repo root.

---

## Acknowledgments

- Widget surfaces (dot-grid canvas, stippled numerals, category meshes, yellow signal accent) set the visual language.
- Spacing and shadow presets still follow a 4pt scale so elevation stays consistent across tabs.
