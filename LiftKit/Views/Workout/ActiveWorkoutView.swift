import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = WorkoutViewModel()
    @State private var isShowingExercisePicker = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    workoutHeader
                }

                let groups = viewModel.groupedSets()
                if groups.isEmpty {
                    ContentUnavailableView(
                        "No exercises yet",
                        systemImage: "dumbbell",
                        description: Text("Add your first exercise to start logging sets.")
                    )
                } else {
                    ForEach(groups) { group in
                        Section {
                            ForEach(group.sets) { set in
                                HStack {
                                    Text("Set \(set.setOrder + 1)")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text("—")
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        } header: {
                            HStack {
                                Text(group.exercise.name)
                                Spacer()
                                Text(group.exercise.equipment.displayName)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .accessibilityLabel("Close")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingExercisePicker = true
                    } label: {
                        Label("Add Exercise", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $isShowingExercisePicker) {
                ExercisePickerView { exercise in
                    viewModel.addExercise(exercise, modelContext: modelContext)
                }
                .presentationDetents([.medium, .large])
            }
            .alert(
                "Couldn't start workout",
                isPresented: Binding(
                    get: { viewModel.startErrorMessage != nil },
                    set: { newValue in
                        if !newValue { viewModel.startErrorMessage = nil }
                    }
                )
            ) {
                Button("OK") {
                    viewModel.startErrorMessage = nil
                }
            } message: {
                Text(viewModel.startErrorMessage ?? "")
            }
            .onAppear {
                viewModel.startWorkoutIfNeeded(modelContext: modelContext)
            }
        }
    }

    @ViewBuilder
    private var workoutHeader: some View {
        if let workout = viewModel.workout {
            VStack(alignment: .leading, spacing: 8) {
                Text("Started \(workout.startedAt.formatted(date: .abbreviated, time: .shortened))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                TimelineView(.periodic(from: workout.startedAt, by: 1)) { context in
                    let elapsed = Int(context.date.timeIntervalSince(workout.startedAt))
                    Text("Elapsed: \(formatElapsed(elapsed))")
                        .font(.headline)
                        .monospacedDigit()
                }
            }
            .padding(.vertical, 4)
        } else {
            HStack {
                ProgressView()
                Text("Starting workout…")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func formatElapsed(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let secs = seconds % 60
        return String(format: "%02d:%02d", minutes, secs)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Exercise.self, Workout.self, WorkoutSet.self, WorkoutTemplate.self,
        configurations: config
    )
    container.mainContext.insert(Exercise(name: "Bench Press", category: .chest, equipment: .barbell, isCustom: false))

    return ActiveWorkoutView()
        .modelContainer(container)
}
