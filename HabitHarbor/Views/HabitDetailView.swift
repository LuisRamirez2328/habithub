import SwiftUI
import Charts
import HabitCore

struct HabitDetailView: View {
    @Environment(HabitStore.self) private var store
    let habit: Habit

    private var chartData: [(day: Date, completed: Int)] {
        habit.completionsByDay(span: 7)
            .sorted { $0.key < $1.key }
            .map { (day: $0.key, completed: $0.value) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                header
                statsGrid
                SectionCard(title: "Last 7 days") {
                    chart
                }
            }
            .padding()
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationTitle(habit.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        HStack {
            Text(habit.emoji)
                .font(.system(size: 40))
            Spacer()
            Button {
                store.toggle(habit)
            } label: {
                Label(
                    habit.isCompleted(on: Date()) ? "Done today" : "Mark done",
                    systemImage: habit.isCompleted(on: Date()) ? "checkmark.circle.fill" : "circle"
                )
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var statsGrid: some View {
        HStack(spacing: 12) {
            StatBox(value: "\(habit.currentStreak)", label: "Current streak", icon: "flame.fill")
            StatBox(value: "\(habit.longestStreak)", label: "Longest", icon: "trophy.fill")
            StatBox(value: "\(habit.weeklyCompletionCount)", label: "This week", icon: "calendar")
            StatBox(value: "\(habit.completionCount)", label: "Total", icon: "checkmark")
        }
    }

    private var chart: some View {
        Chart(chartData, id: \.day) { item in
            BarMark(
                x: .value("Day", item.day, unit: .day),
                y: .value("Completions", item.completed)
            )
            .foregroundStyle(Theme.color(habit.colorName))
            .cornerRadius(4)
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.weekday(.narrow))
            }
        }
        .frame(height: 180)
    }
}

private struct StatBox: View {
    let value: String
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

private struct SectionCard<Content: View>: View {
    let title: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Theme.textPrimary)
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Theme.card)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
