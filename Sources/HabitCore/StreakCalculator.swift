import Foundation

/// Pure, deterministic logic for computing habit streaks — kept free of UI and
/// I/O so it can be exhaustively unit tested. The `calendar` parameter is
/// injectable for fully deterministic tests.
enum StreakCalculator {

    /// Number of consecutive completed days ending at `reference` (today).
    /// A streak is only broken when neither today nor yesterday is completed.
    static func currentStreak(
        for dates: Set<Date>,
        upTo reference: Date = Date(),
        calendar: Calendar = .current
    ) -> Int {
        let days = Set(dates.map { calendar.startOfDay(for: $0) })

        var cursor = calendar.startOfDay(for: reference)
        if !days.contains(cursor) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = yesterday
        }

        var streak = 0
        while days.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return streak
    }

    /// Longest run of consecutive completed days in the whole history.
    static func longestStreak(
        in dates: Set<Date>,
        calendar: Calendar = .current
    ) -> Int {
        let days = Set(dates.map { calendar.startOfDay(for: $0) }).sorted()

        guard !days.isEmpty else { return 0 }
        if days.count == 1 { return 1 }

        var longest = 1
        var current = 1
        for index in 1..<days.count {
            let gap = calendar.dateComponents([.day], from: days[index - 1], to: days[index]).day ?? 0
            if gap == 1 {
                current += 1
                longest = max(longest, current)
            } else {
                current = 1
            }
        }
        return longest
    }

    /// Maps the last `span` days (oldest → newest) to completion counts (0 or 1).
    static func completionsByDay(
        _ dates: Set<Date>,
        span: Int = 7,
        upTo reference: Date = Date(),
        calendar: Calendar = .current
    ) -> [Date: Int] {
        let days = Set(dates.map { calendar.startOfDay(for: $0) })
        let end = calendar.startOfDay(for: reference)

        var result: [Date: Int] = [:]
        for offset in (0..<span).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: end) else { continue }
            result[day] = days.contains(day) ? 1 : 0
        }
        return result
    }
}
