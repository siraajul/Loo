# Loo — Dhaka Washroom Finder

A community-powered iOS app to find clean, accessible public washrooms in Dhaka, Bangladesh.

## Features

- **OSM Map** — OpenStreetMap tiles via MapLibre GL Native (free, no API key)
- **Live Location** — Blue dot on map, real-time distance sorting in the nearby list
- **Nearby Sheet** — Horizontal scroll of the 5 closest washrooms, sorted by GPS distance
- **Compass Finder** — Point-and-navigate arrow that rotates with the device compass toward the selected washroom, with haptic feedback as you get closer
- **Washroom Detail** — Rating, fee, accessibility, bidet, soap/tissue availability, photo gallery
- **Submit a Washroom** — Form with map location preview to add new community entries
- **Filters** — Filter by type (mosque, mall, hospital, petrol pump…), gender, accessibility, price
- **Profile & Auth** — Phone OTP sign-in via Supabase

## Tech Stack

| Layer | Technology |
|---|---|
| UI | SwiftUI |
| Map | MapLibre GL Native + OpenFreeMap tiles |
| Persistence | SwiftData |
| Backend | Supabase (PostgreSQL + Auth) |
| Location | CoreLocation — GPS + compass heading |
| Language | Swift 5.9+ |
| Platform | iOS 17+ |

## Project Structure

```
loo/
├── App/
│   ├── AppRouter.swift        # NavigationStack path & route enum
│   └── Theme.swift            # Colors, fonts, spacing, radii
├── Core/
│   ├── Location/
│   │   ├── LocationService.swift   # CLLocationManager (GPS + compass)
│   │   └── HeadingService.swift
│   ├── Network/
│   │   └── SupabaseClient.swift
│   ├── Persistence/
│   │   ├── AppModelContainer.swift
│   │   └── SeedData.swift         # 10 real Dhaka seed washrooms
│   └── Utilities/
│       ├── Formatting.swift       # Distance (m/km), fee (৳), rating
│       └── Geo.swift              # Bearing & distance calculations
├── Features/
│   ├── Map/                   # Main map screen (OSMMapView wrapper)
│   ├── Finder/                # Compass navigator
│   ├── Detail/                # Washroom detail + photo gallery
│   ├── NearbyList/            # Nearby sheet + cards
│   ├── Submit/                # Add washroom form
│   ├── Filters/               # Filter sheet
│   ├── Auth/                  # Phone OTP sign-in
│   └── Profile/               # User profile
└── Models/
    ├── Washroom.swift         # SwiftData model
    ├── Rating.swift
    ├── Submission.swift
    └── UserProfile.swift
```

## Requirements

- Xcode 15+
- iOS 17+
- Swift Package: [MapLibre GL Native](https://github.com/maplibre/maplibre-gl-native-distribution)

## Setup

1. Clone the repo
   ```bash
   git clone https://github.com/siraajul/Loo.git
   cd Loo
   ```

2. Open `loo.xcodeproj` in Xcode. The MapLibre SPM package resolves automatically.

3. Add the location privacy key to the target's Build Settings:
   - Key: `NSLocationWhenInUseUsageDescription`
   - Value: `Used to show washrooms near your current location.`

4. (Optional) Add your Supabase credentials to `Core/Network/SupabaseClient.swift` to enable the backend.

5. Build and run on a real device (map tiles and compass require hardware).

## Seed Data

The app ships with 10 real Dhaka washrooms for offline-first use before the Supabase backend is wired up:

- Bashundhara City Mall
- Jamuna Future Park
- Baitul Mukarram Mosque
- Square Hospital
- Dhanmondi Lake Park
- Gulshan-1 DCC Market
- Panthapath Petrol Pump
- Star Kabab Restaurant
- Motijheel Shapla Chatter
- Uttara Sector-3 Park

## Map Tiles

This app uses [OpenFreeMap](https://openfreemap.org/) — free, open-source OSM vector tiles with no API key required. Tiles are served over HTTPS; an active internet connection is needed to render the map.

## License

MIT
