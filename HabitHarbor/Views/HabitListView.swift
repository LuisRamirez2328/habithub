import SwiftUI
import HabitCore

struct HabitListView: View {
    @Environment(HabitStore.self) private var store
    @State private var showAdd = false

    var body: some View {
        NavigationStack {
            Group {
                if store.habits.isEmpty {
                    ContentUnavailableView(
                        "No habits yet",
                        systemImage: "star",
                        description: Text("Tap + to create your first habit.")
                    )
                } else {
                    List {
                        summarySection
                        habitsSection
                    }
                    .listStyle(.insetGrouped)
                    .scrollContentBackground(.hidden)
                }
            }
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("HabitHarbor")
            .navigationDestination(for: Habit.self) { habit in
                HabitDetailView(habit: habit)
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddHabitView()
            }
        }
        .tint(Theme.accent)
    }

    private var summarySection: some View {
        let total = store.habits.count
        let done = store.habitsCompleted(on: Date())
        return Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(done) of \(total) done today")
                        .font(.headline)
                        .foregroundStyle(Theme.textPrimary)
                    Text(done == 0 ? "Start building momentum" : "Keep the momentum going 💪")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                CircularProgress(progress: total == 0 ? 0 : Double(done) / Double(total))
                    .frame(width: 44, height: 44)
            }
            .padding(.vertical, 4)
        }
        .listRowBackground(Theme.card)
    }

    private var habitsSection: some View {
        Section("Habits") {
            ForEach(store.habits) { habit in
                NavigationLink(value: habit) {
                    HabitCardView(habit: habit)
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    store.delete(store.habits[index])
                }
            }
        }
    }
}
