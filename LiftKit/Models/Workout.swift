import Foundation
import SwiftData

@Model
final class Workout {
    var id: UUID
    var startedAt: Date
    var completedAt: Date?
    var name: String?
    var notes: String?
    var durationSeconds: Int?
    var templateId: UUID?

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.workout)
    var sets: [WorkoutSet]

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        completedAt: Date? = nil,
        name: String? = nil,
        notes: String? = nil,
        durationSeconds: Int? = nil,
        templateId: UUID? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.name = name
        self.notes = notes
        self.durationSeconds = durationSeconds
        self.templateId = templateId
        self.sets = []
    }
}
