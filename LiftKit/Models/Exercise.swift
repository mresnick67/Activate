import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]

    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
        self.sets = []
    }
}
