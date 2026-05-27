import Foundation
import Observation
import CoreLocation

private final class HeadingManagerDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    var onHeading: @Sendable (CLHeading) -> Void = { _ in }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        onHeading(newHeading)
    }
}

@Observable
@MainActor
final class HeadingService {
    private let manager  = CLLocationManager()
    private let delegate = HeadingManagerDelegate()

    private(set) var heading: CLHeading?
    let isAvailable: Bool

    init() {
        isAvailable      = CLLocationManager.headingAvailable()
        manager.delegate = delegate
        delegate.onHeading = { [weak self] h in
            Task { @MainActor [weak self] in self?.heading = h }
        }
    }

    func start() {
        guard isAvailable else { return }
        manager.startUpdatingHeading()
    }

    func stop() {
        manager.stopUpdatingHeading()
    }
}
