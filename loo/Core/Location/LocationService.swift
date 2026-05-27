import Foundation
import Observation
import CoreLocation

// Separate NSObject delegate to avoid NSObject + @Observable concurrency issues.
// CLLocationManager always calls delegates on the thread it was created on (main).
private final class LocationManagerDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var onLocation: @Sendable (CLLocation) -> Void = { _ in }
    var onHeading:  @Sendable (CLHeading)  -> Void = { _ in }
    var onAuth:     @Sendable (CLAuthorizationStatus) -> Void = { _ in }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        onLocation(loc)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onHeading(newHeading)
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        onAuth(manager.authorizationStatus)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Silently ignore transient errors; the user sees the map without a location dot
    }
}

@Observable
@MainActor
final class LocationService {
    private let manager  = CLLocationManager()
    private let delegate = LocationManagerDelegate()

    private(set) var location: CLLocation?
    private(set) var heading:  CLHeading?
    private(set) var authorizationStatus: CLAuthorizationStatus = .notDetermined

    init() {
        manager.delegate        = delegate
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.distanceFilter  = 10

        delegate.onLocation = { [weak self] loc in
            Task { @MainActor [weak self] in self?.location = loc }
        }
        delegate.onHeading = { [weak self] h in
            Task { @MainActor [weak self] in self?.heading = h }
        }
        delegate.onAuth = { [weak self] status in
            Task { @MainActor [weak self] in
                self?.authorizationStatus = status
                if status == .authorizedWhenInUse || status == .authorizedAlways {
                    self?.manager.startUpdatingLocation()
                    if CLLocationManager.headingAvailable() {
                        self?.manager.startUpdatingHeading()
                    }
                }
            }
        }
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func start() { manager.startUpdatingLocation() }
    func stop()  { manager.stopUpdatingLocation() }
}
