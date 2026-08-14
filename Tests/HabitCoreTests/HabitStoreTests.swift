import XCTest
@testable import HabitCore

final class HabitStoreTests: XCTestCase {

    private func makeTempStore() throws -> (HabitStore, URL) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("habithub-tests-\(UUID().uuidString)")
            .appendingPathComponent("habits.json")
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        return (HabitStore(storageURL: url), url)
    }

    private func cleanup(_ url: URL) {
        try? FileManager.default.removeItem(at: url.deletingLastPathComponent())
    }

    // MARK: - CRUD

    func testAddAndDelete() throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        XCTAssertEqual(store.habits.count, 0)
        store.add(Habit(title: "Read"))
        XCTAssertEqual(store.habits.count, 1)

        store.delete(store.habits[0])
        XCTAssertEqual(store.habits.count, 0)
    }

    func testToggleUpdatesTheHabit() throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        let habit = Habit(title: "Run")
        store.add(habit)
        XCTAssertEqual(store.totalCompletions, 0)

        store.toggle(habit)
        XCTAssertEqual(store.totalCompletions, 1)
        XCTAssertEqual(store.habitsCompleted(on: Date()), 1)

        store.toggleToday(for: store.habits[0])
        XCTAssertEqual(store.totalCompletions, 0)
    }

    func testUpdateReplacesHabit() throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        var habit = Habit(title: "Draft")
        store.add(habit)

        habit.title = "Draft habit"
        store.update(habit)

        XCTAssertEqual(store.habits.first?.title, "Draft habit")
    }

    // MARK: - Persistence

    func testPersistenceSurvivesStoreRecreation() throws {
        let (store, url) = try makeTempStore()
        defer { cleanup(url) }

        var habit = Habit(title: "Persist me", emoji: "💾", weeklyGoal: 3)
        habit.toggle()
        store.add(habit)

        let reloaded = HabitStore(storageURL: url)
        XCTAssertEqual(reloaded.habits.count, 1)
        XCTAssertEqual(reloaded.habits.first, habit)
        XCTAssertEqual(reloaded.habits.first?.completionCount, 1)
    }

    func testMissingFileSeedsSampleData() throws {
        let (store, _) = try makeTempStore()
        XCTAssertEqual(store.habits, Habit.samples)
    }

    func testCorruptFileFallsBackToSamples() throws {
        let (_, url) = try makeTempStore()
        try FileManager.default.createDirectory(
            at: url.deletingLastPathComponent(), withIntermediateDirectories: true
        )
        try "not valid json".write(to: url, atomically: true, encoding: .utf8)
        defer { cleanup(url) }

        let store = HabitStore(storageURL: url)
        XCTAssertEqual(store.habits, Habit.samples)
    }
}
