import SwiftUI
import MapLibre
import CoreLocation

// MapLibre GL Native wrapper using OpenFreeMap tiles (free, no API key, OSM data)
// SPM package: https://github.com/maplibre/maplibre-gl-native-distribution  (product: MapLibre)
struct OSMMapView: UIViewRepresentable {
    let washrooms: [Washroom]
    let onWashroomTap: (String) -> Void
    /// Passed from LocationService; when non-nil the map centers once on the user.
    var userLocation: CLLocationCoordinate2D?

    private static let styleURL    = URL(string: "https://tiles.openfreemap.org/styles/liberty")!
    private static let dhakaCenter = CLLocationCoordinate2D(latitude: 23.7749, longitude: 90.3990)

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIView(context: Context) -> MLNMapView {
        // Use screen bounds so MapLibre initialises its Metal renderer with a real size.
        // SwiftUI will resize via autoresizingMask before the first frame is drawn.
        let map = MLNMapView(frame: UIScreen.main.bounds, styleURL: Self.styleURL)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.delegate = context.coordinator
        map.showsUserLocation = true
        map.setCenter(Self.dhakaCenter, zoomLevel: 13, animated: false)
        // Keep visible content between the floating top bar and the nearby sheet
        map.contentInset = UIEdgeInsets(top: 110, left: 0, bottom: 160, right: 0)
        map.compassViewMargins = CGPoint(x: 16, y: 110)
        return map
    }

    func updateUIView(_ map: MLNMapView, context: Context) {
        syncAnnotations(on: map)
        // Center on the user once when their location first becomes available
        if let coord = userLocation, !context.coordinator.hasCenteredOnUser {
            context.coordinator.hasCenteredOnUser = true
            map.setCenter(coord, zoomLevel: 15, animated: true)
        }
    }

    private func syncAnnotations(on map: MLNMapView) {
        let existing    = (map.annotations ?? []).compactMap { $0 as? WashroomAnnotation }
        let existingIDs = Set(existing.map(\.washroomID))
        let currentIDs  = Set(washrooms.map(\.id))

        let toRemove = existing.filter { !currentIDs.contains($0.washroomID) }
        if !toRemove.isEmpty { map.removeAnnotations(toRemove) }

        let toAdd = washrooms.filter { !existingIDs.contains($0.id) }.map(WashroomAnnotation.init)
        if !toAdd.isEmpty { map.addAnnotations(toAdd) }
    }

    // MARK: - Annotation model

    final class WashroomAnnotation: NSObject, MLNAnnotation {
        let washroomID: String
        let gender: WashroomGender
        let type: WashroomType
        var coordinate: CLLocationCoordinate2D
        var title: String?
        var subtitle: String?

        init(_ w: Washroom) {
            washroomID = w.id
            gender     = w.gender
            type       = w.type
            coordinate = w.coordinate
            title      = w.name
        }
    }

    // MARK: - Delegate

    final class Coordinator: NSObject, MLNMapViewDelegate {
        var parent: OSMMapView
        var hasCenteredOnUser = false
        init(parent: OSMMapView) { self.parent = parent }

        func mapView(_ map: MLNMapView, viewFor annotation: MLNAnnotation) -> MLNAnnotationView? {
            guard let wa = annotation as? WashroomAnnotation else { return nil }
            let id   = "washroom"
            let view = (map.dequeueReusableAnnotationView(withIdentifier: id) as? WashroomMarkerView)
                       ?? WashroomMarkerView(reuseIdentifier: id)
            view.configure(gender: wa.gender, type: wa.type)
            return view
        }

        func mapView(_ map: MLNMapView, didSelect annotation: MLNAnnotation) {
            guard let wa = annotation as? WashroomAnnotation else { return }
            map.deselectAnnotation(annotation, animated: false)
            parent.onWashroomTap(wa.washroomID)
        }
    }
}

// MARK: - Custom marker (UIKit)

private final class WashroomMarkerView: MLNAnnotationView {
    private let circle    = UIView()
    private let icon      = UIImageView()
    private let badge     = UIView()
    private let badgeIcon = UIImageView()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        backgroundColor = .clear
        isUserInteractionEnabled = true
        buildSubviews()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func buildSubviews() {
        circle.frame              = CGRect(x: 2, y: 2, width: 40, height: 40)
        circle.layer.cornerRadius = 20
        circle.layer.shadowOpacity = 0.35
        circle.layer.shadowRadius  = 4
        circle.layer.shadowOffset  = CGSize(width: 0, height: 2)
        addSubview(circle)

        icon.contentMode = .scaleAspectFit
        icon.tintColor   = .white
        icon.frame       = CGRect(x: 10, y: 10, width: 20, height: 20)
        circle.addSubview(icon)

        badge.frame               = CGRect(x: 30, y: -2, width: 16, height: 16)
        badge.backgroundColor     = .white
        badge.layer.cornerRadius  = 8
        addSubview(badge)

        badgeIcon.contentMode = .scaleAspectFit
        badgeIcon.frame       = CGRect(x: 3, y: 3, width: 10, height: 10)
        badge.addSubview(badgeIcon)
    }

    func configure(gender: WashroomGender, type: WashroomType) {
        let color = UIColor(gender.markerColor)
        circle.backgroundColor   = color
        circle.layer.shadowColor = color.cgColor

        icon.image = UIImage(
            systemName: type.systemImage,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        )

        let showBadge = gender == .male || gender == .female
        badge.isHidden = !showBadge
        if showBadge {
            badgeIcon.image = UIImage(
                systemName: gender.systemImage,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 8, weight: .bold)
            )
            badgeIcon.tintColor = color
        }
    }
}
