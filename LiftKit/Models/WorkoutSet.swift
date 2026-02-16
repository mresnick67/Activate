import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID

    // Relationships
    var exercise: Exercise?
    var workout: Workout?

    // Ordering
    var setOrder: Int
    var exerciseOrder: Int

    // Metrics
    var weight: Double?
    var reps: Int?
    var durationSeconds: Int?
    var rpe: Double?

    // State
    var isWarmup: Bool
    var isCompleted: Bool
    var completedAt: Date?

    // Notes
    var notes: String?

    init(
        id: UUID = UUID(),
        exercise: Exercise? = nil,
        workout: Workout? = nil,
        setOrder: Int,
        exerciseOrder: Int,
        weight: Double? = nil,
        reps: Int? = nil,
        durationSeconds: Int? = nil,
        rpe: Double? = nil,
        isWarmup: Bool = false,
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        notes: String? = nil
    ) {
        self.id = id
        self.exercise = exercise
        self.workout = workout
        self.setOrder = setOrder
        self.exerciseOrder = exerciseOrder
        self.weight = weight
        self.reps = reps
        self.durationSeconds = durationSeconds
        self.rpe = rpe
        self.isWarmup = isWarmup
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.notes = notes
    }
}
