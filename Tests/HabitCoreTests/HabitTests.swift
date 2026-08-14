import XCTest
@testable import HabitCore

final class HabitTests: XCTestCase {
    private let calendar = Calendar.current

    private func day(_ offset: Int, from reference: Date = Date()) -> Date {
        calendar.startOfDay(for: calendar.date(byAdding: .day, value: offset, to: reference)!)
    }

    // MARK: - Toggle & queries

    func testToggleInsertsAndRemoves() {
        var habit = Habit(title: "Read")
        XCTAssertFalse(habit.isCompleted(on: day(0)))
        XCTAssertEqual(habit.currentStreak, 0)

        habit.toggle(day(0))
        XCTAssertTrue(habit.isCompleted(on: day(0)))
        XCTAssertEqual(habit.currentStreak, 1)

        habit.toggle(day(0))
        XCTAssertFalse(habit.isCompleted(on: day(0)))
    }

    func testToggleStoresWholeDays() {
        var habit = Habit(title: "Workout")
        let todayAt10PM = calendar.date(byAdding: .hour, value: 22, to: day(0))!
        habit.toggle(todayAt10PM)
        XCTAssertTrue(habit.isCompleted(on: todayAt10PM))
        XCTAssertEqual(habit.completionCount, 1)
    }

    func testWeeklyProgressClampsToOne() {
        var habit = Habit(title: "Hydrate", weeklyGoal: 3)
        for offset in (-2...0) {
            habit.toggle(day(offset))
        }
        XCTAssertEqual(habit.completionCount, 3)
        XCTAssertEqual(habit.weeklyProgress, 1.0, accuracy: 0.001)
    }

    func testWeeklyGoalIsClampedToMinimum() {
        let habit = Habit(title: "Stretch", weeklyGoal: -2)
        XCTAssertEqual(habit.weeklyGoal, 1)
    }

    func testCurrentAndLongestStreakAreExposed() {
        var habit = Habit(title: "Meditate")
        for offset in (-5...(-2)) {
            habit.toggle(day(offset))
        }
        XCTAssertEqual(habit.longestStreak, 4)
        // Today missing, but yesterday (-1) is also missing → streak broken.
        XCTAssertEqual(habit.currentStreak, 0)
    }

    func testCompletionsByDayOnlyReturnsLastWeek() {
        var habit = Habit(title: "Code")
        for offset in (-20...(-10)) {
            habit.toggle(day(offset))
        }
        let lastWeek = habit.completionsByDay(span: 7)
        XCTAssertEqual(lastWeek.values.reduce(0, +), 0)
        XCTAssertEqual(lastWeek.count, 7)
    }

    // MARK: - Codable

    func testCodableRoundTrip() throws {
        var habit = Habit(title: "Run", emoji: "🏃", colorName: "mint", weeklyGoal: 4)
        habit.toggle(day(0))
        habit.toggle(day(-1))

        let data = try JSONEncoder().encode(habit)
        let decoded = try JSONDecoder().decode(Habit.self, from: data)

        XCTAssertEqual(decoded, habit)
        XCTAssertEqual(decoded.id, habit.id)
        XCTAssertEqual(decoded.completionCount, 2)
    }

    func testSamplesAreValid() {
        for habit in Habit.samples {
            XCTAssertFalse(habit.title.isEmpty)
            XCTAssertGreaterThanOrEqual(habit.weeklyGoal, 1)
        }
        XCTAssertEqual(Habit.samples.count, 4)
    }
}
