import SwiftUI
import CoreLocation
import UIKit

@Observable
@MainActor
final class FinderViewModel {
    private(set) var arrowRotation:   Double = 0
    private(set) var distanceMeters:  Double = 0
    private(set) var needsCalibration = false

    private var targetCoordinate: CLLocationCoordinate2D?
    private var updateTask: Task<Void, Never>?
    private var smoothedHeading: Double = 0
    private let alpha = 0.15
    private var hapticBucket = -1
    private let hapticGenerator = UIImpactFeedbackGenerator(style: .soft)

    var gradientColors: [Color] {
        let progress = min(1.0, distanceMeters / 200.0)
        switch progress {
        case ..<0.3: return [.brand, .brandDark]
        case ..<0.7: return [.accent, .orange]
        default:     return [.danger, .red]
        }
    }

    func start(targeting washroom: Washroom, locationService: LocationService) {
        targetCoordinate = washroom.coordinate
        hapticGenerator.prepare()

        // Poll location + heading at 10 Hz for smooth arrow rotation.
        // Both services are @MainActor so this Task runs on main actor too.
        updateTask = Task {
            while !Task.isCancelled {
                if let loc = locationService.location,
                   let heading = locationService.heading {
                    self.update(location: loc, heading: heading)
                }
                try? await Task.sleep(for: .milliseconds(100))
            }
        }
    }

    func stop() {
        updateTask?.cancel()
        updateTask = nil
    }

    private func update(location: CLLocation, heading: CLHeading) {
        guard let target = targetCoordinate else { return }

        // Distance to target
        distanceMeters = location.distance(from:
            CLLocation(latitude: target.latitude, longitude: target.longitude))

        // Show calibration prompt when compass accuracy is poor
        needsCalibration = heading.headingAccuracy > 20 || heading.headingAccuracy < 0

        // Low-pass filter — smooths compass jitter without adding lag
        // trueHeading is -1 when magnetic declination data isn't available; fall back to magnetic
        let raw   = heading.trueHeading >= 0 ? heading.trueHeading : heading.magneticHeading
        let delta = raw - smoothedHeading
        let adj   = delta > 180 ? raw - 360 : (delta < -180 ? raw + 360 : raw)
        smoothedHeading = alpha * adj + (1 - alpha) * smoothedHeading

        // Arrow points at target: bearing minus current device heading
        let bearing = Geo.bearing(from: location.coordinate, to: target)
        arrowRotation = bearing - (smoothedHeading * .pi / 180)

        // Haptic bump every 10 m bucket when within 100 m
        let bucket = Int(distanceMeters / 10)
        if bucket != hapticBucket && distanceMeters < 100 {
            hapticBucket = bucket
            hapticGenerator.impactOccurred()
        }
    }
}
