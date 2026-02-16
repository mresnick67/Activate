import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var startedAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet]

    init(id: UUID = UUID(), startedAt: Date = .now) {
        self.id = id
        self.startedAt = startedAt
        self.sets = []
    }
}
