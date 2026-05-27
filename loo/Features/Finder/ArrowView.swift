import SwiftUI

struct ArrowView: View {
    let rotation: Double   // radians

    var body: some View {
        Image(systemName: "location.north.fill")
            .font(.system(size: 120, weight: .regular))
            .foregroundStyle(.white)
            .shadow(color: .white.opacity(0.3), radius: 20)
            .rotationEffect(.radians(rotation))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: rotation)
    }
}

#Preview {
    ZStack {
        Color.brand.ignoresSafeArea()
        ArrowView(rotation: .pi / 4)
    }
}
