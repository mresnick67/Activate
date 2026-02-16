import Foundation
import SwiftData

@Model
final class WorkoutSet {
    var id: UUID
    var setOrder: Int
    var exercise: Exercise?
    var workout: Workout?

    init(id: UUID = UUID(), setOrder: Int = 0, exercise: Exercise? = nil, workout: Workout? = nil) {
        self.id = id
        self.setOrder = setOrder
        self.exercise = exercise
        self.workout = workout
    }
}
