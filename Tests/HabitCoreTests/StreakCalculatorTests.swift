import XCTest
@testable import HabitCore

final class StreakCalculatorTests: XCTestCase {
    private let calendar = Calendar(identifier: .gregorian)

    private func day(_ components: DateComponents) -> Date {
        calendar.startOfDay(for: calendar.date(from: components)!)
    }

    private func days(_ components: [DateComponents]) -> Set<Date> {
        Set(components.map(day))
    }

    // MARK: - currentStreak

    func testCurrentStreakEmpty() {
        XCTAssertEqual(StreakCalculator.currentStreak(for: [], calendar: calendar), 0)
    }

    func testCurrentStreakCountsBackwardsFromToday() {
        let reference = day(.init(year: 2026, month: 8, day: 14))
        let completed = days([
            .init(year: 2026, month: 8, day: 14),
            .init(year: 2026, month: 8, day: 13),
            .init(year: 2026, month: 8, day: 12),
        ])
        XCTAssertEqual(
            StreakCalculator.currentStreak(for: completed, upTo: reference, calendar: calendar),
            3
        )
    }

    func testCurrentStreakIsBrokenWhenTodayMissingButYesterdayCompleted() {
        let reference = day(.init(year: 2026, month: 8, day: 14))
        let completed = days([
            .init(year: 2026, month: 8, day: 13),
            .init(year: 2026, month: 8, day: 12),
        ])
        XCTAssertEqual(
            StreakCalculator.currentStreak(for: completed, upTo: reference, calendar: calendar),
            2
        )
    }

    func testCurrentStreakIsZeroWhenGapIsOlderThanYesterday() {
        let reference = day(.init(year: 2026, month: 8, day: 14))
        let completed = days([.init(year: 2026, month: 8, day: 11)])
        XCTAssertEqual(
            StreakCalculator.currentStreak(for: completed, upTo: reference, calendar: calendar),
            0
        )
    }

    func testCurrentStreakIgnoresFutureDates() {
        let reference = day(.init(year: 2026, month: 8, day: 14))
        let completed = days([
            .init(year: 2026, month: 8, day: 14),
            .init(year: 2026, month: 8, day: 13),
            .init(year: 2026, month: 9, day: 1),
        ])
        XCTAssertEqual(
            StreakCalculator.currentStreak(for: completed, upTo: reference, calendar: calendar),
            2
        )
    }

    // MARK: - longestStreak

    func testLongestStreakEmpty() {
        XCTAssertEqual(StreakCalculator.longestStreak(in: [], calendar: calendar), 0)
    }

    func testLongestStreakSingleDay() {
        let completed = days([.init(year: 2026, month: 8, day: 10)])
        XCTAssertEqual(StreakCalculator.longestStreak(in: completed, calendar: calendar), 1)
    }

    func testLongestStreakFindsTheLongestRun() {
        let completed = days([
            // Run of 4
            .init(year: 2026, month: 8, day: 1),
            .init(year: 2026, month: 8, day: 2),
            .init(year: 2026, month: 8, day: 3),
            .init(year: 2026, month: 8, day: 4),
            // Gap
            .init(year: 2026, month: 8, day: 10),
            // Run of 2
            .init(year: 2026, month: 8, day: 11),
        ])
        XCTAssertEqual(StreakCalculator.longestStreak(in: completed, calendar: calendar), 4)
    }

    func testLongestStreakIgnoresDuplicates() {
        let duplicate = day(.init(year: 2026, month: 8, day: 10))
        let completed: Set<Date> = [
            duplicate,
            duplicate,
            .init(year: 2026, month: 8, day: 11),
        ]
        XCTAssertEqual(StreakCalculator.longestStreak(in: completed, calendar: calendar), 2)
    }

    // MARK: - completionsByDay

    func testCompletionsByDaySpansSevenDaysOldestToNewest() {
        let reference = day(.init(year: 2026, month: 8, day: 14))
        let completed = days([
            .init(year: 2026, month: 8, day: 14),
            .init(year: 2026, month: 8, day: 10),
        ])
        let result = StreakCalculator.completionsByDay(
            completed, span: 7, upTo: reference, calendar: calendar
        )

        XCTAssertEqual(result.count, 7)
        XCTAssertEqual(result[reference], 1)
        XCTAssertEqual(result[day(.init(year: 2026, month: 8, day: 13))], 0)
        XCTAssertEqual(result[day(.init(year: 2026, month: 8, day: 10))], 1)
        XCTAssertEqual(result[day(.init(year: 2026, month: 8, day: 8))], 0)
    }
}
