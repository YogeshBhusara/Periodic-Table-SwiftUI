# Periodic Table

A SwiftUI iOS app to explore the periodic table of elements: browse elements, view 3D Bohr models, compare properties, and quiz yourself.

## Features

- **Elements tab** – Carousel of element cards with category colors, 3D Bohr model (when available), and quick details
- **Learn tab** – Property comparator and quiz mode, with background that matches the element shown on the Elements tab
- **Element detail** – Full details, electron configuration, history, and related elements
- **Favorites** – Save elements and filter by category
- **Design** – DesignCode-style spacing and shadows, liquid glass UI, line icons, dark mode support

## Requirements

- Xcode 15+
- iOS 17+
- Swift 5.9+

## Setup

1. Clone the repo (or open the project if you have it locally).
2. Open `Periodic Table.xcodeproj` in Xcode.
3. Select your development team under **Signing & Capabilities**.
4. Build and run on a simulator or device (⌘R).

## Data

Element data is loaded from [Bowserinator/Periodic-Table-JSON](https://github.com/Bowserinator/Periodic-Table-JSON) (CSV). 3D Bohr models use Google’s [Search AR EDU](https://storage.googleapis.com/search-ar-edu/periodic-table/) GLB assets when available.

## License

[Choose a license – e.g. MIT, and add the file and a line here.]
