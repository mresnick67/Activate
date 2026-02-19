import SwiftUI

struct WorkoutSummaryView: View {
    let summary: WorkoutViewModel.WorkoutSummary
    let onDone: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Facts") {
                    statRow(label: "Duration", value: formatDuration(summary.durationSeconds))
                    statRow(label: "Completed sets", value: "\(summary.completedSetCount)")
                    statRow(label: "Logged volume", value: formatVolume(summary.loggedVolumePounds))
                }

                Section("Timing") {
                    statRow(
                        label: "Started",
                        value: summary.startedAt.formatted(date: .abbreviated, time: .shortened)
                    )
                    statRow(
                        label: "Finished",
                        value: summary.completedAt.formatted(date: .abbreviated, time: .shortened)
                    )
                }
            }
            .navigationTitle("Workout Saved")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        onDone()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func statRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .multilineTextAlignment(.trailing)
        }
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
    WorkoutSummaryView(
        summary: .init(
            workout: {
                let workout = Workout(startedAt: .now.addingTimeInterval(-2500), completedAt: .now, durationSeconds: 2500)
                let exercise = Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false)
                let set = WorkoutSet(exercise: exercise, workout: workout, setOrder: 0, exerciseOrder: 0, weight: 135, reps: 8, rpe: 8, isCompleted: true, completedAt: .now)
                workout.sets = [set]
                return workout
            }()
        ),
        onDone: {}
    )
}
