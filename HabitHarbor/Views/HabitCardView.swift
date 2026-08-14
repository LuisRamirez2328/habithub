import SwiftUI
import HabitCore

struct HabitCardView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Theme.color(habit.colorName).opacity(0.16))
                Text(habit.emoji)
                    .font(.title2)
            }
            .frame(width: 46, height: 46)

            VStack(alignment: .leading, spacing: 5) {
                Text(habit.title)
                    .font(.headline)
                    .foregroundStyle(Theme.textPrimary)

                HStack(spacing: 10) {
                    if habit.currentStreak > 0 {
                        Label("\(habit.currentStreak)", systemImage: "flame.fill")
                            .foregroundStyle(Theme.accent)
                    }
                    Text("\(habit.weeklyCompletionCount)/\(habit.weeklyGoal) this week")
                        .foregroundStyle(.secondary)
                }
                .font(.caption)
            }

            Spacer()

            Button {
                store.toggle(habit)
            } label: {
                Image(systemName: habit.isCompleted(on: Date()) ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(habit.isCompleted(on: Date()) ? Theme.accent : Color.secondary)
            }
            .buttonStyle(.borderless)
        }
        .padding(.vertical, 4)
    }
}
