import Foundation
import Observation

/// Observable source of truth for the user's habits, with JSON persistence.
/// The storage URL is injectable so tests can use a temporary directory.
@Observable
final class HabitStore {
    private(set) var habits: [Habit] = []

    private let storageURL: URL

    private static var defaultStorageURL: URL {
        let directory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return directory.appendingPathComponent("habits.json")
    }

    init(storageURL: URL? = nil, seed: Bool = false) {
        self.storageURL = storageURL ?? Self.defaultStorageURL
        if seed {
            habits = Habit.samples
        } else {
            load()
        }
    }

    // MARK: - CRUD

    func add(_ habit: Habit) {
        habits.append(habit)
        save()
    }

    func delete(_ habit: Habit) {
        habits.removeAll { $0.id == habit.id }
        save()
    }

    func toggle(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index].toggle()
        save()
    }

    func update(_ habit: Habit) {
        guard let index = habits.firstIndex(where: { $0.id == habit.id }) else { return }
        habits[index] = habit
        save()
    }

    func toggleToday(for habit: Habit) {
        toggle(habit)
    }

    // MARK: - Aggregates

    var totalCompletions: Int {
        habits.reduce(0) { $0 + $1.completionCount }
    }

    func habitsCompleted(on date: Date) -> Int {
        habits.filter { $0.isCompleted(on: date) }.count
    }

    // MARK: - Persistence

    private func load() {
        guard let data = try? Data(contentsOf: storageURL) else {
            habits = Habit.samples
            return
        }
        do {
            habits = try JSONDecoder().decode([Habit].self, from: data)
        } catch {
            habits = Habit.samples
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(habits) else { return }
        try? data.write(to: storageURL, options: .atomic)
    }
}
