import SwiftUI

/// Progress ring used in the summary card.
struct CircularProgress: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.border, lineWidth: 5)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(Theme.accent, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .animation(.easeInOut(duration: 0.3), value: progress)
    }
}
