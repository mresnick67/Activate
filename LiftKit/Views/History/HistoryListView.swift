import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Query(sort: \Workout.startedAt, order: .reverse) private var workouts: [Workout]

    private var completedWorkouts: [Workout] {
        workouts.filter { $0.completedAt != nil }
    }

    private var inProgressWorkouts: [Workout] {
        workouts.filter { $0.completedAt == nil }
    }

    var body: some View {
        NavigationStack {
            List {
                Section("Completed") {
                    if completedWorkouts.isEmpty {
                        emptySectionRow("No completed workouts yet")
                    } else {
                        ForEach(completedWorkouts) { workout in
                            HistoryWorkoutRow(workout: workout, status: .completed)
                        }
                    }
                }

                Section("In Progress") {
                    if inProgressWorkouts.isEmpty {
                        emptySectionRow("No in-progress workouts")
                    } else {
                        ForEach(inProgressWorkouts) { workout in
                            HistoryWorkoutRow(workout: workout, status: .inProgress)
                        }
                    }
                }
            }
            .navigationTitle("History")
        }
    }

    @ViewBuilder
    private func emptySectionRow(_ message: String) -> some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.vertical, 4)
    }
}

private struct HistoryWorkoutRow: View {
    enum Status: Equatable {
        case completed
        case inProgress

        var title: String {
            switch self {
            case .completed:
                return "Completed"
            case .inProgress:
                return "In Progress"
            }
        }

        var tint: Color {
            switch self {
            case .completed:
                return .green
            case .inProgress:
                return .orange
            }
        }
    }

    let workout: Workout
    let status: Status

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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(workout.startedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.headline)

                Spacer()

                Text(status.title)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(status.tint.opacity(0.16), in: Capsule())
                    .foregroundStyle(status.tint)
            }

            HStack(spacing: 12) {
                metric(label: "Duration") {
                    if status == .completed {
                        Text(formatDuration(durationSeconds))
                    } else {
                        TimelineView(.periodic(from: workout.startedAt, by: 1)) { context in
                            let elapsed = max(0, Int(context.date.timeIntervalSince(workout.startedAt)))
                            Text(formatDuration(elapsed))
                        }
                    }
                }

                metric(label: "Sets") {
                    Text("\(completedSetCount)")
                }

                metric(label: "Volume") {
                    Text(formatVolume(loggedVolumePounds))
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .listRowBackground(status == .inProgress ? Color.orange.opacity(0.08) : Color.clear)
    }

    private var durationSeconds: Int {
        if let durationSeconds = workout.durationSeconds {
            return max(0, durationSeconds)
        }

        let endDate = workout.completedAt ?? Date()
        return max(0, Int(endDate.timeIntervalSince(workout.startedAt)))
    }

    @ViewBuilder
    private func metric<Content: View>(label: String, @ViewBuilder value: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)

            value()
                .font(.subheadline.weight(.semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self,
        configurations: config
    )

    let context = container.mainContext

    let bench = Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false)
    context.insert(bench)

    let completedWorkout = Workout(startedAt: .now.addingTimeInterval(-4_200), completedAt: .now.addingTimeInterval(-3_600), durationSeconds: 600)
    let completedSet = WorkoutSet(exercise: bench, workout: completedWorkout, setOrder: 0, exerciseOrder: 0, weight: 135, reps: 8, isCompleted: true, completedAt: .now.addingTimeInterval(-3_900))
    context.insert(completedWorkout)
    context.insert(completedSet)

    let inProgressWorkout = Workout(startedAt: .now.addingTimeInterval(-420))
    let inProgressSet = WorkoutSet(exercise: bench, workout: inProgressWorkout, setOrder: 0, exerciseOrder: 0, weight: 155, reps: 5, isCompleted: true, completedAt: .now.addingTimeInterval(-120))
    context.insert(inProgressWorkout)
    context.insert(inProgressSet)

    return HistoryListView()
        .modelContainer(container)
}
