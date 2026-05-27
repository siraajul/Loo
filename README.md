<br>

<div align="center">

# 🚻 Loo
### Find a clean washroom in Dhaka — fast.

*Community-powered · Free forever · Built for Bangladesh*

[![iOS](https://img.shields.io/badge/iOS-17%2B-black?style=flat-square&logo=apple)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?style=flat-square&logo=swift)](https://swift.org)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5-blue?style=flat-square&logo=swift)](https://developer.apple.com/xcode/swiftui/)
[![MapLibre](https://img.shields.io/badge/Map-MapLibre%20%2B%20OSM-brightgreen?style=flat-square)](https://maplibre.org)
[![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)](LICENSE)

</div>

---

> **Finding a clean public washroom in Dhaka is hard.**  
> Dead apps, outdated listings, zero community input.  
> Loo fixes that — open-source, OSM-powered, built by the community for the city.

---

## ✨ What it does

| Feature | Description |
|---|---|
| 🗺 **Live OSM Map** | OpenStreetMap tiles via MapLibre — no Google, no fees, always up to date |
| 📍 **Blue Dot + Auto-Center** | Snaps to your GPS position the moment location is granted |
| 🧭 **Compass Finder** | Real-time rotating arrow guides you turn-by-turn to the washroom, with haptic pulses as you get closer |
| 📋 **Nearby Sheet** | 5 closest washrooms sorted by live GPS distance, updating as you move |
| 🔍 **Detail View** | Rating, fee (৳), gender, accessibility ♿, bidet, soap, tissue, photos |
| ➕ **Submit a Washroom** | Crowdsource new locations with map preview and community review |
| 🎛 **Smart Filters** | Filter by type, gender, price, accessibility |
| 🔐 **Auth** | Phone OTP sign-in via Supabase — no email required |

---

## 📱 Screens

```
┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐
│   🗺 Map View   │  │  🧭 Finder View │  │  📋 Detail View │
│                 │  │                 │  │                 │
│  [OSM Dhaka]    │  │   Bashundhara   │  │  ★ 4.2  Free    │
│  📍 markers     │  │       ↑         │  │  ♿ Accessible   │
│                 │  │      ↑↑         │  │  🚿 Bidet       │
│ ┌─────────────┐ │  │    320 m        │  │  🧼 Soap        │
│ │ Nearby      │ │  │     away        │  │                 │
│ │ 🏪 320m 🕌  │ │  │ [Open in Maps]  │  │ [📸 Photos]     │
└─────────────────┘  └─────────────────┘  └─────────────────┘
```

---

## 🏗 Architecture

```
loo/
├── 📱 App/
│   ├── AppRouter.swift          # NavigationStack path + route enum
│   └── Theme.swift              # Design tokens: colors, fonts, spacing
│
├── 🔧 Core/
│   ├── Location/
│   │   └── LocationService.swift    # GPS + live compass heading (single CLLocationManager)
│   ├── Network/
│   │   └── SupabaseClient.swift     # Supabase backend client
│   ├── Persistence/
│   │   ├── AppModelContainer.swift  # SwiftData stack
│   │   └── SeedData.swift           # 10 real Dhaka washrooms (offline-first)
│   └── Utilities/
│       ├── Formatting.swift         # Distance (m/km), fee (৳), rating
│       └── Geo.swift                # Haversine bearing & distance
│
├── 🎨 Features/
│   ├── Map/          # Main map screen — MapLibre OSMMapView wrapper
│   ├── Finder/       # Compass navigator with low-pass smoothed heading
│   ├── Detail/       # Washroom info + photo gallery
│   ├── NearbyList/   # Horizontal card scroll, GPS-sorted
│   ├── Submit/       # Add washroom form with live map preview
│   ├── Filters/      # Filter sheet (type / gender / price / accessibility)
│   ├── Auth/         # Phone OTP
│   └── Profile/      # User profile
│
└── 🗃 Models/
    ├── Washroom.swift    # @Model — SwiftData persistent entity
    ├── Rating.swift
    ├── Submission.swift
    └── UserProfile.swift
```

---

## 🧠 How the Compass Works

The Finder screen gives you a real-time pointing arrow — no map needed, just walk.

```
arrowRotation = bearing(userLocation → target)  [radians]
              − deviceHeading                    [radians]
```

- **Bearing** is computed via the Haversine formula (true north = 0, clockwise +)
- **Heading** comes from `CLHeading.trueHeading` on the same `CLLocationManager` as GPS, so magnetic declination is applied correctly
- A **low-pass filter** (`α = 0.15`) smooths jitter without adding lag
- **Haptic feedback** fires every 10 m when within 100 m of the target

---

## 🗺 Why MapLibre + OpenFreeMap?

| | Google Maps | Apple Maps | **MapLibre + OpenFreeMap** |
|---|---|---|---|
| Cost | 💰 Pay per load | Free (limited) | ✅ **Free forever** |
| Bangladesh coverage | Moderate | Poor | ✅ **Excellent (HOT + OSM community)** |
| Offline support | No | Limited | ✅ **Yes** |
| Open source | No | No | ✅ **Yes** |
| Custom styling | Paid | No | ✅ **Yes** |

---

## 🚀 Quick Start

### Requirements
- Xcode 15+
- iOS 17+ device (map tiles + compass need real hardware)
- Swift 5.9+

### Steps

```bash
# 1. Clone
git clone https://github.com/siraajul/Loo.git
cd Loo

# 2. Open in Xcode — MapLibre SPM package resolves automatically
open loo.xcodeproj
```

**3. Add location permission** in the target's Build Settings:
```
INFOPLIST_KEY_NSLocationWhenInUseUsageDescription = Used to show washrooms near your location.
```

**4. (Optional) Supabase backend** — add your project URL and anon key to:
```
loo/Core/Network/SupabaseClient.swift
```

**5. Run on device** — the app seeds 10 real Dhaka washrooms on first launch so it works immediately, even without a backend.

---

## 🌱 Seed Data (Offline-first)

The app ships with 10 verified Dhaka washrooms so it's usable from day one:

| Washroom | Type | Fee |
|---|---|---|
| Bashundhara City Mall | 🏪 Mall | Free |
| Jamuna Future Park | 🏪 Mall | Free |
| Baitul Mukarram Mosque | 🕌 Mosque | Free |
| Square Hospital | 🏥 Hospital | Free |
| Dhanmondi Lake Park | 🚻 Public | ৳2 |
| Gulshan-1 DCC Market | 🚻 Public | ৳5 |
| Panthapath Petrol Pump | ⛽ Petrol Pump | Free |
| Star Kabab Restaurant | 🍴 Restaurant | Free |
| Motijheel Shapla Chatter | 🚻 Public | ৳3 |
| Uttara Sector-3 Park | 🚻 Public | Free |

---

## 🛠 Tech Stack

| Layer | Technology |
|---|---|
| **UI** | SwiftUI 5 |
| **Map** | MapLibre GL Native + OpenFreeMap (OSM vector tiles) |
| **Local DB** | SwiftData |
| **Backend** | Supabase (PostgreSQL + Auth + Storage) |
| **Location** | CoreLocation — GPS + compass heading |
| **State** | `@Observable` macro (iOS 17) |
| **Nav** | `NavigationStack` + typed route enum |
| **Language** | Swift 5.9 |

---

## 🤝 Contributing

Dhaka has thousands of washrooms not yet on the map. Here's how to help:

1. **Fork** this repo
2. **Create a branch** — `git checkout -b feature/my-feature`
3. **Commit** your changes
4. **Push** and open a **Pull Request**

Suggestions, bug reports, and new Dhaka washroom data are all welcome via [Issues](https://github.com/siraajul/Loo/issues).

---

## 📄 License

MIT © [siraajul](https://github.com/siraajul)

---

<div align="center">
  <sub>Built with ❤️ for Dhaka · Powered by OpenStreetMap contributors</sub>
</div>
