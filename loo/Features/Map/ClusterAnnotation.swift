import SwiftUI

struct ClusterAnnotationView: View {
    let count: Int

    var body: some View {
        ZStack {
            Circle()
                .fill(Color.brand)
                .frame(width: 44, height: 44)
                .shadow(radius: 4)
            Text("\(count)")
                .font(.looCaption)
                .fontWeight(.bold)
                .foregroundStyle(.white)
        }
    }
}
