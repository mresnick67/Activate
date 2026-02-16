import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var category: ExerciseCategory
    var equipment: Equipment
    var isCustom: Bool
    var notes: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]

    init(
        id: UUID = UUID(),
        name: String,
        category: ExerciseCategory,
        equipment: Equipment,
        isCustom: Bool = false,
        notes: String? = nil,
        createdAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.equipment = equipment
        self.isCustom = isCustom
        self.notes = notes
        self.createdAt = createdAt
        self.sets = []
    }
}
