import Foundation
import Observation
import SwiftData

@Observable
final class WorkoutViewModel {
    private(set) var workout: Workout?

    var isStartingWorkout: Bool = false
    var startErrorMessage: String?

    func startWorkoutIfNeeded(modelContext: ModelContext) {
        guard workout == nil else { return }
        isStartingWorkout = true
        defer { isStartingWorkout = false }

        let newWorkout = Workout(startedAt: Date())
        modelContext.insert(newWorkout)

        // Save early so the workout has a stable persisted identity for relationships.
        do {
            try modelContext.save()
            workout = newWorkout
        } catch {
            startErrorMessage = "Failed to start workout."
        }
    }

    func addExercise(_ exercise: Exercise, defaultSetCount: Int = 3, modelContext: ModelContext) {
        guard let workout else { return }

        let nextExerciseOrder = (workout.sets.map(\.exerciseOrder).max() ?? -1) + 1

        for idx in 0..<max(1, defaultSetCount) {
            let set = WorkoutSet(
                exercise: exercise,
                workout: workout,
                setOrder: idx,
                exerciseOrder: nextExerciseOrder
            )
            modelContext.insert(set)
        }

        persistChanges(modelContext: modelContext)
    }

    func addSet(to group: ExerciseGroup, modelContext: ModelContext) {
        guard let workout else { return }

        let nextSetOrder = (group.sets.map(\.setOrder).max() ?? -1) + 1

        let newSet = WorkoutSet(
            exercise: group.exercise,
            workout: workout,
            setOrder: nextSetOrder,
            exerciseOrder: group.exerciseOrder
        )

        modelContext.insert(newSet)
        persistChanges(modelContext: modelContext)
    }

    func deleteSets(at offsets: IndexSet, from group: ExerciseGroup, modelContext: ModelContext) {
        guard let workout else { return }

        let orderedSets = workout.sets
            .filter { $0.exerciseOrder == group.exerciseOrder }
            .sorted { $0.setOrder < $1.setOrder }

        guard !orderedSets.isEmpty else { return }

        for index in offsets {
            guard orderedSets.indices.contains(index) else { continue }
            modelContext.delete(orderedSets[index])
        }

        let remainingSets = orderedSets.enumerated()
            .compactMap { offsets.contains($0.offset) ? nil : $0.element }

        for (index, set) in remainingSets.enumerated() {
            set.setOrder = index
        }

        persistChanges(modelContext: modelContext)
    }

    func toggleSetCompletion(_ set: WorkoutSet, isCompleted: Bool, modelContext: ModelContext) {
        set.isCompleted = isCompleted
        set.completedAt = isCompleted ? Date() : nil
        persistChanges(modelContext: modelContext)
    }

    func copyValues(from source: WorkoutSet, to target: WorkoutSet, modelContext: ModelContext) {
        target.weight = source.weight
        target.reps = source.reps
        target.rpe = source.rpe
        persistChanges(modelContext: modelContext)
    }

    func persistChanges(modelContext: ModelContext) {
        do {
            try modelContext.save()
        } catch {
            // Non-fatal for now; UI will still reflect in-memory state.
        }
    }

    // MARK: - Derived UI State

    struct ExerciseGroup: Identifiable {
        var id: String { "\(exercise.id.uuidString)-\(exerciseOrder)" }
        let exercise: Exercise
        let exerciseOrder: Int
        let sets: [WorkoutSet]
    }

    func groupedSets() -> [ExerciseGroup] {
        guard let workout else { return [] }

        let byExerciseOrder = Dictionary(grouping: workout.sets) { $0.exerciseOrder }
        let sortedOrders = byExerciseOrder.keys.sorted()

        return sortedOrders.compactMap { order in
            guard let sets = byExerciseOrder[order] else { return nil }
            guard let exercise = sets.compactMap({ $0.exercise }).first else { return nil }

            let sortedSets = sets.sorted { $0.setOrder < $1.setOrder }
            return ExerciseGroup(exercise: exercise, exerciseOrder: order, sets: sortedSets)
        }
    }
}
