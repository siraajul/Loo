import SwiftUI

struct PhotoGallery: View {
    let washroomID: String
    @State private var photoURLs: [URL] = []

    var body: some View {
        if photoURLs.isEmpty {
            ZStack {
                Color.surfaceElev
                VStack(spacing: Spacing.sm) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.textSecondary)
                    Text("No photos yet")
                        .font(.looCaption)
                        .foregroundStyle(Color.textSecondary)
                }
            }
            .frame(height: 220)
        } else {
            TabView {
                ForEach(photoURLs, id: \.self) { url in
                    // TODO: Replace AsyncImage with Kingfisher for disk caching and downscaling
                    AsyncImage(url: url) { image in
                        image.resizable().aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.surfaceElev
                    }
                    .clipped()
                }
            }
            .tabViewStyle(.page)
            .frame(height: 220)
        }
    }
}
