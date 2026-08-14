import Foundation

/// A single trackable habit with its completion history.
struct Habit: Identifiable, Codable, Hashable {
    let id: UUID
    var title: String
    var emoji: String
    var colorName: String
    var weeklyGoal: Int
    var completionDates: Set<Date>

    init(
        id: UUID = UUID(),
        title: String,
        emoji: String = "🌟",
        colorName: String = "mint",
        weeklyGoal: Int = 5,
        completionDates: Set<Date> = []
    ) {
        self.id = id
        self.title = title
        self.emoji = emoji
        self.colorName = colorName
        self.weeklyGoal = max(1, weeklyGoal)
        self.completionDates = completionDates
    }

    /// Current consecutive-day streak ending today or yesterday.
    var currentStreak: Int {
        StreakCalculator.currentStreak(for: completionDates)
    }

    /// Longest run of consecutive completion days ever recorded.
    var longestStreak: Int {
        StreakCalculator.longestStreak(in: completionDates)
    }

    var completionCount: Int {
        completionDates.count
    }

    /// Completions recorded in the last 7 days.
    var weeklyCompletionCount: Int {
        completionsByDay(span: 7).values.reduce(0, +)
    }

    /// Percentage (0...1) of the weekly goal reached in the last 7 days.
    var weeklyProgress: Double {
        guard weeklyGoal > 0 else { return 0 }
        return min(1.0, Double(weeklyCompletionCount) / Double(weeklyGoal))
    }

    /// Completions per day for the last `span` days, oldest → newest.
    func completionsByDay(span: Int = 7, upTo reference: Date = Date()) -> [Date: Int] {
        StreakCalculator.completionsByDay(completionDates, span: span, upTo: reference)
    }

    func isCompleted(on date: Date) -> Bool {
        completionDates.contains(Calendar.current.startOfDay(for: date))
    }

    mutating func toggle(_ date: Date = Date()) {
        let day = Calendar.current.startOfDay(for: date)
        if completionDates.contains(day) {
            completionDates.remove(day)
        } else {
            completionDates.insert(day)
        }
    }
}

extension Habit {
    /// Sample habits used the first time the app is launched.
    static let samples: [Habit] = {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        func day(_ offset: Int) -> Date {
            calendar.date(byAdding: .day, value: offset, to: today) ?? today
        }

        return [
            Habit(
                title: "Morning run",
                emoji: "🏃",
                colorName: "mint",
                weeklyGoal: 4,
                completionDates: [day(-3), day(-2), day(-1)]
            ),
            Habit(
                title: "Read 20 pages",
                emoji: "📚",
                colorName: "sky",
                weeklyGoal: 6,
                completionDates: [day(-6), day(-5), day(-4), day(-1)]
            ),
            Habit(
                title: "Drink water",
                emoji: "💧",
                colorName: "indigo",
                weeklyGoal: 7,
                completionDates: [day(-2), day(-1), day(0)]
            ),
            Habit(
                title: "Meditate",
                emoji: "🧘",
                colorName: "amber",
                weeklyGoal: 5,
                completionDates: [day(0)]
            ),
        ]
    }()
}
