import SwiftUI
import MapLibre
import CoreLocation

struct SubmitFormState {
    var name: String          = ""
    var nameBn: String        = ""
    var type: WashroomType    = .publicToilet
    var gender: WashroomGender = .both
    var accessible: Bool      = false
    var feeBdt: Int           = 0
    var latitude: Double      = 23.8103   // Default: central Dhaka
    var longitude: Double     = 90.4125
    var notes: String         = ""

    var isValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }

    func toProposedData() -> ProposedWashroomData {
        ProposedWashroomData(
            name:       name,
            nameBn:     nameBn.isEmpty ? nil : nameBn,
            type:       type.rawValue,
            gender:     gender.rawValue,
            accessible: accessible,
            feeBdt:     feeBdt,
            latitude:   latitude,
            longitude:  longitude,
            notes:      notes.isEmpty ? nil : notes
        )
    }
}

struct SubmitForm: View {
    @Binding var form: SubmitFormState

    var body: some View {
        Form {
            Section("Pin Location") {
                // TODO: Replace with interactive draggable pin map (Week 4)
                LocationPreviewMap(latitude: form.latitude, longitude: form.longitude)
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: Radius.card))
                    .listRowInsets(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

                HStack {
                    Text("Lat").foregroundStyle(Color.textSecondary)
                    TextField("Latitude", value: $form.latitude, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Lng").foregroundStyle(Color.textSecondary)
                    TextField("Longitude", value: $form.longitude, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            }

            Section("Name") {
                TextField("Name in English", text: $form.name)
                TextField("নাম (বাংলা — optional)", text: $form.nameBn)
            }

            Section("Type") {
                Picker("Type", selection: $form.type) {
                    ForEach(WashroomType.allCases, id: \.self) { t in
                        Label(t.displayName, systemImage: t.systemImage).tag(t)
                    }
                }
            }

            Section("Gender") {
                Picker("Gender", selection: $form.gender) {
                    ForEach(WashroomGender.allCases, id: \.self) { g in
                        Text(g.displayName).tag(g)
                    }
                }
                .pickerStyle(.segmented)
            }

            Section("Accessibility") {
                Toggle("Wheelchair accessible", isOn: $form.accessible)
            }

            Section("Fee (BDT)") {
                Stepper("৳\(form.feeBdt)", value: $form.feeBdt, in: 0...200, step: 5)
            }

            Section("Notes") {
                TextField("Any additional info…", text: $form.notes, axis: .vertical)
                    .lineLimit(3...6)
            }

            // TODO: Photo upload section (Week 4)
        }
    }
}

// MARK: - Lightweight OSM map for the location pin preview

private struct LocationPreviewMap: UIViewRepresentable {
    let latitude: Double
    let longitude: Double

    private static let styleURL = URL(string: "https://tiles.openfreemap.org/styles/liberty")!
    private static let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"

    func makeUIView(context: Context) -> MLNMapView {
        let map = MLNMapView(frame: UIScreen.main.bounds, styleURL: Self.styleURL)
        map.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        map.isScrollEnabled  = false
        map.isZoomEnabled    = false
        map.isRotateEnabled  = false
        map.isPitchEnabled   = false
        map.logoView.isHidden        = true
        map.attributionButton.isHidden = true
        return map
    }

    func updateUIView(_ map: MLNMapView, context: Context) {
        let coord = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        map.setCenter(coord, zoomLevel: 15, animated: false)

        map.removeAnnotations(map.annotations ?? [])
        let pin = MLNPointAnnotation()
        pin.coordinate = coord
        map.addAnnotation(pin)
    }
}
