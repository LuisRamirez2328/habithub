import SwiftUI
import HabitCore

struct AddHabitView: View {
    @Environment(HabitStore.self) private var store
    @Environment(\.dismiss) private var dismiss

    private static let emojis = ["🏃", "📚", "💧", "🧘", "💻", "🥗", "😴", "🎯", "🎸", "✍️", "🚴", "🧠"]
    private static let colors = ["mint", "sky", "indigo", "amber", "rose", "teal"]

    @State private var title = ""
    @State private var emoji = "🎯"
    @State private var colorName = "mint"
    @State private var weeklyGoal = 5

    var body: some View {
        NavigationStack {
            Form {
                Section("Name") {
                    TextField("e.g. Morning run", text: $title)
                }

                Section("Icon") {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                        ForEach(Self.emojis, id: \.self) { candidate in
                            Button {
                                emoji = candidate
                            } label: {
                                Text(candidate)
                                    .font(.title2)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 6)
                                    .background(emoji == candidate ? Theme.accent.opacity(0.25) : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section("Color") {
                    HStack {
                        ForEach(Self.colors, id: \.self) { name in
                            Button {
                                colorName = name
                            } label: {
                                Circle()
                                    .fill(Theme.color(name))
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(colorName == name ? Theme.textPrimary : .clear, lineWidth: 2)
                                    )
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }

                Section("Weekly goal") {
                    Stepper(value: $weeklyGoal, in: 1...7) {
                        Text("\(weeklyGoal) days per week")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.background.ignoresSafeArea())
            .navigationTitle("New habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.add(
                            Habit(
                                title: trimmedTitle,
                                emoji: emoji,
                                colorName: colorName,
                                weeklyGoal: weeklyGoal
                            )
                        )
                        dismiss()
                    }
                    .disabled(trimmedTitle.isEmpty)
                }
            }
        }
        .tint(Theme.accent)
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
