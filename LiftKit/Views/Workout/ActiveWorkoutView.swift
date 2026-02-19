import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = WorkoutViewModel()
    @State private var isShowingExercisePicker = false
    @FocusState private var focusedField: WorkoutSetInputField?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    workoutHeader
                }

                if viewModel.isRestTimerActive {
                    Section {
                        restTimerCapsule
                    }
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
                            ForEach(Array(group.sets.enumerated()), id: \.element.id) { index, set in
                                WorkoutSetRowView(
                                    set: set,
                                    previousSet: index > 0 ? group.sets[index - 1] : nil,
                                    onToggleCompletion: { isCompleted in
                                        viewModel.toggleSetCompletion(set, isCompleted: isCompleted, modelContext: modelContext)
                                    },
                                    onPersist: {
                                        viewModel.persistChanges(modelContext: modelContext)
                                    },
                                    focusedField: $focusedField
                                )
                            }
                            .onDelete { offsets in
                                viewModel.deleteSets(at: offsets, from: group, modelContext: modelContext)
                            }

                            Button {
                                viewModel.addSet(to: group, modelContext: modelContext)
                            } label: {
                                Label("Add Set", systemImage: "plus.circle")
                                    .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.plain)
                            .padding(.vertical, 4)
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

                ToolbarItemGroup(placement: .keyboard) {
                    Button("Next") {
                        focusNextField()
                    }
                    .disabled(focusedField == nil)

                    Spacer()

                    Button("Done") {
                        focusedField = nil
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
            .onDisappear {
                focusedField = nil
                viewModel.skipRestTimer()
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

    @ViewBuilder
    private var restTimerCapsule: some View {
        if let remaining = viewModel.restTimeRemainingSeconds {
            HStack(spacing: 10) {
                Label("Rest", systemImage: "timer")
                    .font(.subheadline.weight(.semibold))

                Text(formatElapsed(remaining))
                    .font(.headline.monospacedDigit())

                Spacer()

                Button("-15s") {
                    viewModel.adjustRestTimer(by: -15)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("+15s") {
                    viewModel.adjustRestTimer(by: 15)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)

                Button("Skip") {
                    viewModel.skipRestTimer()
                }
                .buttonStyle(.borderless)
                .foregroundStyle(.secondary)
                .font(.subheadline)
            }
            .padding(.vertical, 4)
        }
    }

    private func focusNextField() {
        guard let focusedField else { return }

        switch focusedField {
        case .weight(let setID):
            self.focusedField = .reps(setID)

        case .reps(let setID):
            self.focusedField = .rpe(setID)

        case .rpe(let setID):
            let orderedIDs = orderedSetIDs()
            guard let currentIndex = orderedIDs.firstIndex(of: setID) else {
                self.focusedField = nil
                return
            }

            let nextIndex = currentIndex + 1
            guard orderedIDs.indices.contains(nextIndex) else {
                self.focusedField = nil
                return
            }

            self.focusedField = .weight(orderedIDs[nextIndex])
        }
    }

    private func orderedSetIDs() -> [UUID] {
        viewModel.groupedSets().flatMap { group in
            group.sets.map(\.id)
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
