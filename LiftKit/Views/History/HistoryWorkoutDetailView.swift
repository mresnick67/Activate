import SwiftUI

struct HistoryWorkoutDetailView: View {
    let workout: Workout

    private var completedSetCount: Int {
        workout.sets.filter(\.isCompleted).count
    }

    private var loggedVolumePounds: Double {
        workout.sets
            .filter(\.isCompleted)
            .reduce(0) { partialResult, set in
                guard let weight = set.weight, let reps = set.reps, reps > 0 else { return partialResult }
                return partialResult + (weight * Double(reps))
            }
    }

    private var durationSeconds: Int {
        if let durationSeconds = workout.durationSeconds {
            return max(0, durationSeconds)
        }

        let endDate = workout.completedAt ?? Date()
        return max(0, Int(endDate.timeIntervalSince(workout.startedAt)))
    }

    private var lastUpdatedAt: Date {
        let completionDates = workout.sets.compactMap(\.completedAt)
        let candidateDates = completionDates + [workout.completedAt, workout.startedAt].compactMap { $0 }
        return candidateDates.max() ?? workout.startedAt
    }

    private var groupedSets: [ExerciseGroup] {
        let grouped = Dictionary(grouping: workout.sets) { $0.exerciseOrder }

        return grouped.keys.sorted().compactMap { exerciseOrder in
            guard let sets = grouped[exerciseOrder] else { return nil }
            let sortedSets = sets.sorted { $0.setOrder < $1.setOrder }
            let exercise = sortedSets.compactMap(\.exercise).first
            return ExerciseGroup(exerciseOrder: exerciseOrder, exercise: exercise, sets: sortedSets)
        }
    }

    var body: some View {
        List {
            Section("Facts") {
                statRow(label: "Duration", value: formatDuration(durationSeconds))
                statRow(label: "Completed sets", value: "\(completedSetCount)")
                statRow(label: "Logged volume", value: formatVolume(loggedVolumePounds))
            }

            Section("Timing") {
                statRow(label: "Started", value: workout.startedAt.formatted(date: .abbreviated, time: .shortened))
                statRow(
                    label: "Finished",
                    value: workout.completedAt?.formatted(date: .abbreviated, time: .shortened) ?? "In Progress"
                )
            }

            if groupedSets.isEmpty {
                Section("Exercises") {
                    Text("No logged sets")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            } else {
                ForEach(groupedSets) { group in
                    Section {
                        ForEach(group.sets, id: \.id) { set in
                            setRow(set)
                        }
                    } header: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(group.title)
                            Text(group.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("Disclosure") {
                statRow(label: "Source", value: "On-device workout log (SwiftData)")
                statRow(label: "Last updated", value: lastUpdatedAt.formatted(date: .abbreviated, time: .shortened))

                Text("Volume formula: Σ(weight × reps) for completed loaded sets")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .padding(.top, 4)
            }
        }
        .navigationTitle("Workout Detail")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private func setRow(_ set: WorkoutSet) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Set \(set.setOrder + 1)")
                    .font(.subheadline.weight(.semibold))

                if set.isWarmup {
                    Text("Warm-up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(primarySetValue(set))
                    .font(.subheadline.weight(.semibold))
                    .monospacedDigit()

                Text(secondarySetValue(set))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Label(set.isCompleted ? "Completed" : "Not completed", systemImage: set.isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption.weight(.semibold))
                .labelStyle(.iconOnly)
                .foregroundStyle(set.isCompleted ? .green : .secondary)
                .accessibilityLabel(set.isCompleted ? "Completed" : "Not completed")
        }
        .padding(.vertical, 4)
    }

    @ViewBuilder
    private func statRow(label: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
                .monospacedDigit()
        }
    }

    private func primarySetValue(_ set: WorkoutSet) -> String {
        let weight = set.weight.map { String(format: "%.1f", $0) } ?? "—"
        let reps = set.reps.map(String.init) ?? "—"
        return "\(weight) lb × \(reps)"
    }

    private func secondarySetValue(_ set: WorkoutSet) -> String {
        let rpe = set.rpe.map { String(format: "RPE %.1f", $0) } ?? "RPE —"
        let completed = set.completedAt?.formatted(date: .omitted, time: .shortened) ?? "not timestamped"
        return "\(rpe) • \(completed)"
    }

    private func formatDuration(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60

        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
        }

        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }

    private func formatVolume(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        formatter.minimumFractionDigits = 0
        let number = formatter.string(from: NSNumber(value: value)) ?? String(format: "%.0f", value)
        return "\(number) lb"
    }
}

private extension HistoryWorkoutDetailView {
    struct ExerciseGroup: Identifiable {
        var id: Int { exerciseOrder }

        let exerciseOrder: Int
        let exercise: Exercise?
        let sets: [WorkoutSet]

        var title: String {
            if let exercise {
                return exercise.name
            }

            return "Unknown Exercise"
        }

        var subtitle: String {
            let orderText = "Exercise \(exerciseOrder + 1)"
            let equipment = exercise?.equipment.displayName ?? "Unknown equipment"
            return "\(orderText) • \(equipment)"
        }
    }
}

#Preview {
    let bench = Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false)
    let inclineDB = Exercise(name: "Incline DB Press", category: .chest, equipment: .dumbbell, isCustom: false)

    let workout = Workout(
        startedAt: .now.addingTimeInterval(-3_200),
        completedAt: .now.addingTimeInterval(-2_500),
        durationSeconds: 700
    )

    workout.sets = [
        WorkoutSet(exercise: bench, workout: workout, setOrder: 0, exerciseOrder: 0, weight: 135, reps: 8, rpe: 8, isCompleted: true, completedAt: .now.addingTimeInterval(-2_900)),
        WorkoutSet(exercise: bench, workout: workout, setOrder: 1, exerciseOrder: 0, weight: 145, reps: 6, rpe: 9, isCompleted: true, completedAt: .now.addingTimeInterval(-2_780)),
        WorkoutSet(exercise: inclineDB, workout: workout, setOrder: 0, exerciseOrder: 1, weight: 60, reps: 10, rpe: 8.5, isCompleted: false, completedAt: nil)
    ]

    return NavigationStack {
        HistoryWorkoutDetailView(workout: workout)
    }
}
