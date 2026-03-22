# Periodic Table

A native **SwiftUI** iOS app for exploring chemical elements in a **bold, modern interface**—built on **Liquid Glass** materials, **category-driven color**, and **motion-driven** interactions that make dense scientific data feel approachable and engaging.

---

## What this app is

Periodic Table is a **learning and reference** companion for the elements: browse by category, open rich detail sheets, compare properties side by side, and test yourself with a quiz. The UI is **information-dense by design** (atomic numbers, symbols, configurations, discovery history) but presented through **layered glass, depth, and animation** so exploration feels like a polished product—not a static textbook.

---

## Why this app exists

- **Education** – The periodic table is foundational to chemistry; the app makes it **quick to explore** patterns (groups, periods, metals vs non-metals) without hunting through paper charts or generic websites.
- **Retention & curiosity** – Short quiz modes, comparisons, and **visual hooks** (orbital diagrams, 3D Bohr models where data exists) support **active learning** rather than passive reading.
- **Delight on purpose** – Science apps often default to utilitarian UIs. Here, **Liquid Glass**, **spring-based motion**, and **category color** are intentional: they reward exploration and keep the experience **memorable** on a device people use every day.

---

## Liquid Glass & materials

The app leans into **Apple’s Liquid Glass** (and related APIs) so surfaces feel **physical and layered**—cards, sheets, chips, and controls sit on **frosted, interactive glass** instead of flat fills.

| Where it shows up | Role |
|-------------------|------|
| **Element cards & detail** | Glass panels, tinted by **element category**, with subtle elevation (shadows + inner glow in dark mode). |
| **Sheets & menus** | Detail presentation and menu flyouts use **glass + corner radius** aligned with the design system so transitions feel **continuous** with the carousel. |
| **Quiz & Learn** | Header and question areas use **glass containers** so learning modes match the rest of the app’s depth. |
| **Actions & chips** | Circular glass buttons and capsule chips keep controls **readable** on busy, colorful backgrounds. |

Supporting patterns include **DesignCode-style elevation** (shadow presets, optional **inner glow** on dark surfaces) so depth stays **consistent** across tabs without fighting the glass aesthetic.

---

## Complex UI & animations

Animations are used to **orient the user**, **connect related UI**, and **avoid jarring jumps** when data or selection changes—not only for decoration.

| Technique | What it does in the app |
|-----------|-------------------------|
| **Matched geometry / namespace** | Card → detail transitions share identity where possible so the interface feels like **one continuous surface** opening into depth. |
| **Spring curves (e.g. “Spotify-style”)** | Carousel and overlay motion use **tuned springs** (response + damping) for **smooth, non-bouncy** movement that still feels alive. |
| **Sheet presentation** | Custom animation on the detail sheet pairs with **presentation detents** so expand/collapse feels **linked** to the card metaphor. |
| **Parallax & background motion** | Large background atomic numbers and **liquid blob** motion move at different rates than foreground content—**depth without clutter**. |
| **Orbital & canvas** | Timeline-driven **Canvas** drawing animates electron shells; **3D Bohr** views use WebKit + Three.js for interactive models when URLs are available. |
| **Filters & state** | Filter and search updates are wrapped in **easing** so lists and carousels don’t snap disorientingly. |

Together, these choices keep the app **responsive** under load (lazy patterns, intentional grouping) while the **motion language** stays consistent: **springs for spatial transitions**, **ease for content fades**, **glass** for “this is a surface I can focus on.”

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

- **Theme** – Deep charcoal backgrounds in dark mode, **vibrant category palette** (e.g. alkali, transition metals, halogens, noble gases), functional colors for **quiz success/error**.
- **Typography** – **SF Pro Rounded** for headings and hero symbol treatment; **SF Pro Text** for body; **SF Mono** for numeric and configuration data.
- **Spacing** – 4pt grid–style scale for consistent padding and rhythm.

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

- Liquid Glass patterns inspired by community explorations of **`glassEffect`** / glass containers in SwiftUI.
- Design elevation ideas aligned with **DesignCode**-style spacing and shadow presets used in the project.
