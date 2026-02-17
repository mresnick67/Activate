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

        let nextExerciseOrder: Int = (workout.sets.map { $0.exerciseOrder }.max() ?? -1) + 1

        for idx in 0..<max(1, defaultSetCount) {
            let set = WorkoutSet(
                exercise: exercise,
                workout: workout,
                setOrder: idx,
                exerciseOrder: nextExerciseOrder
            )
            modelContext.insert(set)
        }

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
            // All sets within an exerciseOrder should share the same exercise.
            guard let exercise = sets.compactMap({ $0.exercise }).first else { return nil }

            let sortedSets = sets.sorted { $0.setOrder < $1.setOrder }
            return ExerciseGroup(exercise: exercise, exerciseOrder: order, sets: sortedSets)
        }
    }
}
